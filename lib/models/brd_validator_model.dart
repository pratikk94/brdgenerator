class BRDValidationResult {
  final bool isPassed;
  final String message;
  final List<String> improvementSuggestions;

  const BRDValidationResult({
    required this.isPassed,
    required this.message,
    this.improvementSuggestions = const [],
  });

  factory BRDValidationResult.pass(String message) {
    return BRDValidationResult(
      isPassed: true,
      message: message,
    );
  }

  factory BRDValidationResult.fail(String message, List<String> suggestions) {
    return BRDValidationResult(
      isPassed: false,
      message: message,
      improvementSuggestions: suggestions,
    );
  }
}

class BRDValidator {
  static BRDValidationResult validateCoverPage(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    
    if (content['projectName']?.isEmpty ?? true) {
      missingFields.add('Project Name');
    }
    
    if (content['companyName']?.isEmpty ?? true) {
      missingFields.add('Company Name');
    }
    
    if (content['version']?.isEmpty ?? true) {
      missingFields.add('Document Version');
    }
    
    if (content['date']?.isEmpty ?? true) {
      missingFields.add('Date');
    }
    
    if (content['preparedBy']?.isEmpty ?? true) {
      missingFields.add('Prepared By');
    }
    
    if (missingFields.isEmpty) {
      return BRDValidationResult.pass('Cover page has all required information.');
    } else {
      return BRDValidationResult.fail(
        'The cover page is missing required information.',
        missingFields.map((field) => '$field is required.').toList(),
      );
    }
  }

  static BRDValidationResult validateExecutiveSummary(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    
    if (content['businessContext']?.isEmpty ?? true) {
      missingFields.add('Business background or context');
    }
    
    if (content['problemStatement']?.isEmpty ?? true) {
      missingFields.add('Problem or need statement');
    }
    
    if (content['proposedSolution']?.isEmpty ?? true) {
      missingFields.add('Proposed solution or opportunity');
    }
    
    if (content['benefits']?.isEmpty ?? true) {
      missingFields.add('Expected benefits or document objective');
    }
    
    if (missingFields.isEmpty) {
      return BRDValidationResult.pass('Executive summary has all required information.');
    } else {
      return BRDValidationResult.fail(
        'The executive summary is missing critical components.',
        missingFields.map((field) => '$field is required.').toList(),
      );
    }
  }

