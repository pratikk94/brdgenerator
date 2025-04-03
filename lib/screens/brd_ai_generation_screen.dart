import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/brd_service.dart';
import '../services/openai_service.dart';
import 'brd_editor_screen.dart';

class BRDAIGenerationScreen extends StatefulWidget {
  const BRDAIGenerationScreen({Key? key}) : super(key: key);

  @override
  _BRDAIGenerationScreenState createState() => _BRDAIGenerationScreenState();
}

class _BRDAIGenerationScreenState extends State<BRDAIGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  bool _isGenerating = false;
  String? _error;
  double _generationProgress = 0.0;
  List<String> _generatedComponents = [];
  bool _allComponentsGenerated = false;
  String? _brdId;

  final OpenAIService _openAIService = OpenAIService();

  @override
  void dispose() {
    _projectNameController.dispose();
    _companyNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateBRD() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final brdService = Provider.of<BRDService>(context, listen: false);
    
    setState(() {
      _isGenerating = true;
      _error = null;
      _generationProgress = 0.0;
      _generatedComponents = [];
      _allComponentsGenerated = false;
    });

    try {
      // Step 1: Create a new BRD
      final brdId = await brdService.createNewBRD();
      _brdId = brdId;
      
      // Define the components to generate
      final componentsList = [
        {'id': 'cover', 'title': 'Cover Page'},
        {'id': 'executive', 'title': 'Executive Summary'},
        {'id': 'problem', 'title': 'Business Objectives'},
        {'id': 'proposed', 'title': 'Functional Requirements'},
        {'id': 'scope', 'title': 'Project Scope'},
        {'id': 'requirements', 'title': 'Non-Functional Requirements'},
        {'id': 'constraints', 'title': 'Assumptions & Constraints'},
        {'id': 'timeline', 'title': 'Timeline & Milestones'},
        {'id': 'resources', 'title': 'Stakeholder Analysis'},
        {'id': 'risks', 'title': 'Risk Analysis'},
        {'id': 'glossary', 'title': 'Glossary / Appendix'},
        {'id': 'signoff', 'title': 'Sign-Off'},
      ];
      
      // Step 2: Generate content for each component
      for (int i = 0; i < componentsList.length; i++) {
        final component = componentsList[i];
        
        try {
          // Prepare prompt based on component type
          final prompt = _buildPromptForComponent(
            component['id']!,
            _projectNameController.text,
            _companyNameController.text,
            _projectDescriptionController.text
          );
          
          // Generate content using OpenAI
          final content = await _openAIService.generateComponentContent(prompt);
          
          // Parse the content based on component type
          Map<String, dynamic> contentMap = _parseContentForComponent(component['id']!, content);
          
          // Ensure the content is formatted as needed for form fields
          print("Generated content for ${component['title']}: ${contentMap.keys}");
          
          // Update the component in the database
          await brdService.updateComponentDirect(
            brdId,
            component['id']!,
            component['title']!,
            jsonEncode(contentMap),
            i == 0  // Only mark cover page as completed initially
          );
          
          setState(() {
            _generatedComponents.add(component['title']!);
            _generationProgress = (i + 1) / componentsList.length;
          });
          
          // Add a small delay to ensure server updates
          await Future.delayed(const Duration(milliseconds: 500));
          
        } catch (e) {
          // If a specific component fails, continue with others
          print('Error generating ${component['title']}: $e');
        }
      }
      
      setState(() {
        _allComponentsGenerated = true;
      });

    } catch (e) {
      setState(() {
        _error = 'Error generating BRD: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  String _buildPromptForComponent(String componentId, String projectName, String companyName, String description) {
    // These prompts are ONLY for AI content generation, not for validation
    switch (componentId) {
      case 'cover':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Cover Page & Metadata section of a Business Requirement Document. Your output must include:
- Project Name
- Company Name
- Document Version (e.g., 1.0)
- Date (today's or a specified date)
- Prepared By (Name and Role)
- Project ID (optional but preferred)

Return your answer in a structured Markdown format.

Login Prompt:
$description''';
      
      case 'executive':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Executive Summary section of a Business Requirement Document. Your output must include:
- Business background or context
- Problem or need
- Opportunity
- Objective of the document

Return your answer in a structured Markdown format.

Login Prompt:
$description''';
      
      case 'problem':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Business Objectives section of a Business Requirement Document. Your output must include at least three business objectives written in SMART format (Specific, Measurable, Achievable, Relevant, Time-bound). Also include relevant Key Performance Indicators (KPIs) for each objective.

Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'proposed':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Functional Requirements section of a Business Requirement Document. Your output must include detailed functional requirements. For each requirement, include:
- Feature Name
- Description of the feature
- Involved Role(s)
- Acceptance Criteria
- Any Dependencies

Provide at least three functional requirements. Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'scope':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Scope section of a Business Requirement Document. Your output must include:
- In-Scope items (features and functionalities included in the project)
- Out-of-Scope items (what is intentionally excluded)
- Optional: Future scope or Phase 2 items
- Any scope assumptions if applicable

Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'requirements':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Non-Functional Requirements section of a Business Requirement Document. Your output must include at least three categories (e.g., Performance, Usability, Availability, Maintainability, Security) with measurable expectations for each.

Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'constraints':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Assumptions & Constraints section of a Business Requirement Document. Your output must include:
- Technical assumptions (e.g., "Assumes use of Firebase for backend")
- Business assumptions (e.g., "Users will have continuous internet access")
- Constraints (e.g., budget, legal, technology limits, timeline)

Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'timeline':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Timeline & Milestones section of a Business Requirement Document. Your output must include:
- At least three defined phases or milestones
- For each phase, include the start date, end date, and key deliverables
- (Optional) A brief description of a timeline diagram

Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'resources':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Stakeholder Analysis section of a Business Requirement Document. Your output must list the key stakeholders including:
- Stakeholder Name or Designation
- Their Role/Interest in the project
- Whether they are internal or external

Return your answer in structured Markdown format.

Login Prompt:
$description''';
      
      case 'risks':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Risk Analysis section of a Business Requirement Document. Your output must include at least three risks. For each risk, include:
- Risk Description
- Severity (High/Med/Low)
- Likelihood
- Mitigation Plan

Return your answer in structured Markdown format.

Login Prompt:
$description''';

      case 'glossary':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Glossary / Appendix section of a Business Requirement Document. Your output must define key technical or business terms used in the document. Arrange the terms alphabetically if possible.

Return your answer in structured Markdown format.

Login Prompt:
$description''';
        
      case 'signoff':
        return '''You are a senior business analyst. Based on the following brief project description provided at login, autofill the Sign-Off section of a Business Requirement Document. Your output must include:
- Stakeholder Name
- Role
- Sign-Off Date
- (Optional) Digital Signature or Approval ID

Return your answer in structured Markdown format.

Login Prompt:
$description''';

      default:
        return 'Generate content for $componentId based on this project: $description';
    }
  }

  Map<String, dynamic> _parseContentForComponent(String componentId, String content) {
    // Try to extract JSON from the content if possible
    try {
      // Check if the content is already valid JSON
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      // Not JSON, parse differently based on component type
      switch (componentId) {
        case 'cover':
          Map<String, dynamic> coverData = {};
          
          // Try to extract key data points
          final lines = content.split('\n');
          for (var line in lines) {
            if (line.contains('Project Name:') || line.contains('Project Name -')) {
              coverData['projectName'] = _extractValue(line);
            } else if (line.contains('Company Name:') || line.contains('Company Name -')) {
              coverData['companyName'] = _extractValue(line);
            } else if (line.contains('Version:') || line.contains('Document Version:')) {
              coverData['version'] = _extractValue(line);
            } else if (line.contains('Date:') || line.contains('Prepared on:')) {
              coverData['date'] = _extractValue(line);
            } else if (line.contains('Prepared By:') || line.contains('Author:')) {
              coverData['preparedBy'] = _extractValue(line);
            } else if (line.contains('Project ID:') || line.contains('ID:')) {
              coverData['projectId'] = _extractValue(line);
            }
          }
          
          // If we couldn't find the data, use defaults
          coverData['projectName'] = coverData['projectName'] ?? _projectNameController.text;
          coverData['companyName'] = coverData['companyName'] ?? _companyNameController.text;
          coverData['version'] = coverData['version'] ?? '1.0';
          coverData['date'] = coverData['date'] ?? DateTime.now().toString().split(' ')[0];
          coverData['preparedBy'] = coverData['preparedBy'] ?? 'AI Assistant';
          
          // Store the full content for reference
          coverData['aiContent'] = content;
          
          return coverData;
          
        case 'executive':
          final Map<String, dynamic> executiveData = {
            'businessContext': _extractSectionContent(content, 'Business background', 'Problem'),
            'problemStatement': _extractSectionContent(content, 'Problem', 'Opportunity'),
            'proposedSolution': _extractSectionContent(content, 'Opportunity', 'Objective'),
            'benefits': _extractSectionContent(content, 'Objective', null),
            'aiContent': content,
          };
          
          // If we couldn't extract sections, try a simpler approach
          if (executiveData['businessContext'].isEmpty && 
              executiveData['problemStatement'].isEmpty &&
              executiveData['proposedSolution'].isEmpty) {
            final paragraphs = content.split('\n\n');
            if (paragraphs.length >= 1) executiveData['businessContext'] = paragraphs[0];
            if (paragraphs.length >= 2) executiveData['problemStatement'] = paragraphs[1];
            if (paragraphs.length >= 3) executiveData['proposedSolution'] = paragraphs[2];
            if (paragraphs.length >= 4) executiveData['benefits'] = paragraphs[3];
          }
          
          return executiveData;
          
        case 'problem':
          return {
            'goals': _extractSectionContent(content, 'Business Objectives', 'KPI'),
            'kpis': _extractSectionContent(content, 'KPI', 'Success Criteria'),
            'success_criteria': _extractSectionContent(content, 'Success Criteria', null),
            'aiContent': content,
          };
          
        case 'proposed':
          return {
            'features': _extractListItems(content, 'Feature'),
            'user_stories': _extractListItems(content, 'User Stor'),
            'acceptance_criteria': _extractListItems(content, 'Acceptance Criteria'),
            'aiContent': content,
          };
          
        case 'scope':
          return {
            'in_scope': _extractSectionContent(content, 'In-Scope', 'Out-of-Scope'),
            'out_scope': _extractSectionContent(content, 'Out-of-Scope', 'Future scope'),
            'future_scope': _extractSectionContent(content, 'Future scope', 'Assumptions'),
            'aiContent': content,
          };
          
        case 'requirements':
          // Extract the non-functional requirements categories
          final Map<String, dynamic> reqData = {};
          final categories = ['Performance', 'Usability', 'Availability', 'Maintainability', 'Security', 'Scalability', 'Reliability'];
          
          for (int i = 0; i < categories.length; i++) {
            final category = categories[i];
            final nextCategory = i < categories.length - 1 ? categories[i + 1] : null;
            reqData[category.toLowerCase()] = _extractSectionContent(content, category, nextCategory);
          }
          
          reqData['aiContent'] = content;
          return reqData;
          
        case 'constraints':
          return {
            'assumptions': _extractSectionContent(content, 'Assumptions', 'Constraints'),
            'constraints': _extractSectionContent(content, 'Constraints', null),
            'aiContent': content,
          };
          
        case 'timeline':
          return {
            'phases': _extractSectionContent(content, 'Project Phases', 'Milestones'),
            'milestones': _extractSectionContent(content, 'Milestones', 'Deliverables'),
            'deliverables': _extractSectionContent(content, 'Deliverables', null),
            'aiContent': content,
          };
          
        case 'resources':
          return {
            'stakeholders': _extractListItems(content, 'Stakeholder'),
            'roles': _extractSectionContent(content, 'Role', 'Internal'),
            'internal': _extractListItems(content, 'Internal'),
            'external': _extractListItems(content, 'External'),
            'aiContent': content,
          };
          
        case 'risks':
          return {
            'risks': _extractListItems(content, 'Risk Description'),
            'impact': _extractSectionContent(content, 'Severity', 'Likelihood'),
            'mitigation': _extractSectionContent(content, 'Mitigation Plan', null),
            'aiContent': content,
          };
          
        case 'glossary':
          // The glossary formatter in the form will parse the content
          return {
            'terms': content,
            'aiContent': content,
          };
          
        case 'signoff':
          // The sign-off formatter in the form will parse the content
          return {
            'approvers': content,
            'aiContent': content,
          };
          
        default:
          // For any unhandled component, store the content as-is
          return {'content': content, 'aiContent': content};
      }
    }
  }
  
  String _extractValue(String line) {
    if (line.contains(':')) {
      final parts = line.split(':');
      return parts.sublist(1).join(':').trim();
    } else if (line.contains('-')) {
      final parts = line.split('-');
      return parts.sublist(1).join('-').trim();
    } else if (line.contains('|')) {
      final parts = line.split('|');
      return parts.sublist(1).join('|').trim();
    }
    return '';
  }
  
  String _extractSectionContent(String content, String sectionName, String? nextSectionName) {
    try {
      // Try to find the start of the section - allow for variations in headers
      int startIndex = -1;
      
      // Try different formats like h1, h2, h3, bold, etc.
      final possibleStartPatterns = [
        '# $sectionName', '## $sectionName', '### $sectionName',
        '**$sectionName**', '*$sectionName*', '$sectionName:', '$sectionName -'
      ];
      
      for (final pattern in possibleStartPatterns) {
        int index = content.indexOf(pattern);
        if (index != -1) {
          startIndex = index + pattern.length;
          break;
        }
      }
      
      // Case insensitive as a fallback
      if (startIndex == -1) {
        final regExp = RegExp(sectionName, caseSensitive: false);
        final match = regExp.firstMatch(content);
        if (match != null) {
          startIndex = match.end;
        }
      }
      
      if (startIndex == -1) {
        return '';
      }
      
      // Skip any special characters after the section name
      while (startIndex < content.length && 
             (content[startIndex] == ':' || 
              content[startIndex] == ' ' || 
              content[startIndex] == '\n' ||
              content[startIndex] == '-' ||
              content[startIndex] == '*' ||
              content[startIndex] == '#')) {
        startIndex++;
      }
      
      // Find the end of the section (next section or end of content)
      int endIndex = content.length;
      
      if (nextSectionName != null) {
        final possibleEndPatterns = [
          '# $nextSectionName', '## $nextSectionName', '### $nextSectionName',
          '**$nextSectionName**', '*$nextSectionName*', '$nextSectionName:', '$nextSectionName -'
        ];
        
        for (final pattern in possibleEndPatterns) {
          int index = content.indexOf(pattern, startIndex);
          if (index != -1 && index < endIndex) {
            endIndex = index;
            break;
          }
        }
        
        // Case insensitive as a fallback
        if (endIndex == content.length) {
          final regExp = RegExp(nextSectionName, caseSensitive: false);
          for (final match in regExp.allMatches(content.substring(startIndex))) {
            // Check if it's a heading or new section, not part of the text
            final charBefore = match.start > 0 ? content[startIndex + match.start - 1] : ' ';
            if (charBefore == '\n' || charBefore == ' ' || charBefore == '#') {
              endIndex = startIndex + match.start;
              break;
            }
          }
        }
      }
      
      if (startIndex < endIndex) {
        return content.substring(startIndex, endIndex).trim();
      }
      
      return '';
    } catch (e) {
      print('Error extracting section $sectionName: $e');
      return '';
    }
  }
  
  List<String> _extractListItems(String content, String marker) {
    List<String> items = [];
    
    try {
      final section = _extractSectionContent(content, marker, null);
      if (section.isEmpty) return items;
      
      // Try to find bulleted lists
      final lines = section.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.startsWith('-') || line.startsWith('*') || line.startsWith('•') || 
            RegExp(r'^\d+\.').hasMatch(line)) {
          items.add(line.replaceFirst(RegExp(r'^[-*•\d+\.]\s*'), '').trim());
        } else if (line.isNotEmpty && !line.contains(':') && !line.contains('#')) {
          // If the content doesn't have bullet points, just add non-empty lines
          items.add(line);
        }
      }
      
      if (items.isEmpty && section.isNotEmpty) {
        // If we still couldn't extract list items, just add the whole section
        items.add(section);
      }
    } catch (e) {
      print('Error extracting list items with marker $marker: $e');
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Powered BRD Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Your Complete BRD',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Provide a detailed description of your project, and our AI will generate all BRD components for you to review.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Project Information Form
              if (_brdId == null || !_allComponentsGenerated) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _projectNameController,
                          decoration: const InputDecoration(
                            labelText: 'Project Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter project name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Company Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          'Project Description',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Provide a detailed description of your project, including the business context, problem to solve, target users, and desired outcomes.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        
                        TextFormField(
                          controller: _projectDescriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your project description here...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a project description';
                            }
                            if (value.length < 100) {
                              return 'Please provide a more detailed description (at least 100 characters)';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red.shade100,
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                          
                        const SizedBox(height: 16),
                        
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _isGenerating ? null : _generateBRD,
                            icon: _isGenerating 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                            label: Text(_isGenerating ? 'Generating...' : 'Generate BRD'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Progress indicator
              if (_isGenerating) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generating Your BRD',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _generationProgress,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Generated ${_generatedComponents.length} of 12 components',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_generatedComponents.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          ...List.generate(
                            _generatedComponents.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(_generatedComponents[index]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              
              // Generation complete UI
              if (_brdId != null && _allComponentsGenerated) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BRD Generation Complete!',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All components have been generated successfully. The Cover Page is ready for your review. You must validate each section before proceeding to the next one.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BRDEditorScreen(brdId: _brdId!),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_document),
                          label: const Text('Review & Edit BRD'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension OpenAIServiceExtension on OpenAIService {
  Future<String> generateComponentContent(String prompt) async {
    // This method is a placeholder that will be implemented to generate content
    // based on the prompt using the OpenAI service
    
    // For now, we'll simulate the API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    
    // This would be replaced with actual API call to OpenAI
    return "Generated content based on the prompt: $prompt";
  }
} 