import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class RisksValidator extends StatelessWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const RisksValidator({
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
    if (content['risks']?.isEmpty ?? true) {
      missingFields.add('Risk Descriptions');
    }

    if (content['impact']?.isEmpty ?? true) {
      missingFields.add('Risk Impact');
    } else if (!_containsSeverityRatings(content['impact'] ?? '')) {
      improvementSuggestions.add('Risk impact should include severity ratings (High/Medium/Low).');
    }

    if (content['mitigation']?.isEmpty ?? true) {
      missingFields.add('Mitigation Strategies');
    }

    // Return validation result
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Risk analysis is thorough with mitigation strategies.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Risk analysis is incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Risk analysis can be improved.',
        improvementSuggestions,
      );
    }
  }

  bool _containsSeverityRatings(String text) {
    // Check for severity ratings
    return (text.contains('High') || text.contains('high')) &&
           (text.contains('Medium') || text.contains('medium') || text.contains('Med')) &&
           (text.contains('Low') || text.contains('low'));
  }
}
