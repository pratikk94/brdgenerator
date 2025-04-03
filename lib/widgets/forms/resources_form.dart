import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class ResourcesForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const ResourcesForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ResourcesFormState createState() => _ResourcesFormState();
}

class _ResourcesFormState extends State<ResourcesForm> {
  final _stakeholdersController = TextEditingController();
  final _rolesController = TextEditingController();
  final _internalController = TextEditingController();
  final _externalController = TextEditingController();
  
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
        
        // Load stakeholders data from various possible fields
        if (data.containsKey('stakeholders')) {
          if (data['stakeholders'] is List) {
            _stakeholdersController.text = (data['stakeholders'] as List).join('\n\n');
          } else {
            _stakeholdersController.text = data['stakeholders'] as String? ?? '';
          }
        }
        
        _rolesController.text = data['roles'] as String? ?? '';
        _internalController.text = data['internal'] as String? ?? '';
        _externalController.text = data['external'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading stakeholders data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'stakeholders': _stakeholdersController.text,
      'roles': _rolesController.text,
      'internal': _internalController.text,
      'external': _externalController.text,
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
          const Text('Stakeholders', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List key stakeholders for the project',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _stakeholdersController,
            decoration: const InputDecoration(
              hintText: 'Enter key stakeholders (one per line)',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Roles & Responsibilities', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _rolesController,
            decoration: const InputDecoration(
              hintText: 'Describe stakeholder roles and responsibilities',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Internal Stakeholders', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _internalController,
            decoration: const InputDecoration(
              hintText: 'List internal stakeholders and their interests',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('External Stakeholders', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _externalController,
            decoration: const InputDecoration(
              hintText: 'List external stakeholders and their interests',
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
    _stakeholdersController.dispose();
    _rolesController.dispose();
    _internalController.dispose();
    _externalController.dispose();
    super.dispose();
  }
} 