  static BRDValidationResult validateProblemStatement(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (content['currentState']?.isEmpty ?? true) {
      missingFields.add('Current State');
    } else if ((content['currentState'] ?? '').length < 20) {
      improvementSuggestions.add('Current State description is too brief. Provide more context.');
    }
    
    if (content['problemDescription']?.isEmpty ?? true) {
      missingFields.add('Problem Description');
    } else if ((content['problemDescription'] ?? '').length < 30) {
      improvementSuggestions.add('Problem Description is too vague. Be more specific about the issue.');
    }
    
    if (content['impact']?.isEmpty ?? true) {
      missingFields.add('Business Impact');
    } else if (!(content['impact'] ?? '').contains(RegExp(r'[0-9]'))) {
      improvementSuggestions.add('Business Impact should ideally include metrics or quantifiable effects.');
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Problem statement is well-defined and complete.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'The problem statement is missing required fields.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'The problem statement can be improved for clarity and completeness.',
        improvementSuggestions,
      );
    }
  }

  static BRDValidationResult validateBusinessObjectives(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
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
  
  static BRDValidationResult validateScope(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (content['in_scope']?.isEmpty ?? true) {
      missingFields.add('In-Scope Items');
    } else if (!_containsListItems(content['in_scope'] ?? '')) {
      improvementSuggestions.add('In-Scope items should be clearly listed, preferably as bullet points.');
    }
    
    if (content['out_scope']?.isEmpty ?? true) {
      missingFields.add('Out-of-Scope Items');
    } else if (!_containsListItems(content['out_scope'] ?? '')) {
      improvementSuggestions.add('Out-of-Scope items should be clearly listed to avoid scope creep.');
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Project scope is well-defined with clear boundaries.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Project scope definition is incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Project scope can be improved for clarity.',
        improvementSuggestions,
      );
    }
  }
  
  static BRDValidationResult validateStakeholders(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (content['internal']?.isEmpty ?? true) {
      missingFields.add('Internal Stakeholders');
    }
    
    if (content['roles']?.isEmpty ?? true) {
      missingFields.add('Stakeholder Roles');
    } else if (!_containsRoleDefinitions(content['roles'] ?? '')) {
      improvementSuggestions.add('Each stakeholder should have a clearly defined role or interest in the project.');
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Stakeholder analysis is complete with defined roles.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Stakeholder analysis is missing key information.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Stakeholder analysis can be improved.',
        improvementSuggestions,
      );
    }
  }
  
  static BRDValidationResult validateFunctionalRequirements(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (content['features']?.isEmpty ?? true) {
      missingFields.add('Feature Descriptions');
    }
    
    if (content['user_stories']?.isEmpty ?? true) {
      missingFields.add('User Stories');
    } else if (!_containsUserStoryFormat(content['user_stories'] ?? '')) {
      improvementSuggestions.add('User stories should follow the format: "As a [role], I want [feature] so that [benefit]".');
    }
    
    if (content['acceptance_criteria']?.isEmpty ?? true) {
      missingFields.add('Acceptance Criteria');
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Functional requirements are well-defined with proper user stories and acceptance criteria.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Functional requirements are incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Functional requirements can be improved.',
        improvementSuggestions,
      );
    }
  }
  
  static BRDValidationResult validateNonFunctionalRequirements(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    final requiredCategories = [
      'performance',
      'security',
      'usability',
      'scalability',
    ];
    
    int categoriesFound = 0;
    
    for (final category in requiredCategories) {
      if (content[category]?.isNotEmpty ?? false) {
        categoriesFound++;
      }
    }
    
    if (categoriesFound < 3) {
      missingFields.add('At least 3 Non-Functional Requirement categories');
    }
    
    for (final category in requiredCategories) {
      if (content[category]?.isNotEmpty ?? false) {
        if (!_containsMeasurableExpectation(content[category] ?? '')) {
          improvementSuggestions.add('$category requirements should include measurable expectations.');
        }
      }
    }
    
    if (missingFields.isEmpty && improvementSuggestions.isEmpty) {
      return BRDValidationResult.pass('Non-functional requirements are comprehensive and measurable.');
    } else if (missingFields.isNotEmpty) {
      return BRDValidationResult.fail(
        'Non-functional requirements section is incomplete.',
        [...missingFields.map((field) => '$field is required.'), ...improvementSuggestions],
      );
    } else {
      return BRDValidationResult.fail(
        'Non-functional requirements need measurable criteria.',
        improvementSuggestions,
      );
    }
  }
  
  static BRDValidationResult validateAssumptionsConstraints(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
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
  
  static BRDValidationResult validateRisks(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
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
  
  static BRDValidationResult validateTimeline(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
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
  
  static BRDValidationResult validateGlossary(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (content['terms']?.isEmpty ?? true) {
      missingFields.add('Terms');
    }
    
    if (content['definitions']?.isEmpty ?? true) {
      missingFields.add('Definitions');
    } else if ((content['definitions'] ?? '').split('\n').length < 5) {
      improvementSuggestions.add('Glossary should include definitions for all technical or business terms used in the BRD.');
    }
    
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
  
  static BRDValidationResult validateSignOff(Map<String, dynamic> content) {
    final List<String> missingFields = [];
    final List<String> improvementSuggestions = [];
    
    if (content['approvers']?.isEmpty ?? true) {
      missingFields.add('Approver Names');
    } else if (!_containsRolesWithNames(content['approvers'] ?? '')) {
      improvementSuggestions.add('Sign-off should include both names and roles of approvers.');
    }
    
    if (!_containsDates(content['approvers'] ?? '')) {
      missingFields.add('Sign-off Dates');
    }
    
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
  
  // Helper functions for validation checks
  
  static bool _checkSMARTCriteria(String text) {
    // Simple check: look for measurable terms and timeframes
    return text.contains(RegExp(r'[0-9]')) && 
           (text.contains('by') || text.contains('within') || text.contains('date'));
  }
  
  static bool _containsListItems(String text) {
    // Check if text has list items (bullet points, numbers, or dashes)
    return text.contains(RegExp(r'[\n•\-*]'));
  }
  
  static bool _containsRoleDefinitions(String text) {
    // Check if roles are defined
    return text.contains(':') || text.contains(' - ') || text.contains(' as ');
  }
  
  static bool _containsUserStoryFormat(String text) {
    // Check for "As a ... I want ... so that" format
    return text.contains('As a') && text.contains('I want') && text.contains('so that');
  }
  
  static bool _containsMeasurableExpectation(String text) {
    // Check for measurable criteria
    return text.contains(RegExp(r'[0-9]')) || 
           text.contains('seconds') || 
           text.contains('minutes') ||
           text.contains('hours') ||
           text.contains('percent');
  }
  
  static bool _containsBusinessAssumptions(String text) {
    // Check for business assumptions
    return text.toLowerCase().contains('user') || 
           text.toLowerCase().contains('customer') || 
           text.toLowerCase().contains('business');
  }
  
  static bool _containsDifferentConstraintTypes(String text) {
    // Look for different types of constraints
    int types = 0;
    if (text.toLowerCase().contains('budget') || text.toLowerCase().contains('cost')) types++;
    if (text.toLowerCase().contains('time') || text.toLowerCase().contains('schedule')) types++;
    if (text.toLowerCase().contains('technical') || text.toLowerCase().contains('technology')) types++;
    if (text.toLowerCase().contains('legal') || text.toLowerCase().contains('regulatory')) types++;
    return types >= 2;
  }
  
  static bool _containsSeverityRatings(String text) {
    // Check for severity ratings
    return (text.contains('High') || text.contains('high')) && 
           (text.contains('Medium') || text.contains('medium') || text.contains('Med')) && 
           (text.contains('Low') || text.contains('low'));
  }
  
  static bool _containsAtLeastThreePhases(String text) {
    // Check for at least 3 phases
    return text.split('\n').length >= 3 || text.split(',').length >= 3;
  }
  
  static bool _containsDates(String text) {
    // Check for dates in various formats
    return text.contains(RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}')) || // MM/DD/YYYY
           text.contains(RegExp(r'\b\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'));
  }
  
  static bool _containsRolesWithNames(String text) {
    // Check if text contains both names and roles
    return text.contains(',') && 
          (text.contains('Role:') || text.toLowerCase().contains('manager') || 
           text.toLowerCase().contains('director') || text.toLowerCase().contains('lead'));
  }
} 