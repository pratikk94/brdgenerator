import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class AssumptionsConstraintsForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const AssumptionsConstraintsForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _AssumptionsConstraintsFormState createState() => _AssumptionsConstraintsFormState();
}

class _AssumptionsConstraintsFormState extends State<AssumptionsConstraintsForm> {
  final _assumptionsController = TextEditingController();
  final _constraintsController = TextEditingController();
  
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
        
        _assumptionsController.text = data['assumptions'] as String? ?? '';
        _constraintsController.text = data['constraints'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading assumptions and constraints data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'assumptions': _assumptionsController.text,
      'constraints': _constraintsController.text,
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
          const Text('Assumptions', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List all assumptions that the project is making',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _assumptionsController,
            decoration: const InputDecoration(
              hintText: 'Enter business and technical assumptions (one per line)',
              border: OutlineInputBorder(),
            ),
            maxLines: 8,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Constraints', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List all constraints affecting the project (budget, time, technology, etc.)',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _constraintsController,
            decoration: const InputDecoration(
              hintText: 'Enter constraints (one per line)',
              border: OutlineInputBorder(),
            ),
            maxLines: 8,
            onChanged: (_) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _assumptionsController.dispose();
    _constraintsController.dispose();
    super.dispose();
  }
} 