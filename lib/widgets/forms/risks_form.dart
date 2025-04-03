import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class RisksForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const RisksForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _RisksFormState createState() => _RisksFormState();
}

class _RisksFormState extends State<RisksForm> {
  final _risksController = TextEditingController();
  final _impactController = TextEditingController();
  final _mitigationController = TextEditingController();
  final _contingencyController = TextEditingController();
  
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    try {
      if (widget.component.content.isNotEmpty) {
        // Parse the content string into a Map
        try {
          _formData = Map<String, dynamic>.from(
            widget.component.content.startsWith('{') 
              ? Map<String, dynamic>.from(
                  jsonDecode(widget.component.content) as Map<String, dynamic>
                )
              : {'rawContent': widget.component.content}
          );
        } catch (e) {
          _formData = {'rawContent': widget.component.content};
        }
      }
    } catch (e) {
      _formData = {};
    }

    _risksController.text = _formData['risks'] ?? '';
    _impactController.text = _formData['impact'] ?? '';
    _mitigationController.text = _formData['mitigation'] ?? '';
    _contingencyController.text = _formData['contingency'] ?? '';
  }

  void _updateFormData() {
    final data = {
      'risks': _risksController.text,
      'impact': _impactController.text,
      'mitigation': _mitigationController.text,
      'contingency': _contingencyController.text,
    };
    
    widget.onUpdate(data);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Risk Analysis and Mitigation'),
            const SizedBox(height: 16),
            
            _buildFormField(
              label: 'Risk Identification',
              controller: _risksController,
              required: true,
              hintText: 'List all potential risks that could impact the project',
              maxLines: 5,
              helperText: 'Be specific about different types of risks (technical, business, schedule)',
            ),
            
            _buildFormField(
              label: 'Risk Impact Assessment',
              controller: _impactController,
              required: true,
              hintText: 'Evaluate the potential impact of each risk (High/Medium/Low)',
              maxLines: 5,
              helperText: 'Include probability and severity for each risk',
            ),
            
            _buildFormField(
              label: 'Mitigation Strategies',
              controller: _mitigationController,
              required: true,
              hintText: 'Describe how each risk will be mitigated or prevented',
              maxLines: 4,
            ),
            
            _buildFormField(
              label: 'Contingency Plans',
              controller: _contingencyController,
              hintText: 'What will be done if the risk occurs despite mitigation',
              maxLines: 3,
            ),
            
            _buildRiskMatrix(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMatrix() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sample Risk Assessment Format:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Risk 1: [Description]\n'
            '- Probability: High/Medium/Low\n'
            '- Impact: High/Medium/Low\n'
            '- Mitigation: [Strategy to prevent or reduce likelihood]\n'
            '- Contingency: [Action if risk occurs]\n\n'
            'Risk 2: [Description]\n'
            '- Probability: High/Medium/Low\n'
            '- Impact: High/Medium/Low\n'
            '- Mitigation: [Strategy to prevent or reduce likelihood]\n'
            '- Contingency: [Action if risk occurs]',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    String? hintText,
    String? helperText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (helperText != null) 
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                helperText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            maxLines: maxLines,
            onChanged: (_) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _risksController.dispose();
    _impactController.dispose();
    _mitigationController.dispose();
    _contingencyController.dispose();
    super.dispose();
  }
} 