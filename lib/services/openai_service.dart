import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/brd_section_model.dart';

class OpenAIService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;

  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in .env file');
    }
  }

  Future<String> generateBRDSection(BRDSection section, Map<String, dynamic> data) async {
    final prompt = _getPromptForSection(section.type, data);
    
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional business analyst helping to write a Business Requirements Document (BRD). Provide clear, concise, and well-structured content.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate content: ${response.body}');
    }
  }
  
  Future<String> generateComponentContent(String prompt) async {
    try {
      // Call the actual OpenAI API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional business analyst helping to write a Business Requirements Document (BRD). Provide clear, concise, and well-structured content in markdown format.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        print('OpenAI API error: ${response.statusCode} - ${response.body}');
        // Fall back to sample content if API call fails
        return _getSampleContent(prompt);
      }
    } catch (e) {
      print('Error calling OpenAI API: $e');
      // Fall back to sample content on error
      return _getSampleContent(prompt);
    }
  }

  String _getPromptForSection(BRDSectionType type, Map<String, dynamic> data) {
    switch (type) {
      case BRDSectionType.coverPage:
        return '''Create a professional cover page for a Business Requirements Document with the following details:
          - Project Name: ${data['projectName']}
          - Company Name: ${data['companyName']}
          - Prepared By: ${data['preparedBy']}
          - Version: ${data['version']}
          - Date: ${data['date']}''';

      case BRDSectionType.executiveSummary:
        return '''Write an executive summary for a Business Requirements Document that includes:
          - Business Context: ${data['context']}
          - Problem Statement: ${data['problem']}
          - Project Purpose: ${data['purpose']}
          Keep it concise and focused on the key points.''';

      case BRDSectionType.businessObjectives:
        return '''List the business objectives for the project, including:
          - Goals: ${data['goals']}
          - KPIs: ${data['kpis']}
          - Success Criteria: ${data['success_criteria']}
          Format them as SMART objectives (Specific, Measurable, Achievable, Relevant, Time-bound).''';

      case BRDSectionType.scope:
        return '''Define the project scope, clearly stating:
          - In Scope Items: ${data['in_scope']}
          - Out of Scope Items: ${data['out_scope']}
          Be specific about what will and will not be delivered.''';

      case BRDSectionType.stakeholders:
        return '''List and describe the project stakeholders:
          - Internal Stakeholders: ${data['internal']}
          - Roles and Responsibilities: ${data['roles']}
          Include their influence level and interest in the project.''';

      case BRDSectionType.functionalRequirements:
        return '''Detail the functional requirements:
          - Features: ${data['features']}
          - User Stories: ${data['user_stories']}
          - Acceptance Criteria: ${data['acceptance_criteria']}
          Use clear, testable statements.''';

      case BRDSectionType.nonFunctionalRequirements:
        return '''Specify the non-functional requirements:
          - Performance: ${data['performance']}
          - Security: ${data['security']}
          - Usability: ${data['usability']}
          - Scalability: ${data['scalability']}
          Include measurable criteria where possible.''';

      case BRDSectionType.assumptionsConstraints:
        return '''List the project assumptions and constraints:
          - Assumptions: ${data['assumptions']}
          - Constraints: ${data['constraints']}
          Be clear about their impact on the project.''';

      case BRDSectionType.riskAnalysis:
        return '''Analyze the project risks:
          - Identified Risks: ${data['risks']}
          - Impact Assessment: ${data['impact']}
          - Mitigation Strategies: ${data['mitigation']}
          Include probability and severity ratings.''';

      case BRDSectionType.timeline:
        return '''Create a project timeline:
          - Phases: ${data['phases']}
          - Milestones: ${data['milestones']}
          - Deliverables: ${data['deliverables']}
          Include estimated durations and dependencies.''';

      case BRDSectionType.glossary:
        return '''Create a glossary of terms:
          - Terms: ${data['terms']}
          - Definitions: ${data['definitions']}
          List them in alphabetical order.''';

      case BRDSectionType.signOff:
        return '''Create a sign-off section:
          - Approvers: ${data['approvers']}
          Include spaces for signatures and dates.''';
    }
  }

  // Generate sample content for testing when API is unavailable
  String _getSampleContent(String prompt) {
    if (prompt.contains('Cover Page')) {
      return '''# Cover Page

**Project Name:** Digital Transformation Initiative
**Company Name:** InnovateTech Solutions
**Document Version:** 1.0
**Date:** ${DateTime.now().toString().split(' ')[0]}
**Prepared By:** Alex Johnson, Senior Business Analyst
**Project ID:** DT-2023-001''';
    } 
    else if (prompt.contains('Executive Summary')) {
      return '''# Executive Summary

## Business Background
InnovateTech Solutions is a mid-sized technology company seeking to modernize its customer relationship management processes to improve efficiency and customer satisfaction.

## Problem
The current customer management system is outdated, leading to inefficiencies, data inconsistencies, and decreased customer satisfaction ratings over the past year.

## Opportunity
By implementing a new CRM system with integrated analytics and mobile capabilities, the company can streamline processes, improve data accuracy, and enhance customer experience.

## Objective
This document outlines the requirements for a new customer relationship management system that will replace the existing outdated platform, with the goal of improving operational efficiency by 30% and customer satisfaction scores by 25% within six months of implementation.''';
    }
    else if (prompt.contains('Business Objectives')) {
      return '''# Business Objectives

1. **Increase Customer Retention Rate**: Improve customer retention rate from 75% to 85% by December 31, 2023 through enhanced customer service capabilities and personalized engagement features.
   - **KPI**: Monthly customer retention rate
   - **Target**: 85%

2. **Reduce Response Time**: Decrease average customer inquiry response time from 24 hours to 4 hours by October 15, 2023 through automated routing and prioritization.
   - **KPI**: Average response time
   - **Target**: 4 hours

3. **Improve Data Accuracy**: Achieve 99% data accuracy in customer records by September 30, 2023 through data validation controls and automated verification processes.
   - **KPI**: Error rate in customer records
   - **Target**: <1%

## Success Criteria
- System adoption rate of at least 90% among all customer-facing staff
- Reduction in duplicate customer records by 95%
- Customer satisfaction survey results improved by at least 25% compared to baseline''';
    }
    else {
      // Default sample content with section headers for other components
      return '''# Sample Content for ${prompt.split('\n').first}

## Section 1
This is sample content for the first section of this document component.

## Section 2
This component would normally contain detailed information relevant to this specific part of the BRD.

## Section 3
In a real implementation, this would be populated with data from the OpenAI API based on the project description provided.''';
    }
  }
} 