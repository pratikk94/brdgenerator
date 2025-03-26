import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/document_state.dart';
import 'document_screen.dart';
import 'project_estimates_screen.dart';
import 's_pen_notes_screen.dart';
import '../widgets/progress_loader.dart';
import '../widgets/stylus_text_field.dart';
import '../utils/s_pen_detector.dart';
import '../utils/currency_converter.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;
  bool _hasDocuments = false;
  
  // New properties for earnings dashboard
  Map<String, dynamic> _earningsData = {};
  bool _isLoadingEarnings = true;
  String _selectedBoard = '';
  List<String> _availableBoards = [];
  final TaskService _taskService = TaskService();

  // Preset prompts that users can choose from
  final List<Map<String, String>> _presetPrompts = [
    {
      'title': 'AI Learning Platform',
      'prompt': 'Create a project plan for an AI-powered learning assistant that helps users learn new concepts through personalized tutoring, quizzes, and video explanations.',
    },
    {
      'title': 'E-commerce Platform',
      'prompt': 'Create a project plan for a modern e-commerce platform with features like product catalog, shopping cart, secure checkout, user reviews, and vendor management.',
    },
    {
      'title': 'Health Tracking App',
      'prompt': 'Create a project plan for a mobile health tracking application that monitors users\' fitness activities, diet, sleep patterns, and provides personalized recommendations.',
    },
    {
      'title': 'Project Management Tool',
      'prompt': 'Create a project plan for a web-based project management tool with task tracking, team collaboration, time logging, and reporting features.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }
  
  // New method to load earnings data
  Future<void> _loadEarningsData() async {
    setState(() {
      _isLoadingEarnings = true;
    });
    
    try {
      // Get all boards
      final boards = await _taskService.getAllBoards();
      _availableBoards = boards.map((board) => board.id).toList();
      
      if (_availableBoards.isNotEmpty) {
        _selectedBoard = _availableBoards.first;
        await _loadBoardStatistics(_selectedBoard);
      }
    } catch (e) {
      print('Error loading earnings data: $e');
    } finally {
      setState(() {
        _isLoadingEarnings = false;
      });
    }
  }
  
  // Load statistics for a specific board
  Future<void> _loadBoardStatistics(String boardId) async {
    try {
      final stats = await _taskService.getBoardStatistics(boardId);
      setState(() {
        _earningsData = stats;
        _selectedBoard = boardId;
      });
    } catch (e) {
      print('Error loading board statistics: $e');
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentState = Provider.of<DocumentState>(context);
    _hasDocuments = documentState.getAllDocumentTypes().isNotEmpty;
    final bool isStylusAvailable = SPenDetector.shouldShowStylusFeatures();
    
    // Use MediaQuery to handle responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return _hasDocuments ? Column(
      children: [
        // Add the cumulative earnings dashboard at the top
        _buildCumulativeEarningsDashboard(documentState),
        Expanded(
          child: _buildDocumentGrid(documentState),
        ),
      ],
    ) : _buildPromptInput();
  }

  Widget _buildPromptInput() {
    // Get screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final bool isStylusAvailable = SPenDetector.shouldShowStylusFeatures();
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16.0 : 24.0, 
        vertical: isSmallScreen ? 24.0 : 40.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: isSmallScreen ? 60 : 80,
                  color: Colors.indigo,
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Generate Project Documents',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Enter a project description to automatically create all required documents',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Project Description:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          StylusTextField(
            controller: _promptController,
            maxLines: 8,
            hintText: 'Describe your project idea in detail...',
            stylusHintText: 'Write your project description with S Pen...',
            decoration: InputDecoration(
              hintText: 'Describe your project idea in detail...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isGenerating
                ? null
                : () {
                    setState(() {
                      _isGenerating = true;
                    });
                    
                    // Show progress loader
                    showProgressDialog(context, message: 'Generating project documents...');
                    
                    // Use async-await to handle the async operation properly
                    Provider.of<DocumentState>(context, listen: false)
                        .initializeFromPrompt(_promptController.text)
                        .then((_) {
                      // Hide progress loader
                      hideProgressDialog(context);
                      
                      setState(() {
                        _isGenerating = false;
                      });
                    }).catchError((error) {
                      // Hide progress loader on error
                      hideProgressDialog(context);
                      
                      setState(() {
                        _isGenerating = false;
                      });
                      
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error generating documents: $error'))
                      );
                    });
                  },
            icon: _isGenerating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Documents'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 32),
          Divider(),
          SizedBox(height: 16),
          Text(
            'Or use a template:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildPresetPrompts(),
          
          // Show S Pen Notes button if supported
          if (isStylusAvailable) 
            Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: OutlinedButton.icon(
                icon: Icon(Icons.edit),
                label: Text('S Pen Notes'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SPenNotesScreen()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetPrompts() {
    return Column(
      children: _presetPrompts.map((preset) {
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () {
              _promptController.text = preset['prompt']!;
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          preset['prompt']!.length > 100
                              ? '${preset['prompt']!.substring(0, 100)}...'
                              : preset['prompt']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      _promptController.text = preset['prompt']!;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Add a custom prompt dialog
  void _showCustomPromptDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Template Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: promptController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && promptController.text.isNotEmpty) {
                setState(() {
                  _presetPrompts.add({
                    'title': titleController.text,
                    'prompt': promptController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid(DocumentState documentState) {
    final documentTypes = documentState.getAllDocumentTypes();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Document type mappings
    final typeToDisplayName = {
      'BRD': 'Business Requirements',
      'FRD': 'Functional Requirements',
      'NFR': 'Non-Functional Requirements',
      'TDD': 'Technical Design Document',
      'UI/UX': 'UI/UX Documentation',
      'API Docs': 'API Documentation',
      'Test Cases': 'Test Cases',
      'Deployment Guide': 'Deployment Guide',
      'User Manual': 'User Manual',
    };
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.red,
      Colors.deepPurple,
      Colors.green.shade800,
    ];
    
    final icons = [
      Icons.business,
      Icons.assignment,
      Icons.settings,
      Icons.code,
      Icons.brush,
      Icons.timeline,
      Icons.bug_report,
      Icons.rocket_launch,
      Icons.headset_mic,
      Icons.warning_amber,
      Icons.description,
      Icons.attach_money,
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generated Documents',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Long press any document to delete it',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              // Wrap buttons in a responsive layout
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.analytics, size: isSmallScreen ? 16 : 20),
                    label: Text('View Estimates'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProjectEstimatesScreen()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh, size: isSmallScreen ? 16 : 20),
                    label: Text('New Project'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2),
              crossAxisSpacing: isSmallScreen ? 12.0 : 16.0,
              mainAxisSpacing: isSmallScreen ? 12.0 : 16.0,
              childAspectRatio: isSmallScreen ? 0.85 : 1.0,
            ),
            itemCount: documentTypes.length,
            itemBuilder: (context, index) {
              final documentType = documentTypes[index];
              final color = colors[index % colors.length];
              final icon = icons[index % icons.length];
              
              return _buildDocumentCard(
                context,
                documentType,
                icon,
                color,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentScreen(
                      documentType: documentType,
                      displayName: typeToDisplayName[documentType] ?? documentType,
                    ),
                  ),
                ),
                () => _confirmDeleteDocument(documentState, documentType, typeToDisplayName[documentType] ?? documentType),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    VoidCallback onLongPress,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 36.0 : 48.0,
                color: Colors.white,
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Show confirmation dialog for document deletion
  void _confirmDeleteDocument(DocumentState documentState, String documentType, String displayName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Document'),
          ],
        ),
        content: Text('Are you sure you want to delete "$displayName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Call the document deletion method in the document state
              documentState.deleteDocument(documentType);
              
              // Close the dialog
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$displayName deleted successfully'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Undo functionality would need to be implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Undo is not implemented yet')),
                      );
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // New widget to display cumulative earnings dashboard
  Widget _buildCumulativeEarningsDashboard(DocumentState documentState) {
    if (_isLoadingEarnings) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Format currency values using the CurrencyConverter
    String formatCurrency(double value) {
      return CurrencyConverter.format(value, documentState.selectedCurrency);
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUMULATIVE EARNINGS DASHBOARD',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              if (_availableBoards.length > 1)
                DropdownButton<String>(
                  value: _selectedBoard,
                  items: _availableBoards.map((boardId) {
                    return DropdownMenuItem<String>(
                      value: boardId,
                      child: Text('Board: $boardId'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _loadBoardStatistics(value);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.45 : screenWidth * 0.3,
                child: _buildEarningsCard(
                  'Total Potential Earnings',
                  formatCurrency(_earningsData['totalRevenuePotential'] ?? 0.0),
                  Colors.blue.shade700,
                  Icons.trending_up,
                ),
              ),
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.45 : screenWidth * 0.3,
                child: _buildEarningsCard(
                  'Generated Revenue',
                  formatCurrency(_earningsData['totalRevenueGenerated'] ?? 0.0),
                  Colors.green.shade700,
                  Icons.attach_money,
                ),
              ),
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.45 : screenWidth * 0.3,
                child: _buildEarningsCard(
                  'Remaining Earnings',
                  formatCurrency(
                    (_earningsData['totalRevenuePotential'] ?? 0.0) - 
                    (_earningsData['totalRevenueGenerated'] ?? 0.0)
                  ),
                  Colors.purple.shade700,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.45 : screenWidth * 0.3,
                child: _buildEarningsCard(
                  'Completion',
                  '${(_earningsData['completionPercentage'] ?? 0.0).toStringAsFixed(1)}%',
                  Colors.amber.shade700,
                  Icons.pie_chart,
                ),
              ),
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.45 : screenWidth * 0.3,
                child: _buildEarningsCard(
                  'Efficiency',
                  '${(_earningsData['overallEfficiency'] ?? 0.0).toStringAsFixed(1)}%',
                  Colors.teal.shade700,
                  Icons.speed,
                ),
              ),
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.45 : screenWidth * 0.3,
                child: _buildEarningsCard(
                  'Tasks',
                  '${(_earningsData['taskCounts'] != null ? 
                    (_earningsData['taskCounts']['total'] ?? 0) : 0)}',
                  Colors.red.shade700,
                  Icons.assignment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper widget for earnings cards
  Widget _buildEarningsCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 