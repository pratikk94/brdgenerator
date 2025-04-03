import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class TimelineForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const TimelineForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _TimelineFormState createState() => _TimelineFormState();
}

class _TimelineFormState extends State<TimelineForm> {
  final _phasesController = TextEditingController();
  final _milestonesController = TextEditingController();
  final _deliverablesController = TextEditingController();
  
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
        
        _phasesController.text = data['phases'] as String? ?? '';
        _milestonesController.text = data['milestones'] as String? ?? '';
        _deliverablesController.text = data['deliverables'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading timeline data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'phases': _phasesController.text,
      'milestones': _milestonesController.text,
      'deliverables': _deliverablesController.text,
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
          const Text('Project Phases', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Describe major phases of the project with dates',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phasesController,
            decoration: const InputDecoration(
              hintText: 'Enter project phases with dates',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Key Milestones', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _milestonesController,
            decoration: const InputDecoration(
              hintText: 'List key milestones with target dates',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Deliverables', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _deliverablesController,
            decoration: const InputDecoration(
              hintText: 'List deliverables for each phase',
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
    _phasesController.dispose();
    _milestonesController.dispose();
    _deliverablesController.dispose();
    super.dispose();
  }
} 