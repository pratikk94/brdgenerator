import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class BusinessObjectivesValidator extends StatelessWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const BusinessObjectivesValidator({
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
    if (content['goals']?.isEmpty ?? true) {
      missingFields.add('Business Goals');
    } else if (!_checkSMARTCriteria(content['goals'] ?? '')) {
      improvementSuggestions.add('Goals should follow SMART criteria (Specific, Measurable, Achievable, Relevant, Time-bound).');
    }

    if (content['kpis']?.isEmpty ?? true) {
      missingFields.add('Key Performance Indicators');
    } else if (!(content['kpis'] ?? '').contains(RegExp(r'[0-9]'))) {
      improvementSuggestions.add('KPIs should include measurable metrics.');
    }

    if (content['success_criteria']?.isEmpty ?? true) {
      missingFields.add('Success Criteria');
    }

    // Return validation result
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Business objectives are well-defined with proper SMART criteria.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Business objectives are missing required fields.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Business objectives need improvement to meet SMART criteria.',
        improvementSuggestions,
      );
    }
  }

  bool _checkSMARTCriteria(String text) {
    // Check if the text contains measurable terms and timeframes
    return text.contains(RegExp(r'[0-9]')) &&
           (text.contains('by') || text.contains('within') || text.contains('date'));
  }
} 