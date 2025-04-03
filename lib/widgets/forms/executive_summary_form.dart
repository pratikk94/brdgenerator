import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class ExecutiveSummaryForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const ExecutiveSummaryForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ExecutiveSummaryFormState createState() => _ExecutiveSummaryFormState();
}

class _ExecutiveSummaryFormState extends State<ExecutiveSummaryForm> {
  final _businessContextController = TextEditingController();
  final _problemStatementController = TextEditingController();
  final _proposedSolutionController = TextEditingController();
  final _benefitsController = TextEditingController();
  
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
        
        _businessContextController.text = data['businessContext'] as String? ?? '';
        _problemStatementController.text = data['problemStatement'] as String? ?? '';
        _proposedSolutionController.text = data['proposedSolution'] as String? ?? '';
        _benefitsController.text = data['benefits'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading executive summary data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'businessContext': _businessContextController.text,
      'problemStatement': _problemStatementController.text,
      'proposedSolution': _proposedSolutionController.text,
      'benefits': _benefitsController.text,
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
          const Text('Business Context', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _businessContextController,
            decoration: const InputDecoration(
              hintText: 'Describe the business background or context',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Problem Statement', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _problemStatementController,
            decoration: const InputDecoration(
              hintText: 'Describe the problem or need',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Proposed Solution', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _proposedSolutionController,
            decoration: const InputDecoration(
              hintText: 'Describe the proposed solution or opportunity',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Benefits', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _benefitsController,
            decoration: const InputDecoration(
              hintText: 'Describe the expected benefits or document objective',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _businessContextController.dispose();
    _problemStatementController.dispose();
    _proposedSolutionController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }
} 