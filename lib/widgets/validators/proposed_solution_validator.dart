import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class ProposedSolutionValidator extends StatefulWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const ProposedSolutionValidator({
    Key? key,
    required this.component,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProposedSolutionValidatorState createState() => _ProposedSolutionValidatorState();
}

class _ProposedSolutionValidatorState extends State<ProposedSolutionValidator> {
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
                        : const Text('VALIDATE PROPOSED SOLUTION'),
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
          'Proposed Solution Validation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure your proposed solution clearly addresses the problem statement with a comprehensive approach.',
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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
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
          _buildCriteriaItem('Solution Overview', 'High-level description of the proposed solution'),
          _buildCriteriaItem('Key Features', 'Major features and capabilities of the solution'),
          _buildCriteriaItem('Solution Justification', 'Why this solution is appropriate for the problem'),
          _buildCriteriaItem('Expected Benefits', 'Key benefits and outcomes of implementing the solution'),
          _buildCriteriaItem('Alternative Solutions', 'Brief overview of alternatives considered'),
          _buildCriteriaItem('Implementation Approach', 'High-level implementation strategy (optional)'),
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
            color: Colors.green,
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

    final result = _validateProposedSolution();

    // Just update the local validation result
    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
    
    // Skip calling onUpdate - validation should not modify form data
  }

  BRDValidationResult _validateProposedSolution() {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (widget.content['overview']?.isEmpty ?? true) {
      missingFields.add('Solution Overview');
    } else if ((widget.content['overview'] ?? '').length < 50) {
      improvementSuggestions.add('Solution overview should provide a comprehensive description of your approach.');
    }
    
    if (widget.content['features']?.isEmpty ?? true) {
      missingFields.add('Key Features');
    } else if (!_containsListItems(widget.content['features'] ?? '')) {
      improvementSuggestions.add('Key features should be clearly listed, preferably as bullet points.');
    }
    
    if (widget.content['justification']?.isEmpty ?? true) {
      missingFields.add('Solution Justification');
    }
    
    if (widget.content['benefits']?.isEmpty ?? true) {
      missingFields.add('Expected Benefits');
    }
    
    if (widget.content['alternatives']?.isEmpty ?? true) {
      improvementSuggestions.add('Consider including alternatives that were evaluated before choosing this solution.');
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Proposed solution is well-defined and addresses the problem statement.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'The proposed solution is missing required information.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'The proposed solution can be improved for clarity and completeness.',
        improvementSuggestions,
      );
    }
  }

  bool _containsListItems(String text) {
    // Check if text has list items (bullet points, numbers, or dashes)
    return text.contains(RegExp(r'[\n•\-*]')) || text.contains(RegExp(r'\n\d+\.'));
  }
} 