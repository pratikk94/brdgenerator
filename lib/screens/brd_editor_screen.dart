import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/brd_component.dart';
import '../services/brd_service.dart';
import '../widgets/component_forms.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BRDEditorScreen extends StatefulWidget {
  final String brdId;

  const BRDEditorScreen({
    Key? key,
    required this.brdId,
  }) : super(key: key);

  @override
  _BRDEditorScreenState createState() => _BRDEditorScreenState();
}

class _BRDEditorScreenState extends State<BRDEditorScreen> with SingleTickerProviderStateMixin {
  Timer? _saveTimer;
  BRDComponent? _currentComponent;
  BRDComponent? _originalComponent;  // Store the original component before validation
  Map<String, dynamic>? _validationContent; // Store validation content separately
  bool _isExpanded = false;
  final _scrollController = ScrollController();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      
      if (_tabController.index == 0) {
        // Switching to Form tab - dismiss any validation changes
        _validationContent = null;
        if (_originalComponent != null) {
          setState(() {
            _currentComponent = _originalComponent;
            _originalComponent = null;
          });
        }
      } else if (_tabController.index == 1) {
        // Switching to Validate tab - make a backup of the component
        if (_currentComponent != null) {
          _originalComponent = _currentComponent;
          
          // Create a copy of the content for validation
          try {
            if (_currentComponent!.content.isNotEmpty) {
              _validationContent = Map<String, dynamic>.from(
                jsonDecode(_currentComponent!.content) as Map<String, dynamic>
              );
            } else {
              _validationContent = {};
            }
          } catch (e) {
            _validationContent = {'rawContent': _currentComponent!.content};
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  void _startSaveTimer(BRDService brdService, Map<String, dynamic> content) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (_currentComponent != null) {
        // If we're in validation tab, don't save back to Firebase
        if (_tabController.index == 1) {
          // Only update local validation content
          setState(() {
            _validationContent = content;
          });
          return;
        }
        
        final updatedComponent = _currentComponent!.copyWith(
          content: jsonEncode(content),
          lastModified: DateTime.now(),
        );
        
        brdService.updateComponent(widget.brdId, updatedComponent);
        
        setState(() {
          _currentComponent = updatedComponent;
        });
      }
    });
  }

