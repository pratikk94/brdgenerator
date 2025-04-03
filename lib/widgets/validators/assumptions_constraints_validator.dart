import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class AssumptionsConstraintsValidator extends StatelessWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const AssumptionsConstraintsValidator({
    Key? key,
    required this.component,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final validationResult = _validateContent();

    return ValidationResultWidget(
      result: validationResult,
      onRetry: () => onUpdate(component),
    );
  }

  BRDValidationResult _validateContent() {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];

    // Check for required fields
    if (content['assumptions']?.isEmpty ?? true) {
      missingFields.add('Assumptions');
    } else if (!_containsBusinessAssumptions(content['assumptions'] ?? '')) {
      improvementSuggestions.add('Include business assumptions (e.g., "Users will have internet access").');
    }

    if (content['constraints']?.isEmpty ?? true) {
      missingFields.add('Constraints');
    } else if (!_containsDifferentConstraintTypes(content['constraints'] ?? '')) {
      improvementSuggestions.add('Include different types of constraints (e.g., budget, time, technology, legal).');
    }

    // Return validation result
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Assumptions and constraints are well-documented.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Assumptions and constraints section is incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Assumptions and constraints can be improved.',
        improvementSuggestions,
      );
    }
  }

  bool _containsBusinessAssumptions(String text) {
    // Check for business assumptions
    return text.toLowerCase().contains('user') ||
           text.toLowerCase().contains('customer') ||
           text.toLowerCase().contains('business');
  }

  bool _containsDifferentConstraintTypes(String text) {
    // Look for different types of constraints
    int types = 0;
    if (text.toLowerCase().contains('budget') || text.toLowerCase().contains('cost')) types++;
    if (text.toLowerCase().contains('time') || text.toLowerCase().contains('schedule')) types++;
    if (text.toLowerCase().contains('technical') || text.toLowerCase().contains('technology')) types++;
    if (text.toLowerCase().contains('legal') || text.toLowerCase().contains('regulatory')) types++;
    return types >= 2;
  }
}
