import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class ProblemStatementForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const ProblemStatementForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProblemStatementFormState createState() => _ProblemStatementFormState();
}

class _ProblemStatementFormState extends State<ProblemStatementForm> {
  final _goalsController = TextEditingController();
  final _kpisController = TextEditingController();
  final _successCriteriaController = TextEditingController();
  
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
        
        _goalsController.text = data['goals'] as String? ?? '';
        _kpisController.text = data['kpis'] as String? ?? '';
        _successCriteriaController.text = data['success_criteria'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading business objectives data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'goals': _goalsController.text,
      'kpis': _kpisController.text,
      'success_criteria': _successCriteriaController.text,
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
          const Text('Business Goals (SMART Format)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List objectives that are Specific, Measurable, Achievable, Relevant, and Time-bound',
               style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _goalsController,
            decoration: const InputDecoration(
              hintText: 'Enter your business objectives',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Key Performance Indicators (KPIs)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _kpisController,
            decoration: const InputDecoration(
              hintText: 'List measurable KPIs for each objective',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Success Criteria', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _successCriteriaController,
            decoration: const InputDecoration(
              hintText: 'Define how success will be measured',
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
    _goalsController.dispose();
    _kpisController.dispose();
    _successCriteriaController.dispose();
    super.dispose();
  }
} 