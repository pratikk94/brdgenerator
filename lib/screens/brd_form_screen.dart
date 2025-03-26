import 'package:flutter/material.dart';
import '../models/brd_model.dart';
import '../services/brd_generator_service.dart';
import 'brd_result_screen.dart';

class BRDFormScreen extends StatefulWidget {
  @override
  _BRDFormScreenState createState() => _BRDFormScreenState();
}

class _BRDFormScreenState extends State<BRDFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BRDModel _brdModel = BRDModel.empty();
  final BRDGeneratorService _generatorService = BRDGeneratorService();
  
  // Controllers for text fields
  final _companyNameController = TextEditingController();
  final _websitePurposeController = TextEditingController();
  final _existingWebsiteController = TextEditingController();
  final _targetAudiencesController = TextEditingController();
  final _topGoalsController = TextEditingController();
  final _keyMetricsController = TextEditingController();
  final _preferredLookAndFeelController = TextEditingController();
  final _websitesLikedController = TextEditingController();
  final _designElementsToAvoidController = TextEditingController();
  final _integrationsController = TextEditingController();
  final _essentialPagesController = TextEditingController();
  final _userJourneyController = TextEditingController();
  final _callToActionsController = TextEditingController();
  final _keyConversionsController = TextEditingController();
  final _preferredTechStackController = TextEditingController();
  final _expectedTrafficLoadController = TextEditingController();
  final _preferredCMSController = TextEditingController();
  final _editablePartsController = TextEditingController();
  final _contentManagerController = TextEditingController();
  final _updateFrequencyController = TextEditingController();
  final _importantMilestonesController = TextEditingController();
  final _budgetRangeController = TextEditingController();
  final _complianceRequirementsController = TextEditingController();
  final _topCompetitorsController = TextEditingController();
  final _stakeholdersController = TextEditingController();
  final _finalApproverController = TextEditingController();
  final _feedbackMethodController = TextEditingController();
  
  DateTime? _preferredLaunchDate;
  Map<String, bool> _keyFeatures = {
    'Contact form': false,
    'Newsletter signup': false,
    'Blog': false,
    'E-commerce': false,
    'Booking system': false,
    'User login': false,
    'Admin Panel': false,
    'Search functionality': false,
    'Chatbot/live chat': false,
    'Downloadable resources': false,
    'Testimonials/Reviews': false,
  };
  
  bool _isGenerating = false;
  int _currentStep = 0;
  
  @override
  void dispose() {
    // Dispose all controllers
    _companyNameController.dispose();
    _websitePurposeController.dispose();
    _existingWebsiteController.dispose();
    _targetAudiencesController.dispose();
    _topGoalsController.dispose();
    _keyMetricsController.dispose();
    _preferredLookAndFeelController.dispose();
    _websitesLikedController.dispose();
    _designElementsToAvoidController.dispose();
    _integrationsController.dispose();
    _essentialPagesController.dispose();
    _userJourneyController.dispose();
    _callToActionsController.dispose();
    _keyConversionsController.dispose();
    _preferredTechStackController.dispose();
    _expectedTrafficLoadController.dispose();
    _preferredCMSController.dispose();
    _editablePartsController.dispose();
    _contentManagerController.dispose();
    _updateFrequencyController.dispose();
    _importantMilestonesController.dispose();
    _budgetRangeController.dispose();
    _complianceRequirementsController.dispose();
    _topCompetitorsController.dispose();
    _stakeholdersController.dispose();
    _finalApproverController.dispose();
    _feedbackMethodController.dispose();
    super.dispose();
  }
  
  // Helper method to parse comma-separated values to a list
  List<String> _parseCSV(String text) {
    if (text.isEmpty) return [];
    return text.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }
  
  // Create BRD model from form inputs
  BRDModel _createModelFromForm() {
    return BRDModel(
      companyName: _companyNameController.text,
      websitePurpose: _websitePurposeController.text,
      existingWebsite: _existingWebsiteController.text,
      targetAudiences: _parseCSV(_targetAudiencesController.text),
      topGoals: _parseCSV(_topGoalsController.text),
      keyMetrics: _parseCSV(_keyMetricsController.text),
      hasExistingBranding: false, // from toggle or checkbox
      brandingDetails: '', // optional
      preferredLookAndFeel: _preferredLookAndFeelController.text,
      websitesLiked: _parseCSV(_websitesLikedController.text),
      designElementsToAvoid: _parseCSV(_designElementsToAvoidController.text),
      keyFeatures: _keyFeatures,
      integrations: _parseCSV(_integrationsController.text),
      multiLanguageSupport: false, // from toggle or checkbox
      essentialPages: _parseCSV(_essentialPagesController.text),
      hasExistingContent: false, // from toggle or checkbox
      needsMediaAssets: false, // from toggle or checkbox
      needsSEOContent: false, // from toggle or checkbox
      userJourney: _userJourneyController.text,
      callToActions: _parseCSV(_callToActionsController.text),
      keyConversions: _parseCSV(_keyConversionsController.text),
      preferredTechStack: _preferredTechStackController.text.isEmpty ? null : _preferredTechStackController.text,
      hasHostingDomain: false, // from toggle or checkbox
      needsDNSSetup: false, // from toggle or checkbox
      expectedTrafficLoad: _expectedTrafficLoadController.text,
      mobileFirstDesign: true, // from toggle or checkbox
      accessibilityCompliance: false, // from toggle or checkbox
      preferredCMS: _preferredCMSController.text.isEmpty ? null : _preferredCMSController.text,
      editableParts: _parseCSV(_editablePartsController.text),
      contentManager: _contentManagerController.text,
      needsSEOSetup: false, // from toggle or checkbox
      needsKeywordResearch: false, // from toggle or checkbox
      needsAnalyticsIntegration: false, // from toggle or checkbox
      needsSchemaMarkup: false, // from toggle or checkbox
      needsOngoingMaintenance: false, // from toggle or checkbox
      updateFrequency: _updateFrequencyController.text,
      needsBackupRecovery: false, // from toggle or checkbox
      preferredLaunchDate: _preferredLaunchDate,
      importantMilestones: _parseCSV(_importantMilestonesController.text),
      budgetRange: _budgetRangeController.text.isEmpty ? null : _budgetRangeController.text,
      needsLegalPages: false, // from toggle or checkbox
      complianceRequirements: _parseCSV(_complianceRequirementsController.text),
      hasMarketingStrategy: false, // from toggle or checkbox
      needsLandingPages: false, // from toggle or checkbox
      planningRegularUpdates: false, // from toggle or checkbox
      topCompetitors: _parseCSV(_topCompetitorsController.text),
      competitorFeedback: {}, // more complex UI needed
      stakeholders: _parseCSV(_stakeholdersController.text),
      finalApprover: _finalApproverController.text,
      feedbackMethod: _feedbackMethodController.text,
    );
  }
  
  // Generate BRD and navigate to results screen
  void _generateBRD() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isGenerating = true;
      });
      
      final brdModel = _createModelFromForm();
      
      try {
        // Generate BRD document
        final brdContent = await _generatorService.generateBRDDocument(brdModel);
        
        // Generate estimates
        final estimates = await _generatorService.generateEstimates(brdModel);
        
        // Generate execution steps
        final executionSteps = await _generatorService.generateExecutionSteps(brdModel);
        
        // Generate risk assessment
        final riskAssessment = await _generatorService.generateRiskAssessment(brdModel);
        
        // Generate earnings projection
        final earningsProjection = await _generatorService.generateEarningsProjection(brdModel, estimates);
        
        // Generate client proposal
        final proposalContent = await _generatorService.generateClientProposal(brdModel, estimates);
        
        // Navigate to results screen with generated content
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BRDResultScreen(
                brdContent: brdContent,
                proposalContent: proposalContent,
                estimates: estimates,
                executionSteps: executionSteps,
                riskAssessment: riskAssessment,
                earningsProjection: earningsProjection,
              ),
            ),
          );
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating BRD: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BRD Generator'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          onStepContinue: () {
            if (_currentStep < 7) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _generateBRD();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: [
            // Step 1: Basic Information
            Step(
              title: Text('Basic Information'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _companyNameController,
                    decoration: InputDecoration(
                      labelText: 'Company/Brand Name *',
                      hintText: 'Enter company or brand name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _websitePurposeController,
                    decoration: InputDecoration(
                      labelText: 'Website Purpose *',
                      hintText: 'E.g., E-commerce, Informational, Lead Generation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter website purpose';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _existingWebsiteController,
                    decoration: InputDecoration(
                      labelText: 'Existing Website (if any)',
                      hintText: 'Enter URL if you have an existing website',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _targetAudiencesController,
                    decoration: InputDecoration(
                      labelText: 'Target Audiences *',
                      hintText: 'Enter target audiences, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one target audience';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            
            // Step 2: Goals and Objectives
            Step(
              title: Text('Goals and Objectives'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _topGoalsController,
                    decoration: InputDecoration(
                      labelText: 'Top Goals *',
                      hintText: 'Enter goals, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one goal';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _keyMetricsController,
                    decoration: InputDecoration(
                      labelText: 'Key Metrics',
                      hintText: 'Enter metrics to track, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            
            // Step 3: Design and Branding
            Step(
              title: Text('Design and Branding'),
              content: Column(
                children: [
                  SwitchListTile(
                    title: Text('Has Existing Branding?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _preferredLookAndFeelController,
                    decoration: InputDecoration(
                      labelText: 'Preferred Look and Feel',
                      hintText: 'E.g., Minimal, Bold, Elegant, Corporate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _websitesLikedController,
                    decoration: InputDecoration(
                      labelText: 'Websites You Like',
                      hintText: 'Enter websites URLs, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _designElementsToAvoidController,
                    decoration: InputDecoration(
                      labelText: 'Design Elements to Avoid',
                      hintText: 'Enter design elements to avoid, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
            
            // Step 4: Features and Functionality
            Step(
              title: Text('Features and Functionality'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ..._keyFeatures.keys.map((feature) {
                    return CheckboxListTile(
                      title: Text(feature),
                      value: _keyFeatures[feature],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _keyFeatures[feature] = value;
                          });
                        }
                      },
                    );
                  }).toList(),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _integrationsController,
                    decoration: InputDecoration(
                      labelText: 'Integrations',
                      hintText: 'Enter needed integrations, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Multi-language Support?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 3,
            ),
            
            // Step 5: Pages and Content
            Step(
              title: Text('Pages and Content'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _essentialPagesController,
                    decoration: InputDecoration(
                      labelText: 'Essential Pages *',
                      hintText: 'Enter pages, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one page';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Has Existing Content?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                  SwitchListTile(
                    title: Text('Needs Media Assets?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                  SwitchListTile(
                    title: Text('Needs SEO-Optimized Content?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 4,
            ),
            
            // Step 6: User Experience & Technical Requirements
            Step(
              title: Text('User Experience & Technical'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _userJourneyController,
                    decoration: InputDecoration(
                      labelText: 'User Journey',
                      hintText: 'Describe the ideal user journey on the website',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _callToActionsController,
                    decoration: InputDecoration(
                      labelText: 'Call-to-Actions',
                      hintText: 'Enter CTAs, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _keyConversionsController,
                    decoration: InputDecoration(
                      labelText: 'Key Conversions',
                      hintText: 'Enter key conversions, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _preferredTechStackController,
                    decoration: InputDecoration(
                      labelText: 'Preferred Tech Stack (if any)',
                      hintText: 'E.g., WordPress, React, etc.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _expectedTrafficLoadController,
                    decoration: InputDecoration(
                      labelText: 'Expected Traffic Load',
                      hintText: 'E.g., Low, Medium, High, or specific numbers',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Mobile-First Design?'),
                    value: true,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                  SwitchListTile(
                    title: Text('Accessibility Compliance?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 5,
            ),
            
            // Step 7: CMS & Maintenance
            Step(
              title: Text('CMS & Maintenance'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _preferredCMSController,
                    decoration: InputDecoration(
                      labelText: 'Preferred CMS (if any)',
                      hintText: 'E.g., WordPress, Shopify, Custom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _editablePartsController,
                    decoration: InputDecoration(
                      labelText: 'Editable Parts',
                      hintText: 'Enter parts of the site that should be editable',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contentManagerController,
                    decoration: InputDecoration(
                      labelText: 'Content Manager',
                      hintText: 'Who will manage the content post-launch?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Needs Ongoing Maintenance?'),
                    value: false,
                    onChanged: (value) {
                      // Update state
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _updateFrequencyController,
                    decoration: InputDecoration(
                      labelText: 'Update Frequency',
                      hintText: 'E.g., Weekly, Monthly',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 6,
            ),
            
            // Step 8: Timeline & Stakeholders
            Step(
              title: Text('Timeline & Stakeholders'),
              content: Column(
                children: [
                  ListTile(
                    title: Text('Preferred Launch Date'),
                    subtitle: Text(_preferredLaunchDate != null 
                                  ? _preferredLaunchDate!.toString().split(' ')[0] 
                                  : 'Not set'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 90)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setState(() {
                          _preferredLaunchDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _importantMilestonesController,
                    decoration: InputDecoration(
                      labelText: 'Important Milestones',
                      hintText: 'Enter important milestones, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _budgetRangeController,
                    decoration: InputDecoration(
                      labelText: 'Budget Range',
                      hintText: 'Enter budget range if available',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _stakeholdersController,
                    decoration: InputDecoration(
                      labelText: 'Stakeholders',
                      hintText: 'Enter stakeholders, separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _finalApproverController,
                    decoration: InputDecoration(
                      labelText: 'Final Approver',
                      hintText: 'Who has the final say on approvals?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _feedbackMethodController,
                    decoration: InputDecoration(
                      labelText: 'Feedback Method',
                      hintText: 'E.g., Email, Slack, Trello',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 7,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isGenerating ? null : _generateBRD,
          child: _isGenerating
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Generating...'),
                  ],
                )
              : Text('Generate BRD'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
} 