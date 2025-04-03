import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class SignOffValidator extends StatelessWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const SignOffValidator({
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
    if (content['approvers']?.isEmpty ?? true) {
      missingFields.add('Approver Names');
    } else if (!_containsRolesWithNames(content['approvers'] ?? '')) {
      improvementSuggestions.add('Sign-off should include both names and roles of approvers.');
    }

    if (!_containsDates(content['approvers'] ?? '')) {
      missingFields.add('Sign-off Dates');
    }

    // Return validation result
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Sign-off section is complete with all required approvals.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Sign-off section is incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Sign-off section can be improved.',
        improvementSuggestions,
      );
    }
  }

  bool _containsRolesWithNames(String text) {
    // Check if roles are defined with names
    return text.contains(':') || text.contains(' - ') || text.contains(' as ');
  }

  bool _containsDates(String text) {
    // Check for dates in various formats
    return text.contains(RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}')) || // MM/DD/YYYY
           text.contains(RegExp(r'\b\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'));
  }
}
