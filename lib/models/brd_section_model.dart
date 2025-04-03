import 'package:flutter/material.dart';

enum BRDSectionType {
  coverPage,
  executiveSummary,
  businessObjectives,
  scope,
  stakeholders,
  functionalRequirements,
  nonFunctionalRequirements,
  assumptionsConstraints,
  riskAnalysis,
  timeline,
  glossary,
  signOff,
}

class BRDSection {
  final String title;
  final BRDSectionType type;
  final String description;
  final bool isRequired;
  final Map<String, dynamic> data;
  final bool isComplete;

  BRDSection({
    required this.title,
    required this.type,
    required this.description,
    required this.isRequired,
    this.data = const {},
    this.isComplete = false,
  });

  factory BRDSection.empty(BRDSectionType type) {
    String title;
    String description;
    bool isRequired;

    switch (type) {
      case BRDSectionType.coverPage:
        title = 'Cover Page';
        description = 'Project identity and document ownership';
        isRequired = true;
        break;
      case BRDSectionType.executiveSummary:
        title = 'Executive Summary';
        description = 'High-level overview and business intent';
        isRequired = true;
        break;
      case BRDSectionType.businessObjectives:
        title = 'Business Objectives';
        description = 'SMART goals and targeted improvements';
        isRequired = true;
        break;
      case BRDSectionType.scope:
        title = 'Scope';
        description = 'Project boundaries and deliverables';
        isRequired = true;
        break;
      case BRDSectionType.stakeholders:
        title = 'Stakeholders';
        description = 'Key participants and their roles';
        isRequired = true;
        break;
      case BRDSectionType.functionalRequirements:
        title = 'Functional Requirements';
        description = 'Features and user-level expectations';
        isRequired = true;
        break;
      case BRDSectionType.nonFunctionalRequirements:
        title = 'Non-Functional Requirements';
        description = 'System performance and quality attributes';
        isRequired = true;
        break;
      case BRDSectionType.assumptionsConstraints:
        title = 'Assumptions & Constraints';
        description = 'Project limitations and dependencies';
        isRequired = true;
        break;
      case BRDSectionType.riskAnalysis:
        title = 'Risk Analysis';
        description = 'Potential risks and mitigation strategies';
        isRequired = true;
        break;
      case BRDSectionType.timeline:
        title = 'Timeline';
        description = 'Project schedule and key deliverables';
        isRequired = true;
        break;
      case BRDSectionType.glossary:
        title = 'Glossary';
        description = 'Terms and definitions';
        isRequired = false;
        break;
      case BRDSectionType.signOff:
        title = 'Sign-off';
        description = 'Approval and authorization';
        isRequired = true;
        break;
    }

    return BRDSection(
      title: title,
      type: type,
      description: description,
      isRequired: isRequired,
    );
  }
} 