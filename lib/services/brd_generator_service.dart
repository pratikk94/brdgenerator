import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/brd_model.dart';

class BRDGeneratorService {
  // API key from environment variables
  final String? apiKey = dotenv.env['OPENAI_API_KEY'];
  
  // Generate BRD document from project description
  Future<String> generateBRDDocument(BRDModel brdModel) async {
    try {
      // Convert the BRD model to a structured prompt
      final String brdPrompt = _createBRDPrompt(brdModel);
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o', // Using gpt-4 for better document quality
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a professional business analyst and technical writer specializing in creating comprehensive Business Requirements Documents (BRD) for websites and web applications. Format your output in Markdown.'
            },
            {'role': 'user', 'content': brdPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 4000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('Failed to generate BRD: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return "Error generating BRD document: $e";
    }
  }
  
  // Generate only a specific section of the BRD
  Future<String> generateBRDSection(BRDModel brdModel, String section) async {
    try {
      // Create a prompt specific to the section
      final String sectionPrompt = _createSectionPrompt(brdModel, section);
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a professional business analyst specializing in creating detailed website requirements documentation. Format your output in Markdown.'
            },
            {'role': 'user', 'content': sectionPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('Failed to generate section: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return "Error generating section: $e";
    }
  }
  
  // Create a structured BRD prompt from the model
  String _createBRDPrompt(BRDModel model) {
    return '''
Create a comprehensive Business Requirements Document (BRD) for a website project with the following details:

## 1. Basic Information
- Company/Brand: ${model.companyName}
- Purpose: ${model.websitePurpose}
- Existing Website: ${model.existingWebsite}
- Target Audience: ${model.targetAudiences.join(', ')}

## 2. Goals and Objectives
- Top Goals: ${model.topGoals.join(', ')}
- Key Metrics: ${model.keyMetrics.join(', ')}

## 3. Design and Branding
- Existing Branding: ${model.hasExistingBranding ? 'Yes' : 'No'}
${model.brandingDetails != null ? '- Branding Details: ${model.brandingDetails}' : ''}
- Preferred Look and Feel: ${model.preferredLookAndFeel}
- Websites Liked: ${model.websitesLiked.join(', ')}
- Design Elements to Avoid: ${model.designElementsToAvoid.join(', ')}

## 4. Features and Functionality
- Key Features: ${model.keyFeatures.entries.where((e) => e.value).map((e) => e.key).join(', ')}
- Integrations: ${model.integrations.join(', ')}
- Multi-language Support: ${model.multiLanguageSupport ? 'Yes' : 'No'}

## 5. Pages and Content
- Essential Pages: ${model.essentialPages.join(', ')}
- Existing Content: ${model.hasExistingContent ? 'Yes' : 'No'}
- Media Assets Needed: ${model.needsMediaAssets ? 'Yes' : 'No'}
- SEO-Optimized Content: ${model.needsSEOContent ? 'Yes' : 'No'}

## 6. User Experience & Flow
- User Journey: ${model.userJourney}
- Call-to-Actions: ${model.callToActions.join(', ')}
- Key Conversions: ${model.keyConversions.join(', ')}

## 7. Technical Requirements
${model.preferredTechStack != null ? '- Preferred Tech Stack: ${model.preferredTechStack}' : ''}
- Hosting/Domain: ${model.hasHostingDomain ? 'Already acquired' : 'Not acquired'}
- DNS Setup Assistance: ${model.needsDNSSetup ? 'Needed' : 'Not needed'}
- Expected Traffic: ${model.expectedTrafficLoad}
- Mobile-First Design: ${model.mobileFirstDesign ? 'Yes' : 'No'}
- Accessibility Compliance: ${model.accessibilityCompliance ? 'Yes' : 'No'}

## 8. CMS & Admin Capabilities
${model.preferredCMS != null ? '- Preferred CMS: ${model.preferredCMS}' : ''}
- Editable Parts: ${model.editableParts.join(', ')}
- Content Manager: ${model.contentManager}

## 9. SEO & Analytics
- SEO Setup: ${model.needsSEOSetup ? 'Yes' : 'No'}
- Keyword Research: ${model.needsKeywordResearch ? 'Yes' : 'No'}
- Analytics Integration: ${model.needsAnalyticsIntegration ? 'Yes' : 'No'}
- Schema Markup: ${model.needsSchemaMarkup ? 'Yes' : 'No'}

## 10. Maintenance & Support
- Ongoing Maintenance: ${model.needsOngoingMaintenance ? 'Yes' : 'No'}
- Update Frequency: ${model.updateFrequency}
- Backup & Recovery: ${model.needsBackupRecovery ? 'Yes' : 'No'}

## 11. Timeline & Budget
${model.preferredLaunchDate != null ? '- Preferred Launch Date: ${model.preferredLaunchDate!.toIso8601String().split('T')[0]}' : ''}
- Important Milestones: ${model.importantMilestones.join(', ')}
${model.budgetRange != null ? '- Budget Range: ${model.budgetRange}' : ''}

## 12. Legal and Compliance
- Legal Pages: ${model.needsLegalPages ? 'Yes' : 'No'}
- Compliance Requirements: ${model.complianceRequirements.join(', ')}

## 13. Content & Marketing Strategy
- Marketing Strategy: ${model.hasMarketingStrategy ? 'Yes' : 'No'}
- Landing Pages for Campaigns: ${model.needsLandingPages ? 'Yes' : 'No'}
- Regular Content Updates: ${model.planningRegularUpdates ? 'Yes' : 'No'}

## 14. Competitor Analysis
- Top Competitors: ${model.topCompetitors.join(', ')}
${model.competitorFeedback.isNotEmpty ? '- Competitor Feedback: ' + model.competitorFeedback.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('; ') : ''}

## 15. Stakeholders & Approval Process
- Stakeholders: ${model.stakeholders.join(', ')}
- Final Approver: ${model.finalApprover}
- Feedback Method: ${model.feedbackMethod}

Create a professional, well-structured BRD document with an executive summary, detailed sections for each of the above areas, and a conclusion with next steps. Include any additional recommendations or best practices based on the provided requirements.
''';
  }
  
  // Create a prompt for a specific section
  String _createSectionPrompt(BRDModel model, String section) {
    switch (section) {
      case 'Executive Summary':
        return '''
Create an Executive Summary section for a Business Requirements Document (BRD) for ${model.companyName}'s website project.
The website's purpose is: ${model.websitePurpose}.
Key goals include: ${model.topGoals.join(', ')}.
Target audience: ${model.targetAudiences.join(', ')}.

Make it concise, professional, and highlight the core business needs and expected outcomes.
''';
      
      case 'Technical Requirements':
        return '''
Create a detailed Technical Requirements section for a Business Requirements Document (BRD) based on the following details:

- Preferred Tech Stack: ${model.preferredTechStack ?? 'Not specified'}
- Hosting/Domain Status: ${model.hasHostingDomain ? 'Already acquired' : 'Not acquired'}
- DNS Setup Assistance: ${model.needsDNSSetup ? 'Needed' : 'Not needed'}
- Expected Traffic: ${model.expectedTrafficLoad}
- Mobile-First Design: ${model.mobileFirstDesign ? 'Required' : 'Not required'}
- Accessibility Compliance: ${model.accessibilityCompliance ? 'Required' : 'Not required'}

Include appropriate subsections, technical specifications, architectural recommendations, and best practices for implementation.
''';
      
      // Add more cases for other sections
      
      default:
        return '''
Create a section on "$section" for a Business Requirements Document (BRD) for ${model.companyName}'s website project.
Include all relevant details, be thorough and professional, and provide actionable information.
''';
    }
  }
  
  // Generate project timeline and cost estimates based on BRD
  Future<Map<String, dynamic>> generateEstimates(BRDModel brdModel) async {
    try {
      // Create a prompt for estimates
      final String estimatePrompt = '''
Based on the following website project details, provide a detailed estimate of timeline (in weeks) and cost (in USD):

## Basic Info
- Website Type: ${brdModel.websitePurpose}
- Company: ${brdModel.companyName}

## Complexity Factors
- Features: ${brdModel.keyFeatures.entries.where((e) => e.value).map((e) => e.key).join(', ')}
- Pages: ${brdModel.essentialPages.join(', ')}
- Integrations: ${brdModel.integrations.join(', ')}
- Tech Requirements: ${brdModel.preferredTechStack ?? 'Not specified'}, Mobile-First: ${brdModel.mobileFirstDesign ? 'Yes' : 'No'}, Accessibility: ${brdModel.accessibilityCompliance ? 'Yes' : 'No'}
- Content Creation Needed: ${brdModel.hasExistingContent ? 'No' : 'Yes'}
- SEO Work Needed: ${brdModel.needsSEOContent || brdModel.needsSEOSetup ? 'Yes' : 'No'}

Generate a JSON object with:
1. A timeline breakdown by phase (discovery, design, development, testing, content, launch)
2. A cost breakdown by category (design, development, content, marketing, other)
3. Total timeline in weeks
4. Total cost in USD
5. Maintenance cost per month

Format the response as valid JSON only, no other text:
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a professional web project estimator with extensive experience in website development costs and timelines. Provide only JSON, no other text.'
            },
            {'role': 'user', 'content': estimatePrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to generate estimates: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error generating estimates: $e',
        'timelineTotal': 12,
        'costTotal': 20000,
        'maintenanceCost': 500
      };
    }
  }
  
  // Generate a client-facing document (simplified version of BRD)
  Future<String> generateClientProposal(BRDModel brdModel, Map<String, dynamic> estimates) async {
    try {
      // Create a prompt for the client proposal
      final String proposalPrompt = '''
Create a professional client proposal document for a website project with the following details:

## Client Information
- Company/Brand: ${brdModel.companyName}
- Project: ${brdModel.websitePurpose} website

## Project Understanding
- Primary Goals: ${brdModel.topGoals.join(', ')}
- Target Audience: ${brdModel.targetAudiences.join(', ')}

## Proposed Solution
- Key Features: ${brdModel.keyFeatures.entries.where((e) => e.value).map((e) => e.key).join(', ')}
- Main Pages: ${brdModel.essentialPages.join(', ')}
- Design Direction: ${brdModel.preferredLookAndFeel}

## Project Timeline
${estimates.containsKey('timelineBreakdown') ? '- Timeline Breakdown: ' + jsonEncode(estimates['timelineBreakdown']) : '- Estimated Timeline: ${estimates['timelineTotal']} weeks'}

## Investment
${estimates.containsKey('costBreakdown') ? '- Cost Breakdown: ' + jsonEncode(estimates['costBreakdown']) : '- Estimated Cost: \$${estimates['costTotal']}'}
- Monthly Maintenance: \$${estimates['maintenanceCost']} per month

## Next Steps
1. Review proposal
2. Sign agreement
3. Begin discovery phase

Format this as a professional client proposal in Markdown, including an introduction, the sections above, and a conclusion. Add any appropriate recommendations or notes based on the project details.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a professional web agency proposal writer with experience creating compelling client proposals for web projects. Format your output in Markdown.'
            },
            {'role': 'user', 'content': proposalPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2500,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('Failed to generate proposal: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return "Error generating client proposal: $e";
    }
  }
  
  // Generate execution steps for the plan of action
  Future<Map<String, dynamic>> generateExecutionSteps(BRDModel brdModel) async {
    try {
      // Create a prompt for execution steps
      final String executionPrompt = '''
Based on the following BRD details, provide detailed execution steps for implementing this plan of action:

## Project Basics
- Project: ${brdModel.websitePurpose}
- Company: ${brdModel.companyName}
- Goals: ${brdModel.topGoals.join(', ')}

## Project Components
- Features: ${brdModel.keyFeatures.entries.where((e) => e.value).map((e) => e.key).join(', ')}
- Pages: ${brdModel.essentialPages.join(', ')}
- Tech Requirements: ${brdModel.preferredTechStack ?? 'Not specified'}

Generate a JSON object with:
1. A list of phases (e.g., discovery, planning, design, development, testing, launch, post-launch)
2. For each phase, provide:
   - A detailed description
   - A list of specific tasks/steps
   - Required resources (skills, tools, etc.)
   - Expected duration
   - Key milestones/deliverables
   - Dependencies on other phases

Format the response as a valid JSON object.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a senior project manager with extensive experience in website and application implementation. Provide detailed execution steps in JSON format only.'
            },
            {'role': 'user', 'content': executionPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to generate execution steps: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error generating execution steps: $e',
        'phases': [
          {
            'name': 'Planning',
            'description': 'Initial planning phase',
            'tasks': ['Define requirements', 'Create project plan'],
            'duration': '2 weeks'
          }
        ]
      };
    }
  }
  
  // Generate potential risks and mitigation strategies
  Future<Map<String, dynamic>> generateRiskAssessment(BRDModel brdModel) async {
    try {
      // Create a prompt for risk assessment
      final String riskPrompt = '''
Based on the following BRD details, provide a comprehensive risk assessment for this project:

## Project Basics
- Project: ${brdModel.websitePurpose}
- Company: ${brdModel.companyName}
- Goals: ${brdModel.topGoals.join(', ')}

## Project Components
- Features: ${brdModel.keyFeatures.entries.where((e) => e.value).map((e) => e.key).join(', ')}
- Integrations: ${brdModel.integrations.join(', ')}
- Technical Stack: ${brdModel.preferredTechStack ?? 'Not specified'}
- Timeline: ${brdModel.preferredLaunchDate != null ? brdModel.preferredLaunchDate!.toIso8601String().split('T')[0] : 'Not specified'}

Generate a JSON object with:
1. A list of potential risks categorized by type (technical, business, schedule, resource, etc.)
2. For each risk, provide:
   - A description of the risk
   - Probability (Low, Medium, High)
   - Impact (Low, Medium, High)
   - Overall risk rating
   - Detailed mitigation strategies
   - Contingency plans

Format the response as a valid JSON object.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a risk management specialist with extensive experience in website and application projects. Provide a detailed risk assessment in JSON format only.'
            },
            {'role': 'user', 'content': riskPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to generate risk assessment: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error generating risk assessment: $e',
        'risks': [
          {
            'type': 'Technical',
            'description': 'Integration issues with existing systems',
            'probability': 'Medium',
            'impact': 'High',
            'rating': 'High',
            'mitigation': 'Early testing and validation'
          }
        ]
      };
    }
  }
  
  // Generate potential earnings and ROI
  Future<Map<String, dynamic>> generateEarningsProjection(BRDModel brdModel, Map<String, dynamic> estimates) async {
    try {
      // Create a prompt for earnings projection
      final String earningsPrompt = '''
Based on the following BRD details and cost estimates, provide a comprehensive earnings projection and ROI analysis:

## Project Basics
- Project: ${brdModel.websitePurpose}
- Company: ${brdModel.companyName}
- Goals: ${brdModel.topGoals.join(', ')}
- Target Audience: ${brdModel.targetAudiences.join(', ')}

## Financial Details
- Implementation Cost: \$${estimates['costTotal'] ?? '20000'}
- Monthly Maintenance: \$${estimates['maintenanceCost'] ?? '500'}
- Timeline to Launch: ${estimates['timelineTotal'] ?? '12'} weeks

## Expected Business Outcomes
- Key Metrics: ${brdModel.keyMetrics.join(', ')}
- Key Conversions: ${brdModel.keyConversions.join(', ')}

Generate a JSON object with:
1. Projected earnings for 3 years (broken down by year and quarter)
2. Multiple scenarios (pessimistic, realistic, optimistic)
3. Key revenue sources and growth metrics
4. Expected ROI (Return on Investment) over time
5. Break-even analysis
6. Recommendations for maximizing earnings

Format the response as a valid JSON object.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a financial analyst specializing in digital projects and ROI forecasting. Provide detailed earnings projections in JSON format only.'
            },
            {'role': 'user', 'content': earningsPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to generate earnings projection: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error generating earnings projection: $e',
        'projections': {
          'year1': {
            'total': 30000,
            'roi': '50%',
            'breakEven': '8 months'
          }
        }
      };
    }
  }
  
  // Generate estimates from uploaded text content
  Future<Map<String, dynamic>> generateEstimatesFromText(String textContent) async {
    try {
      // Create a prompt for estimates from text
      final String estimatePrompt = '''
Based on the following Business Requirements Document text, provide a detailed estimate of timeline (in weeks) and cost (in USD):

$textContent

Generate a JSON object with:
1. A timeline breakdown by phase (discovery, design, development, testing, content, launch)
2. A cost breakdown by category (design, development, content, marketing, other)
3. Total timeline in weeks
4. Total cost in USD
5. Maintenance cost per month
6. Estimated hours required to complete the project
7. Suggested hourly rate
8. Risk factor (Low, Medium, High)
9. Complexity level (Low, Medium, High)
10. Required skills (array of skill names)

Format the response as valid JSON only, no other text.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a professional web project estimator with extensive experience in website development costs and timelines. Provide only JSON, no other text.'
            },
            {'role': 'user', 'content': estimatePrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to generate estimates: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error generating estimates: $e',
        'timelineTotal': 12,
        'costTotal': 20000,
        'maintenanceCost': 500,
        'estimatedHours': 160,
        'suggestedRate': 50,
        'riskFactor': 'Medium',
        'complexityLevel': 'Medium',
        'skillsRequired': ['Web Development', 'Design', 'Project Management'],
        'timelineBreakdown': {
          'Discovery': 2,
          'Design': 3,
          'Development': 4,
          'Testing': 2,
          'Launch': 1
        },
        'costBreakdown': {
          'Design': 5000,
          'Development': 10000,
          'Content': 2000,
          'Testing': 2000,
          'Other': 1000
        }
      };
    }
  }
  
  // Extract potential execution steps from BRD text
  Future<Map<String, dynamic>> extractExecutionStepsFromText(String textContent) async {
    try {
      // Create a prompt to extract execution steps
      final String executionPrompt = '''
Based on the following Business Requirements Document text, extract detailed execution steps for implementing this project:

$textContent

Generate a JSON object with:
1. A list of phases (e.g., discovery, planning, design, development, testing, launch, post-launch)
2. For each phase, provide:
   - A detailed description
   - A list of specific tasks/steps
   - Required resources (skills, tools, etc.)
   - Expected duration
   - Key milestones/deliverables
   - Dependencies on other phases

Format the response as a valid JSON object only, no other text.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a senior project manager with extensive experience in website and application implementation. Provide detailed execution steps in JSON format only.'
            },
            {'role': 'user', 'content': executionPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to extract execution steps: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error extracting execution steps: $e',
        'phases': [
          {
            'name': 'Planning',
            'description': 'Initial planning phase',
            'tasks': ['Define requirements', 'Create project plan'],
            'duration': '2 weeks',
            'resources': ['Project Manager', 'Business Analyst'],
            'deliverables': ['Project Plan', 'Requirements Document'],
            'dependencies': []
          }
        ]
      };
    }
  }
  
  // Extract potential risks from BRD text
  Future<Map<String, dynamic>> extractRisksFromText(String textContent) async {
    try {
      // Create a prompt to extract risks
      final String riskPrompt = '''
Based on the following Business Requirements Document text, identify potential risks for this project:

$textContent

Generate a JSON object with:
1. A list of potential risks categorized by type (technical, business, schedule, resource, etc.)
2. For each risk, provide:
   - A description of the risk
   - Probability (Low, Medium, High)
   - Impact (Low, Medium, High)
   - Overall risk rating
   - Detailed mitigation strategies
   - Contingency plans

Format the response as a valid JSON object only, no other text.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a risk management specialist with extensive experience in website and application projects. Provide a detailed risk assessment in JSON format only.'
            },
            {'role': 'user', 'content': riskPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to extract risks: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return {
        'error': 'Error extracting risks: $e',
        'risks': [
          {
            'type': 'Technical',
            'description': 'Integration issues with existing systems',
            'probability': 'Medium',
            'impact': 'High',
            'rating': 'High',
            'mitigation': 'Early testing and validation',
            'contingency': 'Develop backup integration approach'
          }
        ]
      };
    }
  }
  
  // Generate a simple earnings projection from estimates
  Future<Map<String, dynamic>> generateSimpleEarningsProjection(Map<String, dynamic> estimates) async {
    try {
      // Create a prompt for earnings projection
      final String earningsPrompt = '''
Based on the following cost estimates, provide a comprehensive earnings projection and ROI analysis:

## Financial Details
- Implementation Cost: \$${estimates['costTotal'] ?? '20000'}
- Monthly Maintenance: \$${estimates['maintenanceCost'] ?? '500'}
- Timeline to Launch: ${estimates['timelineTotal'] ?? '12'} weeks
- Risk Factor: ${estimates['riskFactor'] ?? 'Medium'}
- Complexity Level: ${estimates['complexityLevel'] ?? 'Medium'}

Generate a JSON object with:
1. Projected earnings for 3 years (broken down by year and quarter)
2. Multiple scenarios (pessimistic, realistic, optimistic)
3. Key revenue sources and growth metrics
4. Expected ROI (Return on Investment) over time
5. Break-even analysis
6. Recommendations for maximizing earnings

Format the response as a valid JSON object only, no other text.
''';
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a financial analyst specializing in digital projects and ROI forecasting. Provide detailed earnings projections in JSON format only.'
            },
            {'role': 'user', 'content': earningsPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from the response
        final jsonRegExp = RegExp(r'{[\s\S]*}');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return jsonDecode(jsonStr);
          }
        }
        throw Exception('Could not parse JSON response');
      } else {
        throw Exception('Failed to generate earnings projection: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Return a simplified fallback projection
      final double costTotal = (estimates['costTotal'] as num?)?.toDouble() ?? 20000;
      final double monthlyMaintenance = (estimates['maintenanceCost'] as num?)?.toDouble() ?? 500;
      
      return {
        'error': 'Error generating earnings projection: $e',
        'roi': '150%',
        'breakEven': '8 months',
        'scenarios': {
          'pessimistic': '\$${(costTotal * 1.2).toStringAsFixed(0)}',
          'realistic': '\$${(costTotal * 2).toStringAsFixed(0)}',
          'optimistic': '\$${(costTotal * 3).toStringAsFixed(0)}'
        },
        'projections': {
          'year1': {
            'total': costTotal * 1.5,
            'roi': '50%',
            'quarters': {
              'q1': costTotal * 0.2,
              'q2': costTotal * 0.3,
              'q3': costTotal * 0.4,
              'q4': costTotal * 0.6
            }
          },
          'year2': {
            'total': costTotal * 2.5,
            'roi': '150%',
            'quarters': {
              'q1': costTotal * 0.5,
              'q2': costTotal * 0.6,
              'q3': costTotal * 0.7,
              'q4': costTotal * 0.7
            }
          },
          'year3': {
            'total': costTotal * 3.5,
            'roi': '250%',
            'quarters': {
              'q1': costTotal * 0.8,
              'q2': costTotal * 0.9,
              'q3': costTotal * 0.9,
              'q4': costTotal * 0.9
            }
          }
        },
        'recommendations': [
          'Invest in SEO to maximize organic traffic',
          'Implement conversion rate optimization strategies',
          'Consider upselling additional services to increase revenue',
          'Monitor and reduce customer acquisition costs',
          'Regularly update content to maintain relevance'
        ]
      };
    }
  }
} 