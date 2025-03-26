import 'dart:convert';

class BRDRequirementsForm {
  // Basic Information
  String? companyName;
  String? websitePurpose;
  String? existingWebsite;
  String? primaryAudience;
  String? secondaryAudience;

  // Goals and Objectives
  List<String> websiteGoals = [];
  List<String> kpiMetrics = [];

  // Design and Branding
  bool hasExistingBranding;
  String? preferredStyle;
  List<String> websitesLiked = [];
  String? designElementsToAvoid;

  // Features and Functionality
  Map<String, bool> features = {
    'Contact Form': false,
    'Newsletter Signup': false,
    'Blog': false,
    'E-commerce': false,
    'Booking System': false,
    'User Login': false,
    'Admin Panel': false,
    'Search Functionality': false,
    'Chatbot': false,
    'Downloadable Resources': false,
    'Testimonials': false,
  };
  List<String> requiredIntegrations = [];
  bool multiLanguageSupport;

  // Pages and Content
  List<String> essentialPages = [];
  String? contentStatus;
  String? mediaAssets;
  bool needSeoContent;

  // User Experience & Flow
  String? userJourney;
  List<String> callToActions = [];
  List<String> keyConversions = [];

  // Technical Requirements
  String? techStack;
  bool hasHostingDomain;
  bool needsDnsSetup;
  String? expectedTraffic;
  String? designApproach;
  bool accessibilityCompliance;

  // CMS & Admin
  String? cmsPreference;
  List<String> editableSections = [];
  String? contentManager;

  // SEO & Analytics
  bool needsBasicSeo;
  bool needsKeywordResearch;
  bool needsAnalytics;
  bool needsSchemaMarkup;

  // Maintenance & Support
  bool needsOngoingMaintenance;
  String? updateFrequency;
  bool needsBackupRecovery;

  // Timeline & Budget
  DateTime? launchDate;
  String? importantMilestones;
  String? budgetRange;

  // Legal and Compliance
  bool needsLegalPages;
  List<String> complianceRequirements = [];

  // Content & Marketing
  bool hasMarketingStrategy;
  bool needsLandingPages;
  bool planningContentUpdates;

  // Competitor Analysis
  List<String> competitors = [];
  Map<String, String> competitorFeedback = {};

  // Stakeholders & Approval
  List<String> stakeholders = [];
  String? finalApprover;
  String? feedbackMethod;

  // Audio Recording for each section
  Map<String, String?> sectionAudioPaths = {};
  Map<String, String?> sectionTranscriptions = {};
  Map<String, String?> sectionSummaries = {};

  // Progress tracking
  double get completionPercentage {
    int totalFields = 30; // Total number of required sections
    int completedFields = 0;

    if (companyName != null && companyName!.isNotEmpty) completedFields++;
    if (websitePurpose != null && websitePurpose!.isNotEmpty) completedFields++;
    if (primaryAudience != null && primaryAudience!.isNotEmpty) completedFields++;
    if (websiteGoals.isNotEmpty) completedFields++;
    if (kpiMetrics.isNotEmpty) completedFields++;
    // Design
    if (preferredStyle != null && preferredStyle!.isNotEmpty) completedFields++;
    // Features
    if (features.values.any((isSelected) => isSelected)) completedFields++;
    if (requiredIntegrations.isNotEmpty) completedFields++;
    // Pages
    if (essentialPages.isNotEmpty) completedFields++;
    if (contentStatus != null && contentStatus!.isNotEmpty) completedFields++;
    // UX
    if (callToActions.isNotEmpty) completedFields++;
    if (keyConversions.isNotEmpty) completedFields++;
    // Technical
    if (techStack != null && techStack!.isNotEmpty) completedFields++;
    if (expectedTraffic != null && expectedTraffic!.isNotEmpty) completedFields++;
    if (designApproach != null && designApproach!.isNotEmpty) completedFields++;
    // CMS
    if (cmsPreference != null && cmsPreference!.isNotEmpty) completedFields++;
    if (editableSections.isNotEmpty) completedFields++;
    if (contentManager != null && contentManager!.isNotEmpty) completedFields++;
    // SEO
    if (needsBasicSeo || needsKeywordResearch || needsAnalytics || needsSchemaMarkup) completedFields++;
    // Maintenance
    if (updateFrequency != null && updateFrequency!.isNotEmpty) completedFields++;
    // Timeline
    if (launchDate != null) completedFields++;
    if (budgetRange != null && budgetRange!.isNotEmpty) completedFields++;
    // Legal
    if (complianceRequirements.isNotEmpty) completedFields++;
    // Marketing
    if (hasMarketingStrategy || needsLandingPages || planningContentUpdates) completedFields++;
    // Competitors
    if (competitors.isNotEmpty) completedFields++;
    // Stakeholders
    if (stakeholders.isNotEmpty) completedFields++;
    if (finalApprover != null && finalApprover!.isNotEmpty) completedFields++;
    if (feedbackMethod != null && feedbackMethod!.isNotEmpty) completedFields++;
    
    return completedFields / totalFields;
  }

