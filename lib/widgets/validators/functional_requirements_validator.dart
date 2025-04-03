import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import '../validators/validation_result_widget.dart';

class FunctionalRequirementsValidator extends StatefulWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const FunctionalRequirementsValidator({
    Key? key,
    required this.component,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _FunctionalRequirementsValidatorState createState() => _FunctionalRequirementsValidatorState();
}

class _FunctionalRequirementsValidatorState extends State<FunctionalRequirementsValidator> {
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
            
            _buildUserStoryInfo(),
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
                        : const Text('VALIDATE FUNCTIONAL REQUIREMENTS'),
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
          'Functional Requirements Validation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure your functional requirements clearly define what the system should do.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildUserStoryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'User Story Format:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'As a [role], I want [feature] so that [benefit]',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Example: "As a customer, I want to save my payment methods so that I can check out faster next time."',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCriteria() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
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
          _buildCriteriaItem('Feature Descriptions', 'Clear descriptions of each feature'),
          _buildCriteriaItem('User Stories', 'Following the "As a, I want, so that" format'),
          _buildCriteriaItem('Acceptance Criteria', 'Specific conditions that must be met for a feature to be accepted'),
          _buildCriteriaItem('User Roles', 'Identification of which user roles are involved with each feature'),
          _buildCriteriaItem('Dependencies', 'Any dependencies between requirements or with external systems'),
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
            color: Colors.teal,
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

    final result = BRDValidator.validateFunctionalRequirements(widget.content);

    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
  }
}
