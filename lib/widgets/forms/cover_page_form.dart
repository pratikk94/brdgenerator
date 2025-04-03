import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import 'dart:convert';

class CoverPageForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const CoverPageForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CoverPageFormState createState() => _CoverPageFormState();
}

class _CoverPageFormState extends State<CoverPageForm> {
  final _projectNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _versionController = TextEditingController();
  final _dateController = TextEditingController();
  final _preparedByController = TextEditingController();
  final _approvedByController = TextEditingController();
  final _projectIdController = TextEditingController();
  
  Map<String, dynamic> _formData = {};
  bool _isLoading = false;
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
        
        _projectNameController.text = data['projectName'] as String? ?? '';
        _companyNameController.text = data['companyName'] as String? ?? '';
        _versionController.text = data['version'] as String? ?? '1.0';
        _dateController.text = data['date'] as String? ?? DateTime.now().toString().split(' ')[0];
        _preparedByController.text = data['preparedBy'] as String? ?? '';
        _projectIdController.text = data['projectId'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading cover page data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    _formData = {
      'projectName': _projectNameController.text,
      'companyName': _companyNameController.text,
      'version': _versionController.text,
      'date': _dateController.text,
      'preparedBy': _preparedByController.text,
      'projectId': _projectIdController.text,
      'aiContent': _aiGeneratedContent,
    };
    widget.onUpdate(_formData);
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
          TextFormField(
            controller: _projectNameController,
            decoration: const InputDecoration(
              labelText: 'Project Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _versionController,
            decoration: const InputDecoration(
              labelText: 'Version',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onChanged: (_) => _updateFormData(),
            onTap: () async {
              // Show date picker here
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                _dateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                _updateFormData();
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _preparedByController,
            decoration: const InputDecoration(
              labelText: 'Prepared By',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _projectIdController,
            decoration: const InputDecoration(
              labelText: 'Project ID (Optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _companyNameController.dispose();
    _versionController.dispose();
    _dateController.dispose();
    _preparedByController.dispose();
    _approvedByController.dispose();
    _projectIdController.dispose();
    super.dispose();
  }
} 