  Widget _buildTimelineComponent(BRDComponent component, bool isSelected, VoidCallback? onTap) {
    final isDisabled = onTap == null;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: isSelected 
            ? Colors.indigo.shade50 
            : (isDisabled ? Colors.grey.shade100 : Colors.white),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForComponent(component.id),
                    color: isDisabled 
                        ? Colors.grey.shade400 
                        : (component.isCompleted ? Colors.green : Colors.indigo),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    component.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isDisabled ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isDisabled && !component.isCompleted)
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.grey,
                    )
                  else if (component.isCompleted)
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brdService = Provider.of<BRDService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRD Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export BRD',
            onPressed: () async {
              // Call simpler export function
              await _exportBRDAsText(context, brdService);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Submit for Approval',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Submission functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Component timeline at the top
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: StreamBuilder<List<BRDComponent>>(
              stream: brdService.getBRDComponents(widget.brdId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final components = snapshot.data!;
                
                // Order components in a logical flow, not alphabetically
                final orderedIds = [
                  'cover', 'executive', 'problem', 'proposed', 'scope',
                  'requirements', 'constraints', 'timeline', 'resources', 'risks',
                  'glossary', 'signoff'
                ];
                
                // First, check which components are completed
                // to determine which ones should be enabled
                final completedMap = <String, bool>{};
                
                // Always enable the first component (cover page)
                bool previousCompleted = true;
                String? previousCompletedId;
                
                for (final id in orderedIds) {
                  final component = components.firstWhere(
                    (c) => c.id == id, 
                    orElse: () => BRDComponent(
                      id: id,
                      title: id.substring(0, 1).toUpperCase() + id.substring(1),
                      content: '',
                      isCompleted: false,
                      lastModified: DateTime.now(),
                    )
                  );
                  
                  // First component is always enabled
                  if (previousCompletedId == null) {
                    completedMap[id] = true;
                  } else {
                    // A component is available if the previous one is completed
                    completedMap[id] = previousCompleted;
                  }
                  
                  // Update for the next component
                  previousCompleted = component.isCompleted;
                  previousCompletedId = id;
                }
                
                components.sort((a, b) {
                  final indexA = orderedIds.indexOf(a.id);
                  final indexB = orderedIds.indexOf(b.id);
                  if (indexA == -1 && indexB == -1) return a.title.compareTo(b.title);
                  if (indexA == -1) return 1;
                  if (indexB == -1) return -1;
                  return indexA.compareTo(indexB);
                });

                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: components.length,
                  itemBuilder: (context, index) {
                    final component = components[index];
                    final isSelected = _currentComponent?.id == component.id;
                    final isEnabled = completedMap[component.id] ?? false;

                    return _buildTimelineComponent(
                      component,
                      isSelected,
                      isEnabled ? () {
                        setState(() {
                          _currentComponent = component;
                          // Reset to the Form tab when changing components
                          _tabController.animateTo(0);
                        });
                      } : null,
                    );
                  },
                );
              },
            ),
          ),
          // Editor
          Expanded(
            child: _currentComponent == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a component to start editing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Title and metadata
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _currentComponent!.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Mark as complete button
                              IconButton(
                                icon: Icon(
                                  _currentComponent!.isCompleted
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                  color: _currentComponent!.isCompleted
                                    ? Colors.green
                                    : Colors.grey,
                                ),
                                onPressed: () {
                                  final updatedComponent = _currentComponent!.copyWith(
                                    isCompleted: !_currentComponent!.isCompleted,
                                  );
                                  brdService.updateComponent(widget.brdId, updatedComponent);
                                  setState(() {
                                    _currentComponent = updatedComponent;
                                  });
                                },
                                tooltip: 'Mark as complete',
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.save,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Auto-saving',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tab bar for Form/Validate
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.edit_document),
                              text: 'FORM',
                            ),
                            Tab(
                              icon: Icon(Icons.check_circle),
                              text: 'VALIDATE',
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Content area with tabs
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TabBarView(
                                controller: _tabController,
                                physics: const NeverScrollableScrollPhysics(), // Disable swiping between tabs
                                children: [
                                  // Form Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ComponentForms.buildForm(
                                      _currentComponent!,
                                      (updatedContent) {
                                        _startSaveTimer(brdService, updatedContent);
                                      },
                                    ),
                                  ),
                                  
                                  // Validate Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ComponentForms.buildValidator(
                                      _currentComponent!,
                                      _validationContent ?? {}, // Pass our validation-specific content
                                      (updatedComponent) {
                                        // Only update completion status
                                        if (updatedComponent.isCompleted != _currentComponent!.isCompleted) {
                                          setState(() {
                                            _currentComponent = _currentComponent!.copyWith(
                                              isCompleted: updatedComponent.isCompleted,
                                            );
                                            if (_originalComponent != null) {
                                              _originalComponent = _originalComponent!.copyWith(
                                                isCompleted: updatedComponent.isCompleted,
                                              );
                                            }
                                          });
                                          
                                          // Save completion status to Firebase
                                          brdService.updateComponent(
                                            widget.brdId, 
                                            _currentComponent!,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getIconForComponent(String componentId) {
    switch (componentId) {
      case 'cover':
        return Icons.title;
      case 'executive':
        return Icons.summarize;
      case 'problem':
        return Icons.assignment_late;
      case 'proposed':
        return Icons.integration_instructions;
      case 'scope':
        return Icons.crop_free;
      case 'requirements':
        return Icons.fact_check;
      case 'constraints':
        return Icons.block;
      case 'timeline':
        return Icons.timeline;
      case 'resources':
        return Icons.people;
      case 'risks':
        return Icons.warning;
      case 'glossary':
        return Icons.menu_book;
      case 'signoff':
        return Icons.approval;
      default:
        return Icons.article;
    }
  }

  Future<void> _exportBRDAsText(BuildContext context, BRDService brdService) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating text...'),
            ],
          ),
        );
      },
    );

    try {
      // Get all components for this BRD
      final components = await brdService.getBRDComponents(widget.brdId).first;
      
      // Order components in a logical flow, not alphabetically
      final orderedIds = [
        'cover', 'executive', 'problem', 'proposed', 'scope',
        'requirements', 'constraints', 'timeline', 'resources', 'risks',
        'glossary', 'signoff'
      ];
      
      components.sort((a, b) {
        final indexA = orderedIds.indexOf(a.id);
        final indexB = orderedIds.indexOf(b.id);
        if (indexA == -1 && indexB == -1) return a.title.compareTo(b.title);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
      
      // Create text content
      final textContent = StringBuffer();
      
      // Get BRD title and other information from cover page if available
      String brdTitle = 'Business Requirements Document';
      String projectName = '';
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final coverComponent = components.firstWhere(
        (c) => c.id == 'cover',
        orElse: () => BRDComponent(
          id: 'cover',
          title: 'Cover Page',
          content: '{}',
          isCompleted: false,
          lastModified: DateTime.now(),
        ),
      );
      
      if (coverComponent.content.isNotEmpty) {
        try {
          final coverContent = jsonDecode(coverComponent.content) as Map<String, dynamic>;
          projectName = coverContent['projectName'] as String? ?? '';
          if (projectName.isNotEmpty) {
            brdTitle = '$projectName - Business Requirements Document';
          }
          
          // Format date if available
          final docDate = coverContent['date'] as String? ?? '';
          if (docDate.isNotEmpty) {
            date = docDate;
          }
        } catch (e) {
          // Use defaults if parsing fails
        }
      }
      
      textContent.writeln('Title: $brdTitle');
      textContent.writeln('Project: $projectName');
      textContent.writeln('Date: $date');
      textContent.writeln('');
      
      // Add each component as a section
      for (final component in components) {
        Map<String, dynamic> content = {};
        if (component.content.isNotEmpty) {
          try {
            content = jsonDecode(component.content) as Map<String, dynamic>;
          } catch (e) {
            content = {'rawContent': component.content};
          }
        }
        
        textContent.writeln('${component.title}:');
        textContent.writeln(content['rawContent'] as String? ?? '');
        textContent.writeln('');
      }
      
      // Save the text content to a temporary file
      final output = await getTemporaryDirectory();
      final String fileName = '${projectName.isEmpty ? 'BRD' : projectName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${output.path}/$fileName');
      await file.writeAsString(textContent.toString());
      
      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show options to open or share the text file
      await _shareContent(context, textContent.toString(), fileName);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text saved as $fileName')),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating text: $e')),
      );
    }
  }

  Future<void> _shareContent(BuildContext context, String content, String fileName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Generated BRD'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your BRD has been exported as $fileName'),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.copy),
                label: Text('Copy to clipboard'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard')),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 