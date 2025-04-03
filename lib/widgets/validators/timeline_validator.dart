import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class TimelineValidator extends StatelessWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const TimelineValidator({
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
    if (content['phases']?.isEmpty ?? true) {
      missingFields.add('Project Phases');
    } else if (!_containsAtLeastThreePhases(content['phases'] ?? '')) {
      improvementSuggestions.add('Timeline should include at least 3 defined phases.');
    }

    if (content['milestones']?.isEmpty ?? true) {
      missingFields.add('Milestones');
    }

    if (content['deliverables']?.isEmpty ?? true) {
      missingFields.add('Deliverables');
    }

    if (!_containsDates(content['phases'] ?? '') && !_containsDates(content['milestones'] ?? '')) {
      improvementSuggestions.add('Timeline should include specific dates for phases and milestones.');
    }

    // Return validation result
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Timeline is well-structured with clear phases and milestones.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Timeline is missing key components.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Timeline can be improved with more specific information.',
        improvementSuggestions,
      );
    }
  }

  bool _containsAtLeastThreePhases(String text) {
    // Check for at least 3 phases
    return text.split('\n').length >= 3 || text.split(',').length >= 3;
  }

  bool _containsDates(String text) {
    // Check for dates in various formats
    return text.contains(RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}')) || // MM/DD/YYYY
           text.contains(RegExp(r'\b\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'));
  }
}