  BRDRequirementsForm({
    this.companyName,
    this.websitePurpose,
    this.existingWebsite,
    this.primaryAudience,
    this.secondaryAudience,
    List<String>? websiteGoals,
    List<String>? kpiMetrics,
    this.hasExistingBranding = false,
    this.preferredStyle,
    List<String>? websitesLiked,
    this.designElementsToAvoid,
    Map<String, bool>? features,
    List<String>? requiredIntegrations,
    this.multiLanguageSupport = false,
    List<String>? essentialPages,
    this.contentStatus,
    this.mediaAssets,
    this.needSeoContent = false,
    this.userJourney,
    List<String>? callToActions,
    List<String>? keyConversions,
    this.techStack,
    this.hasHostingDomain = false,
    this.needsDnsSetup = false,
    this.expectedTraffic,
    this.designApproach,
    this.accessibilityCompliance = false,
    this.cmsPreference,
    List<String>? editableSections,
    this.contentManager,
    this.needsBasicSeo = false,
    this.needsKeywordResearch = false,
    this.needsAnalytics = false,
    this.needsSchemaMarkup = false,
    this.needsOngoingMaintenance = false,
    this.updateFrequency,
    this.needsBackupRecovery = false,
    this.launchDate,
    this.importantMilestones,
    this.budgetRange,
    this.needsLegalPages = false,
    List<String>? complianceRequirements,
    this.hasMarketingStrategy = false,
    this.needsLandingPages = false,
    this.planningContentUpdates = false,
    List<String>? competitors,
    Map<String, String>? competitorFeedback,
    List<String>? stakeholders,
    this.finalApprover,
    this.feedbackMethod,
    Map<String, String?>? sectionAudioPaths,
    Map<String, String?>? sectionTranscriptions,
    Map<String, String?>? sectionSummaries,
  }) {
    this.websiteGoals = websiteGoals ?? [];
    this.kpiMetrics = kpiMetrics ?? [];
    this.websitesLiked = websitesLiked ?? [];
    this.features = features ?? this.features;
    this.requiredIntegrations = requiredIntegrations ?? [];
    this.essentialPages = essentialPages ?? [];
    this.callToActions = callToActions ?? [];
    this.keyConversions = keyConversions ?? [];
    this.editableSections = editableSections ?? [];
    this.complianceRequirements = complianceRequirements ?? [];
    this.competitors = competitors ?? [];
    this.competitorFeedback = competitorFeedback ?? {};
    this.stakeholders = stakeholders ?? [];
    this.sectionAudioPaths = sectionAudioPaths ?? {};
    this.sectionTranscriptions = sectionTranscriptions ?? {};
    this.sectionSummaries = sectionSummaries ?? {};
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'websitePurpose': websitePurpose,
      'existingWebsite': existingWebsite,
      'primaryAudience': primaryAudience,
      'secondaryAudience': secondaryAudience,
      'websiteGoals': websiteGoals,
      'kpiMetrics': kpiMetrics,
      'hasExistingBranding': hasExistingBranding,
      'preferredStyle': preferredStyle,
      'websitesLiked': websitesLiked,
      'designElementsToAvoid': designElementsToAvoid,
      'features': features,
      'requiredIntegrations': requiredIntegrations,
      'multiLanguageSupport': multiLanguageSupport,
      'essentialPages': essentialPages,
      'contentStatus': contentStatus,
      'mediaAssets': mediaAssets,
      'needSeoContent': needSeoContent,
      'userJourney': userJourney,
      'callToActions': callToActions,
      'keyConversions': keyConversions,
      'techStack': techStack,
      'hasHostingDomain': hasHostingDomain,
      'needsDnsSetup': needsDnsSetup,
      'expectedTraffic': expectedTraffic,
      'designApproach': designApproach,
      'accessibilityCompliance': accessibilityCompliance,
      'cmsPreference': cmsPreference,
      'editableSections': editableSections,
      'contentManager': contentManager,
      'needsBasicSeo': needsBasicSeo,
      'needsKeywordResearch': needsKeywordResearch,
      'needsAnalytics': needsAnalytics,
      'needsSchemaMarkup': needsSchemaMarkup,
      'needsOngoingMaintenance': needsOngoingMaintenance,
      'updateFrequency': updateFrequency,
      'needsBackupRecovery': needsBackupRecovery,
      'launchDate': launchDate?.toIso8601String(),
      'importantMilestones': importantMilestones,
      'budgetRange': budgetRange,
      'needsLegalPages': needsLegalPages,
      'complianceRequirements': complianceRequirements,
      'hasMarketingStrategy': hasMarketingStrategy,
      'needsLandingPages': needsLandingPages,
      'planningContentUpdates': planningContentUpdates,
      'competitors': competitors,
      'competitorFeedback': competitorFeedback,
      'stakeholders': stakeholders,
      'finalApprover': finalApprover,
      'feedbackMethod': feedbackMethod,
      'sectionAudioPaths': sectionAudioPaths,
      'sectionTranscriptions': sectionTranscriptions,
      'sectionSummaries': sectionSummaries,
    };
  }

  factory BRDRequirementsForm.fromJson(Map<String, dynamic> json) {
    return BRDRequirementsForm(
      companyName: json['companyName'],
      websitePurpose: json['websitePurpose'],
      existingWebsite: json['existingWebsite'],
      primaryAudience: json['primaryAudience'],
      secondaryAudience: json['secondaryAudience'],
      websiteGoals: List<String>.from(json['websiteGoals'] ?? []),
      kpiMetrics: List<String>.from(json['kpiMetrics'] ?? []),
      hasExistingBranding: json['hasExistingBranding'] ?? false,
      preferredStyle: json['preferredStyle'],
      websitesLiked: List<String>.from(json['websitesLiked'] ?? []),
      designElementsToAvoid: json['designElementsToAvoid'],
      features: Map<String, bool>.from(json['features'] ?? {}),
      requiredIntegrations: List<String>.from(json['requiredIntegrations'] ?? []),
      multiLanguageSupport: json['multiLanguageSupport'] ?? false,
      essentialPages: List<String>.from(json['essentialPages'] ?? []),
      contentStatus: json['contentStatus'],
      mediaAssets: json['mediaAssets'],
      needSeoContent: json['needSeoContent'] ?? false,
      userJourney: json['userJourney'],
      callToActions: List<String>.from(json['callToActions'] ?? []),
      keyConversions: List<String>.from(json['keyConversions'] ?? []),
      techStack: json['techStack'],
      hasHostingDomain: json['hasHostingDomain'] ?? false,
      needsDnsSetup: json['needsDnsSetup'] ?? false,
      expectedTraffic: json['expectedTraffic'],
      designApproach: json['designApproach'],
      accessibilityCompliance: json['accessibilityCompliance'] ?? false,
      cmsPreference: json['cmsPreference'],
      editableSections: List<String>.from(json['editableSections'] ?? []),
      contentManager: json['contentManager'],
      needsBasicSeo: json['needsBasicSeo'] ?? false,
      needsKeywordResearch: json['needsKeywordResearch'] ?? false,
      needsAnalytics: json['needsAnalytics'] ?? false,
      needsSchemaMarkup: json['needsSchemaMarkup'] ?? false,
      needsOngoingMaintenance: json['needsOngoingMaintenance'] ?? false,
      updateFrequency: json['updateFrequency'],
      needsBackupRecovery: json['needsBackupRecovery'] ?? false,
      launchDate: json['launchDate'] != null ? DateTime.parse(json['launchDate']) : null,
      importantMilestones: json['importantMilestones'],
      budgetRange: json['budgetRange'],
      needsLegalPages: json['needsLegalPages'] ?? false,
      complianceRequirements: List<String>.from(json['complianceRequirements'] ?? []),
      hasMarketingStrategy: json['hasMarketingStrategy'] ?? false,
      needsLandingPages: json['needsLandingPages'] ?? false,
      planningContentUpdates: json['planningContentUpdates'] ?? false,
      competitors: List<String>.from(json['competitors'] ?? []),
      competitorFeedback: Map<String, String>.from(json['competitorFeedback'] ?? {}),
      stakeholders: List<String>.from(json['stakeholders'] ?? []),
      finalApprover: json['finalApprover'],
      feedbackMethod: json['feedbackMethod'],
      sectionAudioPaths: Map<String, String?>.from(json['sectionAudioPaths'] ?? {}),
      sectionTranscriptions: Map<String, String?>.from(json['sectionTranscriptions'] ?? {}),
      sectionSummaries: Map<String, String?>.from(json['sectionSummaries'] ?? {}),
    );
  }

  String generateMarkdown() {
    String markdown = "# Business Requirements Document (BRD)\n\n";
    
    // Basic Information
    markdown += "## 1. Basic Information\n\n";
    if (companyName != null && companyName!.isNotEmpty) {
      markdown += "- **Company/Brand Name**: $companyName\n";
    }
    if (websitePurpose != null && websitePurpose!.isNotEmpty) {
      markdown += "- **Website Purpose**: $websitePurpose\n";
    }
    if (existingWebsite != null && existingWebsite!.isNotEmpty) {
      markdown += "- **Existing Website**: $existingWebsite\n";
    }
    if (primaryAudience != null && primaryAudience!.isNotEmpty) {
      markdown += "- **Primary Target Audience**: $primaryAudience\n";
    }
    if (secondaryAudience != null && secondaryAudience!.isNotEmpty) {
      markdown += "- **Secondary Target Audience**: $secondaryAudience\n";
    }
    
    // Goals and Objectives
    markdown += "\n## 2. Goals and Objectives\n\n";
    if (websiteGoals.isNotEmpty) {
      markdown += "### Website Goals:\n";
      for (int i = 0; i < websiteGoals.length; i++) {
        markdown += "- ${websiteGoals[i]}\n";
      }
    }
    if (kpiMetrics.isNotEmpty) {
      markdown += "\n### Key Performance Indicators (KPIs):\n";
      for (int i = 0; i < kpiMetrics.length; i++) {
        markdown += "- ${kpiMetrics[i]}\n";
      }
    }
    
    // Design and Branding
    markdown += "\n## 3. Design and Branding\n\n";
    markdown += "- **Existing Branding**: ${hasExistingBranding ? 'Yes' : 'No'}\n";
    if (preferredStyle != null && preferredStyle!.isNotEmpty) {
      markdown += "- **Preferred Look and Feel**: $preferredStyle\n";
    }
    if (websitesLiked.isNotEmpty) {
      markdown += "\n### Websites of Interest:\n";
      for (int i = 0; i < websitesLiked.length; i++) {
        markdown += "- ${websitesLiked[i]}\n";
      }
    }
    if (designElementsToAvoid != null && designElementsToAvoid!.isNotEmpty) {
      markdown += "- **Design Elements to Avoid**: $designElementsToAvoid\n";
    }
    
    // Features and Functionality
    markdown += "\n## 4. Features and Functionality\n\n";
    markdown += "### Required Features:\n";
    features.forEach((feature, isSelected) {
      if (isSelected) {
        markdown += "- $feature\n";
      }
    });
    
    if (requiredIntegrations.isNotEmpty) {
      markdown += "\n### Required Integrations:\n";
      for (int i = 0; i < requiredIntegrations.length; i++) {
        markdown += "- ${requiredIntegrations[i]}\n";
      }
    }
    markdown += "\n- **Multi-Language Support Required**: ${multiLanguageSupport ? 'Yes' : 'No'}\n";
    
    // Continue for all sections
    // Pages and Content
    markdown += "\n## 5. Pages and Content\n\n";
    if (essentialPages.isNotEmpty) {
      markdown += "### Essential Pages:\n";
      for (int i = 0; i < essentialPages.length; i++) {
        markdown += "- ${essentialPages[i]}\n";
      }
    }
    if (contentStatus != null && contentStatus!.isNotEmpty) {
      markdown += "\n- **Content Status**: $contentStatus\n";
    }
    if (mediaAssets != null && mediaAssets!.isNotEmpty) {
      markdown += "- **Media Assets**: $mediaAssets\n";
    }
    markdown += "- **SEO-Optimized Content Required**: ${needSeoContent ? 'Yes' : 'No'}\n";
    
    // Continue with all remaining sections...
    // User Experience & Flow
    markdown += "\n## 6. User Experience & Flow\n\n";
    if (userJourney != null && userJourney!.isNotEmpty) {
      markdown += "- **Ideal User Journey**: $userJourney\n\n";
    }
    if (callToActions.isNotEmpty) {
      markdown += "### Call-to-Actions (CTAs):\n";
      for (int i = 0; i < callToActions.length; i++) {
        markdown += "- ${callToActions[i]}\n";
      }
    }
    if (keyConversions.isNotEmpty) {
      markdown += "\n### Key Conversions/Actions:\n";
      for (int i = 0; i < keyConversions.length; i++) {
        markdown += "- ${keyConversions[i]}\n";
      }
    }
    
    // Technical Requirements
    markdown += "\n## 7. Technical Requirements\n\n";
    if (techStack != null && techStack!.isNotEmpty) {
      markdown += "- **Preferred Tech Stack**: $techStack\n";
    }
    markdown += "- **Has Hosting/Domain**: ${hasHostingDomain ? 'Yes' : 'No'}\n";
    markdown += "- **Needs DNS Setup Assistance**: ${needsDnsSetup ? 'Yes' : 'No'}\n";
    if (expectedTraffic != null && expectedTraffic!.isNotEmpty) {
      markdown += "- **Expected Traffic**: $expectedTraffic\n";
    }
    if (designApproach != null && designApproach!.isNotEmpty) {
      markdown += "- **Design Approach**: $designApproach\n";
    }
    markdown += "- **Accessibility Compliance Required**: ${accessibilityCompliance ? 'Yes' : 'No'}\n";
    
    // CMS & Admin
    markdown += "\n## 8. CMS & Admin Capabilities\n\n";
    if (cmsPreference != null && cmsPreference!.isNotEmpty) {
      markdown += "- **CMS Preference**: $cmsPreference\n";
    }
    if (editableSections.isNotEmpty) {
      markdown += "\n### Editable Sections:\n";
      for (int i = 0; i < editableSections.length; i++) {
        markdown += "- ${editableSections[i]}\n";
      }
    }
    if (contentManager != null && contentManager!.isNotEmpty) {
      markdown += "\n- **Content Manager**: $contentManager\n";
    }
    
    // SEO & Analytics
    markdown += "\n## 9. SEO & Analytics\n\n";
    markdown += "- **Basic SEO Setup Required**: ${needsBasicSeo ? 'Yes' : 'No'}\n";
    markdown += "- **Keyword Research Required**: ${needsKeywordResearch ? 'Yes' : 'No'}\n";
    markdown += "- **Analytics Integration Required**: ${needsAnalytics ? 'Yes' : 'No'}\n";
    markdown += "- **Schema Markup Required**: ${needsSchemaMarkup ? 'Yes' : 'No'}\n";
    
    // Maintenance & Support
    markdown += "\n## 10. Maintenance & Support\n\n";
    markdown += "- **Ongoing Maintenance Required**: ${needsOngoingMaintenance ? 'Yes' : 'No'}\n";
    if (updateFrequency != null && updateFrequency!.isNotEmpty) {
      markdown += "- **Update Frequency**: $updateFrequency\n";
    }
    markdown += "- **Backup & Recovery Support Required**: ${needsBackupRecovery ? 'Yes' : 'No'}\n";
    
    // Timeline & Budget
    markdown += "\n## 11. Timeline & Budget\n\n";
    if (launchDate != null) {
      markdown += "- **Preferred Launch Date**: ${launchDate!.toIso8601String().split('T')[0]}\n";
    }
    if (importantMilestones != null && importantMilestones!.isNotEmpty) {
      markdown += "- **Important Milestones**: $importantMilestones\n";
    }
    if (budgetRange != null && budgetRange!.isNotEmpty) {
      markdown += "- **Budget Range**: $budgetRange\n";
    }
    
    // Legal and Compliance
    markdown += "\n## 12. Legal and Compliance\n\n";
    markdown += "- **Legal Pages Required**: ${needsLegalPages ? 'Yes' : 'No'}\n";
    if (complianceRequirements.isNotEmpty) {
      markdown += "\n### Compliance Requirements:\n";
      for (int i = 0; i < complianceRequirements.length; i++) {
        markdown += "- ${complianceRequirements[i]}\n";
      }
    }
    
    // Content & Marketing
    markdown += "\n## 13. Content & Marketing Strategy\n\n";
    markdown += "- **Has Marketing Strategy**: ${hasMarketingStrategy ? 'Yes' : 'No'}\n";
    markdown += "- **Needs Campaign Landing Pages**: ${needsLandingPages ? 'Yes' : 'No'}\n";
    markdown += "- **Planning Regular Content Updates**: ${planningContentUpdates ? 'Yes' : 'No'}\n";
    
    // Competitor Analysis
    markdown += "\n## 14. Competitor Analysis\n\n";
    if (competitors.isNotEmpty) {
      markdown += "### Key Competitors:\n";
      for (int i = 0; i < competitors.length; i++) {
        String competitor = competitors[i];
        markdown += "- $competitor";
        if (competitorFeedback.containsKey(competitor)) {
          markdown += ": ${competitorFeedback[competitor]}";
        }
        markdown += "\n";
      }
    }
    
    // Stakeholders & Approval
    markdown += "\n## 15. Stakeholders & Approval Process\n\n";
    if (stakeholders.isNotEmpty) {
      markdown += "### Project Stakeholders:\n";
      for (int i = 0; i < stakeholders.length; i++) {
        markdown += "- ${stakeholders[i]}\n";
      }
    }
    if (finalApprover != null && finalApprover!.isNotEmpty) {
      markdown += "\n- **Final Approver**: $finalApprover\n";
    }
    if (feedbackMethod != null && feedbackMethod!.isNotEmpty) {
      markdown += "- **Feedback Communication Method**: $feedbackMethod\n";
    }
    
    return markdown;
  }
} 