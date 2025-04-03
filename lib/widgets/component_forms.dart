import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/brd_component.dart';
import 'forms/cover_page_form.dart';
import 'forms/executive_summary_form.dart';
import 'forms/problem_statement_form.dart';
import 'forms/proposed_solution_form.dart';
import 'forms/scope_form.dart';
import 'forms/functional_requirements_form.dart';
import 'forms/assumptions_constraints_form.dart';
import 'forms/timeline_form.dart';
import 'forms/resources_form.dart';
import 'forms/risks_form.dart';
import 'forms/glossary_form.dart';
import 'forms/sign_off_form.dart';
import 'validators/cover_page_validator.dart';
import 'validators/executive_summary_validator.dart';
import 'validators/problem_statement_validator.dart';
import 'validators/business_objectives_validator.dart';
import 'validators/scope_validator.dart';
import 'validators/stakeholders_validator.dart';
import 'validators/functional_requirements_validator.dart';
import 'validators/non_functional_requirements_validator.dart';
import 'validators/assumptions_constraints_validator.dart';
import 'validators/risks_validator.dart';
import 'validators/timeline_validator.dart';
import 'validators/glossary_validator.dart';
import 'validators/sign_off_validator.dart';
import 'validators/proposed_solution_validator.dart';
import 'validators/resources_validator.dart';

/// A utility class that provides factory methods to build the appropriate form
/// widget based on the BRD component type
class ComponentForms {
  /// Builds the appropriate form widget based on the component ID
  static Widget buildForm(
    BRDComponent component, 
    Function(Map<String, dynamic>) onUpdate
  ) {
    Map<String, dynamic> content = _parseContent(component.content);
    
    switch (component.id) {
      case 'cover':
        return CoverPageForm(component: component, onUpdate: onUpdate);
      case 'executive':
        return ExecutiveSummaryForm(component: component, onUpdate: onUpdate);
      case 'problem':
        return ProblemStatementForm(component: component, onUpdate: onUpdate);
      case 'proposed':
        return ProposedSolutionForm(component: component, onUpdate: onUpdate);
      case 'scope':
        return ScopeForm(component: component, onUpdate: onUpdate);
      case 'requirements':
        return FunctionalRequirementsForm(component: component, onUpdate: onUpdate);
      case 'constraints':
        return AssumptionsConstraintsForm(component: component, onUpdate: onUpdate);
      case 'timeline':
        return TimelineForm(component: component, onUpdate: onUpdate);
      case 'resources':
        return ResourcesForm(component: component, onUpdate: onUpdate);
      case 'risks':
        return RisksForm(component: component, onUpdate: onUpdate);
      case 'glossary':
        return GlossaryForm(component: component, onUpdate: onUpdate);
      case 'signoff':
        return SignOffForm(component: component, onUpdate: onUpdate);
      default:
        return _buildDefaultForm(component, onUpdate);
    }
  }

  /// Builds the appropriate validator widget based on the component ID
  static Widget buildValidator(
    BRDComponent component,
    Map<String, dynamic> validationContent,
    Function(BRDComponent) onUpdate
  ) {
    // Use the provided validation content directly
    Map<String, dynamic> content = validationContent.isNotEmpty ? 
        validationContent : _parseContent(component.content);
    
    switch (component.id) {
      case 'cover':
        return CoverPageValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'executive':
        return ExecutiveSummaryValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'problem':
        return ProblemStatementValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'proposed':
        return ProposedSolutionValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'objectives':
        return BusinessObjectivesValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'scope':
        return ScopeValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'stakeholders':
        return StakeholdersValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'requirements':
        return FunctionalRequirementsValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'nonfunctional':
        return NonFunctionalRequirementsValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'constraints':
        return AssumptionsConstraintsValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'risks':
        return RisksValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'timeline':
        return TimelineValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'resources':
        return ResourcesValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'glossary':
        return GlossaryValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      case 'signoff':
        return SignOffValidator(
          component: component, 
          content: content,
          onUpdate: onUpdate
        );
      default:
        return _buildDefaultValidator(component);
    }
  }

  /// Helper method to parse component content string to Map
  static Map<String, dynamic> _parseContent(String content) {
    if (content.isEmpty) return {};
    
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return {'rawContent': content};
    }
  }

  /// Builds a default form for components that don't have a specific form implementation yet
  static Widget _buildDefaultForm(
    BRDComponent component, 
    Function(Map<String, dynamic>) onUpdate
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.orange[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Form for "${component.title}" is coming soon',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              onUpdate({'rawContent': 'This section is under construction'});
            },
            child: const Text('Save Placeholder'),
          ),
        ],
      ),
    );
  }
  
  /// Builds a default validator for components that don't have a specific validator implementation yet
  static Widget _buildDefaultValidator(BRDComponent component) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.engineering,
            size: 64,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Validator for "${component.title}" is coming soon',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working on adding validation criteria for this section.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 