import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import '../validators/validation_result_widget.dart';

class ProblemStatementValidator extends StatefulWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const ProblemStatementValidator({
    Key? key,
    required this.component,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProblemStatementValidatorState createState() => _ProblemStatementValidatorState();
}

class _ProblemStatementValidatorState extends State<ProblemStatementValidator> {
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
                        : const Text('VALIDATE PROBLEM STATEMENT'),
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
          'Problem Statement Validation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure your problem statement clearly defines the issue, its impact, and the need for a solution.',
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
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
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
          _buildCriteriaItem('Current State', 'Description of the current situation'),
          _buildCriteriaItem('Problem Description', 'Detailed explanation of the problem to be solved'),
          _buildCriteriaItem('Business Impact', 'Quantifiable effects on the business (include metrics if possible)'),
          _buildCriteriaItem('Affected Stakeholders', 'Who is impacted by this problem'),
          _buildCriteriaItem('Urgency', 'Why this problem needs to be addressed now'),
          _buildCriteriaItem('Root Cause', 'Underlying causes (if known)'),
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
            color: Colors.amber,
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

    final result = BRDValidator.validateProblemStatement(widget.content);

    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
  }
} 