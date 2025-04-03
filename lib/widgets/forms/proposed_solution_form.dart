import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class ProposedSolutionForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const ProposedSolutionForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProposedSolutionFormState createState() => _ProposedSolutionFormState();
}

class _ProposedSolutionFormState extends State<ProposedSolutionForm> {
  final _featuresController = TextEditingController();
  final _userStoriesController = TextEditingController();
  final _acceptanceCriteriaController = TextEditingController();
  
  bool _isLoading = true;
  String _aiGeneratedContent = '';

  @override
  void initState() {
    super.initState();
    _loadComponentData();
  }

  void _loadComponentData() {
    setState(() => _isLoading = true);
    
    try {
      if (widget.component.content.isNotEmpty) {
        final data = jsonDecode(widget.component.content) as Map<String, dynamic>;
        
        if (data.containsKey('features')) {
          if (data['features'] is List) {
            _featuresController.text = (data['features'] as List).join('\n\n');
          } else {
            _featuresController.text = data['features'] as String? ?? '';
          }
        }
        
        if (data.containsKey('user_stories')) {
          if (data['user_stories'] is List) {
            _userStoriesController.text = (data['user_stories'] as List).join('\n\n');
          } else {
            _userStoriesController.text = data['user_stories'] as String? ?? '';
          }
        }
        
        if (data.containsKey('acceptance_criteria')) {
          if (data['acceptance_criteria'] is List) {
            _acceptanceCriteriaController.text = (data['acceptance_criteria'] as List).join('\n\n');
          } else {
            _acceptanceCriteriaController.text = data['acceptance_criteria'] as String? ?? '';
          }
        }
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading functional requirements data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'features': _featuresController.text,
      'user_stories': _userStoriesController.text,
      'acceptance_criteria': _acceptanceCriteriaController.text,
      'aiContent': _aiGeneratedContent,
    };
    
    widget.onUpdate(data);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Content Preview (if available)
          if (_aiGeneratedContent.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'AI-Generated Content',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_aiGeneratedContent),
                  ],
                ),
              ),
            ),
          ],
          
          // Form Fields
          const Text('Feature Descriptions', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _featuresController,
            decoration: const InputDecoration(
              hintText: 'Describe the key features required',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('User Stories', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Format: As a [role], I want [feature] so that [benefit]',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _userStoriesController,
            decoration: const InputDecoration(
              hintText: 'Enter user stories',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Acceptance Criteria', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _acceptanceCriteriaController,
            decoration: const InputDecoration(
              hintText: 'Define when each feature is considered complete',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _featuresController.dispose();
    _userStoriesController.dispose();
    _acceptanceCriteriaController.dispose();
    super.dispose();
  }
} 