import 'package:flutter/material.dart';
import '../../models/brd_component.dart';
import '../../models/brd_validator_model.dart';
import 'validation_result_widget.dart';

class GlossaryValidator extends StatelessWidget {
  final BRDComponent component;
  final Map<String, dynamic> content;
  final Function(BRDComponent) onUpdate;

  const GlossaryValidator({
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
    if (content['terms']?.isEmpty ?? true) {
      missingFields.add('Terms');
    }

    if (content['definitions']?.isEmpty ?? true) {
      missingFields.add('Definitions');
    } else if ((content['definitions'] ?? '').split('\n').length < 5) {
      improvementSuggestions.add('Glossary should include definitions for all technical or business terms used in the BRD.');
    }

    // Return validation result
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Glossary provides clear definitions for all technical and business terms.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Glossary is incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Glossary can be improved.',
        improvementSuggestions,
      );
    }
  }
}
