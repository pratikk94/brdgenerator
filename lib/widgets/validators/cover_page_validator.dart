import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import '../validators/validation_result_widget.dart';

class CoverPageValidator extends StatefulWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const CoverPageValidator({
    Key? key,
    required this.component,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CoverPageValidatorState createState() => _CoverPageValidatorState();
}

class _CoverPageValidatorState extends State<CoverPageValidator> {
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
                onRetry: () {
                  // The button will switch to form tab via the ValidationResultWidget
                },
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
                        : const Text('VALIDATE COVER PAGE'),
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
          'Cover Page Validation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure your cover page contains all required information before proceeding.',
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
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
          _buildCriteriaItem('Project Name', 'Full name of the project'),
          _buildCriteriaItem('Company Name', 'Name of the organization'),
          _buildCriteriaItem('Document Version', 'e.g., 1.0, 2.1, etc.'),
          _buildCriteriaItem('Date', 'Creation or last modification date'),
          _buildCriteriaItem('Prepared By', 'Name and role of the document author'),
          _buildCriteriaItem('Project ID (Optional)', 'Internal project identifier'),
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
            color: Colors.blue,
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

    final result = BRDValidator.validateCoverPage(widget.content);

    // Just update the local validation result, do not affect the original component
    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
    
    // Skip calling onUpdate - validation should not affect the form data
  }
} 