import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class FunctionalRequirementsForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const FunctionalRequirementsForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _FunctionalRequirementsFormState createState() => _FunctionalRequirementsFormState();
}

class _FunctionalRequirementsFormState extends State<FunctionalRequirementsForm> {
  final _performanceController = TextEditingController();
  final _securityController = TextEditingController();
  final _usabilityController = TextEditingController();
  final _scalabilityController = TextEditingController();
  final _reliabilityController = TextEditingController();
  
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
        
        _performanceController.text = data['performance'] as String? ?? '';
        _securityController.text = data['security'] as String? ?? '';
        _usabilityController.text = data['usability'] as String? ?? '';
        _scalabilityController.text = data['scalability'] as String? ?? '';
        _reliabilityController.text = data['reliability'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading non-functional requirements data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'performance': _performanceController.text,
      'security': _securityController.text,
      'usability': _usabilityController.text,
      'scalability': _scalabilityController.text,
      'reliability': _reliabilityController.text,
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
          const Text('Performance Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Specify response times, throughput, and other performance metrics',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _performanceController,
            decoration: const InputDecoration(
              hintText: 'Enter performance requirements',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Security Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _securityController,
            decoration: const InputDecoration(
              hintText: 'Specify security requirements and compliance needs',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Usability Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _usabilityController,
            decoration: const InputDecoration(
              hintText: 'Specify user experience and accessibility requirements',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Scalability Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _scalabilityController,
            decoration: const InputDecoration(
              hintText: 'Define how the system should scale with increased load or users',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Reliability Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reliabilityController,
            decoration: const InputDecoration(
              hintText: 'Specify uptime, recovery time, and backup requirements',
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
    _performanceController.dispose();
    _securityController.dispose();
    _usabilityController.dispose();
    _scalabilityController.dispose();
    _reliabilityController.dispose();
    super.dispose();
  }
} 