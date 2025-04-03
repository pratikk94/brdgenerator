import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class ResourcesValidator extends StatefulWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const ResourcesValidator({
    Key? key,
    required this.component,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ResourcesValidatorState createState() => _ResourcesValidatorState();
}

class _ResourcesValidatorState extends State<ResourcesValidator> {
  BRDValidationResult? _validationResult;
  bool _isValidating = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildValidationHeader(),
            const SizedBox(height: 16),
            
            _buildValidationCriteria(),
            const SizedBox(height: 24),
            
            if (_validationResult != null)
              ValidationResultWidget(
                result: _validationResult,
                onRetry: _validate,
              ),
              
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isValidating ? null : _validate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isValidating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('VALIDATE RESOURCES'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources Validation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure you have identified all the resources required for successful project implementation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildValidationCriteria() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Elements:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildCriteriaItem('Human Resources', 'Roles, responsibilities, and team structure'),
          _buildCriteriaItem('Technology Resources', 'Hardware, software, and infrastructure needs'),
          _buildCriteriaItem('Financial Resources', 'Budget estimates for different aspects of the project'),
          _buildCriteriaItem('Third-Party Resources', 'External vendors, partners, or services required'),
          _buildCriteriaItem('Resource Allocation', 'How resources will be distributed across project phases'),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Colors.deepPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validate() async {
    setState(() {
      _isValidating = true;
    });

    // Simulate network delay for validation
    await Future.delayed(const Duration(milliseconds: 800));

    final result = _validateResources();

    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
  }

  BRDValidationResult _validateResources() {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (widget.content['human_resources']?.isEmpty ?? true) {
      missingFields.add('Human Resources');
    } else if (!_containsListItems(widget.content['human_resources'] ?? '')) {
      improvementSuggestions.add('Human resources should be clearly listed with roles and responsibilities.');
    }
    
    if (widget.content['technology_resources']?.isEmpty ?? true) {
      missingFields.add('Technology Resources');
    }
    
    if (widget.content['financial_resources']?.isEmpty ?? true) {
      missingFields.add('Financial Resources');
    } else if (!(widget.content['financial_resources'] ?? '').contains(RegExp(r'[0-9]'))) {
      improvementSuggestions.add('Financial resources should include budget estimates with numbers.');
    }
    
    if (widget.content['third_party']?.isEmpty ?? true) {
      improvementSuggestions.add('Consider identifying any third-party resources required for the project.');
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Resource requirements are well-defined and comprehensive.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Resource requirements are missing key information.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Resource requirements can be improved for clarity and completeness.',
        improvementSuggestions,
      );
    }
  }

  bool _containsListItems(String text) {
    // Check if text has list items (bullet points, numbers, or dashes)
    return text.contains(RegExp(r'[\n•\-*]')) || text.contains(RegExp(r'\n\d+\.'));
  }
} 