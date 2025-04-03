import '../models/brd_section_model.dart';

class ValidationResult {
  final bool isValid;
  final String message;
  final List<String> issues;

  ValidationResult({
    required this.isValid,
    required this.message,
    this.issues = const [],
  });
}

class BRDValidatorService {
  ValidationResult validateSection(BRDSection section, Map<String, dynamic> data) {
    switch (section.type) {
      case BRDSectionType.coverPage:
        return _validateCoverPage(data);
      case BRDSectionType.executiveSummary:
        return _validateExecutiveSummary(data);
      case BRDSectionType.businessObjectives:
        return _validateBusinessObjectives(data);
      case BRDSectionType.scope:
        return _validateScope(data);
      case BRDSectionType.stakeholders:
        return _validateStakeholders(data);
      case BRDSectionType.functionalRequirements:
        return _validateFunctionalRequirements(data);
      case BRDSectionType.nonFunctionalRequirements:
        return _validateNonFunctionalRequirements(data);
      case BRDSectionType.assumptionsConstraints:
        return _validateAssumptionsConstraints(data);
      case BRDSectionType.riskAnalysis:
        return _validateRiskAnalysis(data);
      case BRDSectionType.timeline:
        return _validateTimeline(data);
      case BRDSectionType.glossary:
        return _validateGlossary(data);
      case BRDSectionType.signOff:
        return _validateSignOff(data);
      default:
        return ValidationResult(
          isValid: false,
          message: 'Unknown section type',
        );
    }
  }

  ValidationResult _validateCoverPage(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['projectName']?.isEmpty ?? true) {
      issues.add('Project name is required');
    }
    if (data['companyName']?.isEmpty ?? true) {
      issues.add('Company name is required');
    }
    if (data['preparedBy']?.isEmpty ?? true) {
      issues.add('Prepared by is required');
    }
    if (data['version']?.isEmpty ?? true) {
      issues.add('Version is required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Cover page is valid' : 'Cover page has issues',
      issues: issues,
    );
  }

  ValidationResult _validateExecutiveSummary(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['context']?.isEmpty ?? true) {
      issues.add('Business context is required');
    }
    if (data['problem']?.isEmpty ?? true) {
      issues.add('Problem statement is required');
    }
    if (data['purpose']?.isEmpty ?? true) {
      issues.add('Purpose is required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Executive summary is valid' : 'Executive summary has issues',
      issues: issues,
    );
  }

  ValidationResult _validateBusinessObjectives(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['goals']?.isEmpty ?? true) {
      issues.add('Business goals are required');
    }
    if (data['kpis']?.isEmpty ?? true) {
      issues.add('KPIs are required');
    }
    if (data['success_criteria']?.isEmpty ?? true) {
      issues.add('Success criteria are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Business objectives are valid' : 'Business objectives have issues',
      issues: issues,
    );
  }

  ValidationResult _validateScope(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['in_scope']?.isEmpty ?? true) {
      issues.add('In-scope items are required');
    }
    if (data['out_scope']?.isEmpty ?? true) {
      issues.add('Out-of-scope items are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Scope is valid' : 'Scope has issues',
      issues: issues,
    );
  }

  ValidationResult _validateStakeholders(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['internal']?.isEmpty ?? true) {
      issues.add('Internal stakeholders are required');
    }
    if (data['roles']?.isEmpty ?? true) {
      issues.add('Roles and responsibilities are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Stakeholders are valid' : 'Stakeholders have issues',
      issues: issues,
    );
  }

  ValidationResult _validateFunctionalRequirements(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['features']?.isEmpty ?? true) {
      issues.add('Features are required');
    }
    if (data['user_stories']?.isEmpty ?? true) {
      issues.add('User stories are required');
    }
    if (data['acceptance_criteria']?.isEmpty ?? true) {
      issues.add('Acceptance criteria are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Functional requirements are valid' : 'Functional requirements have issues',
      issues: issues,
    );
  }

  ValidationResult _validateNonFunctionalRequirements(Map<String, dynamic> data) {
    final issues = <String>[];
    final requiredCategories = ['performance', 'security', 'usability', 'scalability'];

    for (final category in requiredCategories) {
      if (data[category]?.isEmpty ?? true) {
        issues.add('$category requirements are required');
      }
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Non-functional requirements are valid' : 'Non-functional requirements have issues',
      issues: issues,
    );
  }

  ValidationResult _validateAssumptionsConstraints(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['assumptions']?.isEmpty ?? true) {
      issues.add('Assumptions are required');
    }
    if (data['constraints']?.isEmpty ?? true) {
      issues.add('Constraints are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Assumptions and constraints are valid' : 'Assumptions and constraints have issues',
      issues: issues,
    );
  }

  ValidationResult _validateRiskAnalysis(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['risks']?.isEmpty ?? true) {
      issues.add('Risks are required');
    }
    if (data['impact']?.isEmpty ?? true) {
      issues.add('Impact assessment is required');
    }
    if (data['mitigation']?.isEmpty ?? true) {
      issues.add('Mitigation strategies are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Risk analysis is valid' : 'Risk analysis has issues',
      issues: issues,
    );
  }

  ValidationResult _validateTimeline(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['phases']?.isEmpty ?? true) {
      issues.add('Project phases are required');
    }
    if (data['milestones']?.isEmpty ?? true) {
      issues.add('Milestones are required');
    }
    if (data['deliverables']?.isEmpty ?? true) {
      issues.add('Deliverables are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Timeline is valid' : 'Timeline has issues',
      issues: issues,
    );
  }

  ValidationResult _validateGlossary(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['terms']?.isEmpty ?? true && data['definitions']?.isEmpty ?? true) {
      issues.add('At least one term and definition is required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Glossary is valid' : 'Glossary has issues',
      issues: issues,
    );
  }

  ValidationResult _validateSignOff(Map<String, dynamic> data) {
    final issues = <String>[];

    if (data['approvers']?.isEmpty ?? true) {
      issues.add('Approvers are required');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      message: issues.isEmpty ? 'Sign-off is valid' : 'Sign-off has issues',
      issues: issues,
    );
  }

  ValidationResult validateCompleteBRD(List<BRDSection> sections) {
    final issues = <String>[];
    var completedSections = 0;

    for (final section in sections) {
      if (section.isComplete) {
        completedSections++;
      } else if (section.isRequired) {
        issues.add('${section.title} is required but not complete');
      }
    }

    final isValid = issues.isEmpty && completedSections == sections.where((s) => s.isRequired).length;
    return ValidationResult(
      isValid: isValid,
      message: isValid ? 'BRD is complete and valid' : 'BRD has incomplete sections',
      issues: issues,
    );
  }
} 