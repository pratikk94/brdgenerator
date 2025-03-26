class BRDDocument {
  final String title;
  final String content;
  final DateTime createdAt;

  BRDDocument({
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory BRDDocument.fromJson(Map<String, dynamic> json) {
    return BRDDocument(
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BRDModel {
  // Basic Information
  final String companyName;
  final String websitePurpose;
  final String existingWebsite;
  final List<String> targetAudiences;

  // Goals and Objectives
  final List<String> topGoals;
  final List<String> keyMetrics;

  // Design and Branding
  final bool hasExistingBranding;
  final String? brandingDetails;
  final String preferredLookAndFeel;
  final List<String> websitesLiked;
  final List<String> designElementsToAvoid;

  // Features and Functionality
  final Map<String, bool> keyFeatures;
  final List<String> integrations;
  final bool multiLanguageSupport;

  // Pages and Content
  final List<String> essentialPages;
  final bool hasExistingContent;
  final bool needsMediaAssets;
  final bool needsSEOContent;

  // User Experience & Flow
  final String userJourney;
  final List<String> callToActions;
  final List<String> keyConversions;

  // Technical Requirements
  final String? preferredTechStack;
  final bool hasHostingDomain;
  final bool needsDNSSetup;
  final String expectedTrafficLoad;
  final bool mobileFirstDesign;
  final bool accessibilityCompliance;

  // CMS & Admin Capabilities
  final String? preferredCMS;
  final List<String> editableParts;
  final String contentManager;

  // SEO & Analytics
  final bool needsSEOSetup;
  final bool needsKeywordResearch;
  final bool needsAnalyticsIntegration;
  final bool needsSchemaMarkup;

  // Maintenance & Support
  final bool needsOngoingMaintenance;
  final String updateFrequency;
  final bool needsBackupRecovery;

  // Timeline & Budget
  final DateTime? preferredLaunchDate;
  final List<String> importantMilestones;
  final String? budgetRange;

  // Legal and Compliance
  final bool needsLegalPages;
  final List<String> complianceRequirements;

  // Content & Marketing Strategy
  final bool hasMarketingStrategy;
  final bool needsLandingPages;
  final bool planningRegularUpdates;

  // Competitor Analysis
  final List<String> topCompetitors;
  final Map<String, List<String>> competitorFeedback;

  // Stakeholders & Approval Process
  final List<String> stakeholders;
  final String finalApprover;
  final String feedbackMethod;

  BRDModel({
    required this.companyName,
    required this.websitePurpose,
    required this.existingWebsite,
    required this.targetAudiences,
    required this.topGoals,
    required this.keyMetrics,
    required this.hasExistingBranding,
    this.brandingDetails,
    required this.preferredLookAndFeel,
    required this.websitesLiked,
    required this.designElementsToAvoid,
    required this.keyFeatures,
    required this.integrations,
    required this.multiLanguageSupport,
    required this.essentialPages,
    required this.hasExistingContent,
    required this.needsMediaAssets,
    required this.needsSEOContent,
    required this.userJourney,
    required this.callToActions,
    required this.keyConversions,
    this.preferredTechStack,
    required this.hasHostingDomain,
    required this.needsDNSSetup,
    required this.expectedTrafficLoad,
    required this.mobileFirstDesign,
    required this.accessibilityCompliance,
    this.preferredCMS,
    required this.editableParts,
    required this.contentManager,
    required this.needsSEOSetup,
    required this.needsKeywordResearch,
    required this.needsAnalyticsIntegration,
    required this.needsSchemaMarkup,
    required this.needsOngoingMaintenance,
    required this.updateFrequency,
    required this.needsBackupRecovery,
    this.preferredLaunchDate,
    required this.importantMilestones,
    this.budgetRange,
    required this.needsLegalPages,
    required this.complianceRequirements,
    required this.hasMarketingStrategy,
    required this.needsLandingPages,
    required this.planningRegularUpdates,
    required this.topCompetitors,
    required this.competitorFeedback,
    required this.stakeholders,
    required this.finalApprover,
    required this.feedbackMethod,
  });

  // Factory method to create an empty BRD model with default values
  factory BRDModel.empty() {
    return BRDModel(
      companyName: '',
      websitePurpose: '',
      existingWebsite: '',
      targetAudiences: [],
      topGoals: [],
      keyMetrics: [],
      hasExistingBranding: false,
      preferredLookAndFeel: '',
      websitesLiked: [],
      designElementsToAvoid: [],
      keyFeatures: {
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
      },
      integrations: [],
      multiLanguageSupport: false,
      essentialPages: [],
      hasExistingContent: false,
      needsMediaAssets: false,
      needsSEOContent: false,
      userJourney: '',
      callToActions: [],
      keyConversions: [],
      hasHostingDomain: false,
      needsDNSSetup: false,
      expectedTrafficLoad: '',
      mobileFirstDesign: true,
      accessibilityCompliance: false,
      editableParts: [],
      contentManager: '',
      needsSEOSetup: false,
      needsKeywordResearch: false,
      needsAnalyticsIntegration: false,
      needsSchemaMarkup: false,
      needsOngoingMaintenance: false,
      updateFrequency: '',
      needsBackupRecovery: false,
      importantMilestones: [],
      needsLegalPages: false,
      complianceRequirements: [],
      hasMarketingStrategy: false,
      needsLandingPages: false,
      planningRegularUpdates: false,
      topCompetitors: [],
      competitorFeedback: {},
      stakeholders: [],
      finalApprover: '',
      feedbackMethod: '',
    );
  }

  // Convert the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'basicInformation': {
        'companyName': companyName,
        'websitePurpose': websitePurpose,
        'existingWebsite': existingWebsite,
        'targetAudiences': targetAudiences,
      },
      'goalsAndObjectives': {
        'topGoals': topGoals,
        'keyMetrics': keyMetrics,
      },
      'designAndBranding': {
        'hasExistingBranding': hasExistingBranding,
        'brandingDetails': brandingDetails,
        'preferredLookAndFeel': preferredLookAndFeel,
        'websitesLiked': websitesLiked,
        'designElementsToAvoid': designElementsToAvoid,
      },
      'featuresAndFunctionality': {
        'keyFeatures': keyFeatures,
        'integrations': integrations,
        'multiLanguageSupport': multiLanguageSupport,
      },
      'pagesAndContent': {
        'essentialPages': essentialPages,
        'hasExistingContent': hasExistingContent,
        'needsMediaAssets': needsMediaAssets,
        'needsSEOContent': needsSEOContent,
      },
      'userExperienceAndFlow': {
        'userJourney': userJourney,
        'callToActions': callToActions,
        'keyConversions': keyConversions,
      },
      'technicalRequirements': {
        'preferredTechStack': preferredTechStack,
        'hasHostingDomain': hasHostingDomain,
        'needsDNSSetup': needsDNSSetup,
        'expectedTrafficLoad': expectedTrafficLoad,
        'mobileFirstDesign': mobileFirstDesign,
        'accessibilityCompliance': accessibilityCompliance,
      },
      'cmsAndAdminCapabilities': {
        'preferredCMS': preferredCMS,
        'editableParts': editableParts,
        'contentManager': contentManager,
      },
      'seoAndAnalytics': {
        'needsSEOSetup': needsSEOSetup,
        'needsKeywordResearch': needsKeywordResearch,
        'needsAnalyticsIntegration': needsAnalyticsIntegration,
        'needsSchemaMarkup': needsSchemaMarkup,
      },
      'maintenanceAndSupport': {
        'needsOngoingMaintenance': needsOngoingMaintenance,
        'updateFrequency': updateFrequency,
        'needsBackupRecovery': needsBackupRecovery,
      },
      'timelineAndBudget': {
        'preferredLaunchDate': preferredLaunchDate?.toIso8601String(),
        'importantMilestones': importantMilestones,
        'budgetRange': budgetRange,
      },
      'legalAndCompliance': {
        'needsLegalPages': needsLegalPages,
        'complianceRequirements': complianceRequirements,
      },
      'contentAndMarketingStrategy': {
        'hasMarketingStrategy': hasMarketingStrategy,
        'needsLandingPages': needsLandingPages,
        'planningRegularUpdates': planningRegularUpdates,
      },
      'competitorAnalysis': {
        'topCompetitors': topCompetitors,
        'competitorFeedback': competitorFeedback,
      },
      'stakeholdersAndApprovalProcess': {
        'stakeholders': stakeholders,
        'finalApprover': finalApprover,
        'feedbackMethod': feedbackMethod,
      },
    };
  }

  // Create a model from JSON map
  factory BRDModel.fromJson(Map<String, dynamic> json) {
    final basicInfo = json['basicInformation'] as Map<String, dynamic>;
    final goals = json['goalsAndObjectives'] as Map<String, dynamic>;
    final design = json['designAndBranding'] as Map<String, dynamic>;
    final features = json['featuresAndFunctionality'] as Map<String, dynamic>;
    final pages = json['pagesAndContent'] as Map<String, dynamic>;
    final ux = json['userExperienceAndFlow'] as Map<String, dynamic>;
    final tech = json['technicalRequirements'] as Map<String, dynamic>;
    final cms = json['cmsAndAdminCapabilities'] as Map<String, dynamic>;
    final seo = json['seoAndAnalytics'] as Map<String, dynamic>;
    final maintenance = json['maintenanceAndSupport'] as Map<String, dynamic>;
    final timeline = json['timelineAndBudget'] as Map<String, dynamic>;
    final legal = json['legalAndCompliance'] as Map<String, dynamic>;
    final marketing = json['contentAndMarketingStrategy'] as Map<String, dynamic>;
    final competitors = json['competitorAnalysis'] as Map<String, dynamic>;
    final stakeholders = json['stakeholdersAndApprovalProcess'] as Map<String, dynamic>;

    return BRDModel(
      companyName: basicInfo['companyName'] as String,
      websitePurpose: basicInfo['websitePurpose'] as String,
      existingWebsite: basicInfo['existingWebsite'] as String,
      targetAudiences: List<String>.from(basicInfo['targetAudiences'] as List),
      topGoals: List<String>.from(goals['topGoals'] as List),
      keyMetrics: List<String>.from(goals['keyMetrics'] as List),
      hasExistingBranding: design['hasExistingBranding'] as bool,
      brandingDetails: design['brandingDetails'] as String?,
      preferredLookAndFeel: design['preferredLookAndFeel'] as String,
      websitesLiked: List<String>.from(design['websitesLiked'] as List),
      designElementsToAvoid: List<String>.from(design['designElementsToAvoid'] as List),
      keyFeatures: Map<String, bool>.from(features['keyFeatures'] as Map),
      integrations: List<String>.from(features['integrations'] as List),
      multiLanguageSupport: features['multiLanguageSupport'] as bool,
      essentialPages: List<String>.from(pages['essentialPages'] as List),
      hasExistingContent: pages['hasExistingContent'] as bool,
      needsMediaAssets: pages['needsMediaAssets'] as bool,
      needsSEOContent: pages['needsSEOContent'] as bool,
      userJourney: ux['userJourney'] as String,
      callToActions: List<String>.from(ux['callToActions'] as List),
      keyConversions: List<String>.from(ux['keyConversions'] as List),
      preferredTechStack: tech['preferredTechStack'] as String?,
      hasHostingDomain: tech['hasHostingDomain'] as bool,
      needsDNSSetup: tech['needsDNSSetup'] as bool,
      expectedTrafficLoad: tech['expectedTrafficLoad'] as String,
      mobileFirstDesign: tech['mobileFirstDesign'] as bool,
      accessibilityCompliance: tech['accessibilityCompliance'] as bool,
      preferredCMS: cms['preferredCMS'] as String?,
      editableParts: List<String>.from(cms['editableParts'] as List),
      contentManager: cms['contentManager'] as String,
      needsSEOSetup: seo['needsSEOSetup'] as bool,
      needsKeywordResearch: seo['needsKeywordResearch'] as bool,
      needsAnalyticsIntegration: seo['needsAnalyticsIntegration'] as bool,
      needsSchemaMarkup: seo['needsSchemaMarkup'] as bool,
      needsOngoingMaintenance: maintenance['needsOngoingMaintenance'] as bool,
      updateFrequency: maintenance['updateFrequency'] as String,
      needsBackupRecovery: maintenance['needsBackupRecovery'] as bool,
      preferredLaunchDate: timeline['preferredLaunchDate'] != null
          ? DateTime.parse(timeline['preferredLaunchDate'] as String)
          : null,
      importantMilestones: List<String>.from(timeline['importantMilestones'] as List),
      budgetRange: timeline['budgetRange'] as String?,
      needsLegalPages: legal['needsLegalPages'] as bool,
      complianceRequirements: List<String>.from(legal['complianceRequirements'] as List),
      hasMarketingStrategy: marketing['hasMarketingStrategy'] as bool,
      needsLandingPages: marketing['needsLandingPages'] as bool,
      planningRegularUpdates: marketing['planningRegularUpdates'] as bool,
      topCompetitors: List<String>.from(competitors['topCompetitors'] as List),
      competitorFeedback: Map<String, List<String>>.from(
        (competitors['competitorFeedback'] as Map).map(
          (key, value) => MapEntry(key as String, List<String>.from(value as List)),
        ),
      ),
      stakeholders: List<String>.from(stakeholders['stakeholders'] as List),
      finalApprover: stakeholders['finalApprover'] as String,
      feedbackMethod: stakeholders['feedbackMethod'] as String,
    );
  }
} 