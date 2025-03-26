import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:collection';
import '../utils/currency_converter.dart';

class DocumentState extends ChangeNotifier {
  // Master data store that will be used to generate all documents
  Map<String, dynamic> masterData = {};
  
  // Store custom prompts
  List<Map<String, String>> customPrompts = [];
  
  // Map to store documents content
  final Map<String, String> _documents = {};
  
  // Project timeline and revenue estimations
  Map<String, dynamic> _projectEstimates = {
    'timeEstimate': {
      'months': 0,
      'weeks': 0
    },
    'revenueEstimate': {
      'initial': 0.0,
      'monthly': 0.0,
      'yearlyTotal': 0.0
    }
  };
  
  // Replace the sensitive API key with a placeholder or remove it
  const String apiKey = 'YOUR_API_KEY_HERE'; // Use environment variable instead
  
  // Region settings for pricing
  String _selectedRegion = 'North America';
  final Map<String, double> _regionRateMultipliers = {
    'North America': 1.0,
    'Europe': 1.2,
    'Asia': 0.8,
    'Australia': 1.15,
    'South America': 0.75,
    'Africa': 0.7,
    'Middle East': 1.1,
  };
  
  // Currency settings
  String _selectedCurrency = 'USD';
  
  // Custom rate settings
  double _customDailyRate = 300.0; // Default daily rate
  
  // Client agreement tracking
  bool _clientAgreed = false;
  double _agreedAmount = 0.0;
  
  // Getters for currency
  String get selectedCurrency => _selectedCurrency;
  
  // Get all supported currencies
  List<String> get supportedCurrencies => CurrencyConverter.getSupportedCurrencies();
  
  // Set selected currency
  set selectedCurrency(String currencyCode) {
    if (CurrencyConverter.currencies.containsKey(currencyCode)) {
      _selectedCurrency = currencyCode;
      _savePreferences();
      notifyListeners();
    }
  }
  
  // Format amount in selected currency
  String formatCurrency(double amount, {String? currencyCode, bool showCode = false}) {
    final code = currencyCode ?? _selectedCurrency;
    return CurrencyConverter.format(amount, code, showCode: showCode);
  }
  
  // Convert amount to selected currency
  double convertToSelectedCurrency(double amount, String fromCurrency) {
    return CurrencyConverter.convert(amount, fromCurrency, _selectedCurrency);
  }
  
  // Get daily rate in selected currency
  double get dailyRateInSelectedCurrency {
    // Daily rate is stored in USD, convert to selected currency
    return _selectedCurrency == 'USD' 
        ? _customDailyRate 
        : convertToSelectedCurrency(_customDailyRate, 'USD');
  }
  
  // Get formatted daily rate with currency symbol
  String get formattedDailyRate {
    return formatCurrency(dailyRateInSelectedCurrency);
  }
  
  // Existing getters
  String get selectedRegion => _selectedRegion;
  double get regionMultiplier => _regionRateMultipliers[_selectedRegion] ?? 1.0;
  double get dailyRate => _customDailyRate * regionMultiplier;
  bool get clientAgreed => _clientAgreed;
  double get agreedAmount => _agreedAmount;
  
  // Load saved custom prompts
  Future<void> loadCustomPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    final promptsJson = prefs.getString('custom_prompts');
    if (promptsJson != null) {
      final List<dynamic> decoded = jsonDecode(promptsJson);
      customPrompts = decoded.map((item) => Map<String, String>.from(item)).toList();
    }
    
    // Load currency preference
    _selectedCurrency = prefs.getString('selected_currency') ?? 'USD';
    
    notifyListeners();
  }
  
  // Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', _selectedCurrency);
    await prefs.setString('selected_region', _selectedRegion);
    await prefs.setDouble('custom_daily_rate', _customDailyRate);
  }

  // Save region and rate settings
  Future<void> saveSettings({String? region, double? rate, String? currency}) async {
    if (region != null && _regionRateMultipliers.containsKey(region)) {
      _selectedRegion = region;
    }
    
    if (rate != null && rate > 0) {
      _customDailyRate = rate;
    }
    
    if (currency != null && CurrencyConverter.currencies.containsKey(currency)) {
      _selectedCurrency = currency;
    }
    
    await _savePreferences();
    notifyListeners();
  }
  
  // Save a new custom prompt
  Future<void> saveCustomPrompt(String title, String prompt) async {
    customPrompts.add({
      'title': title,
      'prompt': prompt,
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_prompts', jsonEncode(customPrompts));
    notifyListeners();
  }
  
  Future<void> initializeFromPrompt(String prompt) async {
    // Define document types
    final documentTypes = [
      'BRD', 'FRD', 'NFR', 'TDD', 'UI/UX', 
      'API Docs', 'Test Cases', 'Deployment Guide', 'User Manual'
    ];
    
    // Generate each document
    for (var docType in documentTypes) {
      await _generateDocument(docType, prompt);
    }
    
    // Generate time and revenue estimates
    await _generateProjectEstimates(prompt);
    
    notifyListeners();
  }
  
  Future<void> _generateProjectEstimates(String projectPrompt) async {
    try {
      // Create a specific prompt for time and revenue estimation
      final String timeRevenuePrompt = 
          "Based on this project description, provide a JSON response with: "
          "1. A realistic time estimate (in months and weeks) "
          "2. Revenue estimates (initial setup fee, monthly recurring revenue, and yearly total). "
          "Format should be exactly this JSON structure: "
          "{ \"timeEstimate\": { \"months\": X, \"weeks\": Y }, "
          "\"revenueEstimate\": { \"initial\": X, \"monthly\": Y, \"yearlyTotal\": Z } }. "
          "Project description: $projectPrompt";
      
      // Direct HTTP call to OpenAI API
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a professional project manager with expertise in estimating project timelines and revenue projections.'},
            {'role': 'user', 'content': timeRevenuePrompt},
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse the JSON response from GPT
        try {
          // Find the JSON string in the response (in case GPT adds additional text)
          final jsonRegex = RegExp(r'\{[\s\S]*\}');
          final match = jsonRegex.firstMatch(content);
          
          if (match != null) {
            final jsonStr = match.group(0);
            if (jsonStr != null) {
              final estimates = jsonDecode(jsonStr);
              _projectEstimates = estimates;
              
              // Apply custom rates and region multiplier
              final months = _projectEstimates['timeEstimate']['months'] ?? 0;
              final weeks = _projectEstimates['timeEstimate']['weeks'] ?? 0;
              final totalDays = (months * 30) + (weeks * 7);
              
              // Recalculate with custom daily rate and region multiplier
              double devCost = totalDays * dailyRate;
              double monthlyRev = _projectEstimates['revenueEstimate']['monthly'] ?? 0.0;
              double initialRev = _projectEstimates['revenueEstimate']['initial'] ?? 0.0;
              
              // Apply region multiplier to revenue projections too
              monthlyRev *= regionMultiplier;
              initialRev *= regionMultiplier;
              double yearlyTotal = initialRev + (monthlyRev * 12);
              
              // Update the estimates with our custom calculations
              _projectEstimates['revenueEstimate']['initial'] = initialRev;
              _projectEstimates['revenueEstimate']['monthly'] = monthlyRev;
              _projectEstimates['revenueEstimate']['yearlyTotal'] = yearlyTotal;
            }
          }
        } catch (e) {
          print("Error parsing estimate JSON: $e");
          // Set default values if parsing fails
          _setDefaultEstimates();
        }
      } else {
        throw Exception('Failed to generate estimates: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print("Error generating estimates: $e");
      // Set default values if the API call fails
      _setDefaultEstimates();
    }
  }
  
  // Helper method to set default estimates
  void _setDefaultEstimates() {
    _projectEstimates = {
      'timeEstimate': {
        'months': 3,
        'weeks': 2
      },
      'revenueEstimate': {
        'initial': 5000.0 * regionMultiplier,
        'monthly': 2000.0 * regionMultiplier,
        'yearlyTotal': 29000.0 * regionMultiplier
      }
    };
  }
  
  // Get project time estimates
  Map<String, dynamic> getTimeEstimate() {
    return _projectEstimates['timeEstimate'];
  }
  
  // Get project revenue estimates
  Map<String, dynamic> getRevenueEstimate() {
    return _projectEstimates['revenueEstimate'];
  }
  
  Future<void> _generateDocument(String documentType, String projectPrompt) async {
    try {
      // Create a specific prompt for each document type
      final String specificPrompt = _createSpecificPrompt(documentType, projectPrompt);
      
      // Direct HTTP call to OpenAI API
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a professional technical writer and project manager.'},
            {'role': 'user', 'content': specificPrompt},
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        _documents[documentType] = content;
      } else {
        throw Exception('Failed to generate content: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _documents[documentType] = "Error generating document: $e";
      print("Error generating $documentType: $e");
    }
  }

  String _createSpecificPrompt(String documentType, String projectPrompt) {
    switch (documentType) {
      case 'BRD':
        return "Create a detailed Business Requirements Document for the following project: $projectPrompt. Include executive summary, project goals, stakeholders, business needs, constraints, and success criteria.";
      case 'FRD':
        return "Create a comprehensive Functional Requirements Document for the following project: $projectPrompt. Include detailed user stories, functional specifications, data requirements, and system behaviors.";
      case 'NFR':
        return "Create a Non-Functional Requirements Document for the following project: $projectPrompt. Include performance, security, reliability, scalability, and compliance requirements.";
      case 'TDD':
        return "Create a Technical Design Document for the following project: $projectPrompt. Include system architecture, component designs, data models, interfaces, and technical constraints.";
      case 'UI/UX':
        return "Create UI/UX Documentation for the following project: $projectPrompt. Include user personas, user journeys, wireframes descriptions, and design guidelines.";
      case 'API Docs':
        return "Create API Documentation for the following project: $projectPrompt. Include endpoints, request/response formats, authentication methods, and example usage.";
      case 'Test Cases':
        return "Create Test Cases for the following project: $projectPrompt. Include functional tests, integration tests, performance tests, and user acceptance criteria.";
      case 'Deployment Guide':
        return "Create a Deployment Guide for the following project: $projectPrompt. Include environment setup, deployment steps, configuration, and troubleshooting.";
      case 'User Manual':
        return "Create a User Manual for the following project: $projectPrompt. Include installation instructions, feature guides, troubleshooting, and FAQs.";
      default:
        return "Create a detailed $documentType for the following project: $projectPrompt";
    }
  }
  
  // Getter for document content
  String getDocumentContent(String documentType) {
    return _documents[documentType] ?? "No content generated yet.";
  }
  
  // Get all document types that have been generated
  List<String> getAllDocumentTypes() {
    return _documents.keys.toList();
  }
  
  // Method to generate all requested documents
  Map<String, dynamic> _generateAllDocuments(String prompt) {
    // In a real application, this would call an AI service like OpenAI
    // For demo purposes, we'll use static examples with minor customization
    
    // Extract a project name from the first few words of the prompt
    final projectName = prompt.split(' ').take(3).join(' ') + ' Project';
    
    return {
      'BRD': _generateBRD(prompt, projectName),
      'FRD': _generateFRD(prompt, projectName),
      'NFR': _generateNFR(prompt, projectName),
      'TDD': _generateTDD(prompt, projectName),
      'UI/UX': _generateUIUX(prompt, projectName),
      'API Docs': _generateAPIDocs(prompt, projectName),
      'Test Cases': _generateTestCases(prompt, projectName),
      'Deployment Guide': _generateDeploymentGuide(prompt, projectName),
      'User Manual': _generateUserManual(prompt, projectName),
    };
  }
  
  // Business Requirements Document
  Map<String, dynamic> _generateBRD(String prompt, String projectName) {
    return {
      'a. Project Name': projectName,
      'b. Executive Summary': prompt,
      'c. Business Objectives': [
        'Increase user engagement by 30%',
        'Reduce operational costs by 25%',
        'Expand market reach to new segments',
        'Improve customer satisfaction scores',
      ],
      'd. Stakeholders': [
        'End Users',
        'Product Management Team',
        'Development Team',
        'QA Team',
        'Marketing Team',
        'Executive Sponsors',
      ],
      'e. Scope': {
        'In Scope': 'User authentication, core functionality modules, reporting, admin panel',
        'Out of Scope': 'Third-party integrations (planned for Phase 2), multi-language support',
      },
      'f. Success Metrics': [
        'User adoption rate > 20% in first 3 months',
        'Customer satisfaction rating > 4.2/5',
        'Completion of MVP within 4 months',
        'Reduction in support tickets by 15%',
      ],
      'g. Constraints': [
        'Budget cap of \$150,000',
        'Must launch by Q4 2023',
        'Must comply with GDPR and CCPA regulations',
        'Must support all major browsers and mobile devices',
      ],
      'h. Assumptions': [
        'The development team has necessary expertise',
        'Infrastructure costs will remain stable',
        'Third-party APIs will maintain current functionality',
        'Target users have basic technical literacy',
      ],
    };
  }
  
  // Functional Requirements Document
  Map<String, dynamic> _generateFRD(String prompt, String projectName) {
    return {
      'a. User Roles': [
        'Guest (Unauthenticated)',
        'Standard User',
        'Premium User',
        'Administrator',
        'System Manager',
      ],
      'b. User Authentication': {
        'FR-1.1': 'User registration with email verification',
        'FR-1.2': 'Social login (Google, Apple, Facebook)',
        'FR-1.3': 'Password reset functionality',
        'FR-1.4': 'Session management and auto-logout',
      },
      'c. Core Functionality': {
        'FR-2.1': 'User profile management',
        'FR-2.2': 'Content creation and management',
        'FR-2.3': 'Search and filter functionality',
        'FR-2.4': 'Notification system (email, in-app)',
      },
      'd. Administrative Features': {
        'FR-3.1': 'User management dashboard',
        'FR-3.2': 'Content moderation tools',
        'FR-3.3': 'System analytics and reporting',
        'FR-3.4': 'Configuration management',
      },
      'e. Payment Processing': {
        'FR-4.1': 'Subscription management',
        'FR-4.2': 'Payment gateway integration',
        'FR-4.3': 'Invoice generation',
        'FR-4.4': 'Refund processing',
      },
      'f. Integration Requirements': {
        'FR-5.1': 'Third-party API connections',
        'FR-5.2': 'Data import/export functionality',
        'FR-5.3': 'Webhook support',
      },
    };
  }
  
  // Non-Functional Requirements
  Map<String, dynamic> _generateNFR(String prompt, String projectName) {
    return {
      'a. Performance': {
        'NFR-1.1': 'Page load time < 2 seconds',
        'NFR-1.2': 'API response time < 500ms',
        'NFR-1.3': 'Support 10,000 concurrent users',
        'NFR-1.4': 'Database query time < 100ms',
      },
      'b. Security': {
        'NFR-2.1': 'Data encryption in transit and at rest',
        'NFR-2.2': 'Role-based access control',
        'NFR-2.3': 'Regular security audits and penetration testing',
        'NFR-2.4': 'Compliance with industry standards (OWASP)',
      },
      'c. Reliability': {
        'NFR-3.1': '99.9% uptime SLA',
        'NFR-3.2': 'Automated backup system',
        'NFR-3.3': 'Disaster recovery plan with RPO < 1 hour',
        'NFR-3.4': 'Graceful degradation under high load',
      },
      'd. Usability': {
        'NFR-4.1': 'Intuitive UI requiring minimal training',
        'NFR-4.2': 'Mobile-responsive design',
        'NFR-4.3': 'Accessibility compliance (WCAG 2.1 AA)',
        'NFR-4.4': 'Consistent design language',
      },
      'e. Scalability': {
        'NFR-5.1': 'Horizontal scaling capability',
        'NFR-5.2': 'Database sharding support',
        'NFR-5.3': 'Caching strategy implementation',
        'NFR-5.4': 'Microservices architecture',
      },
      'f. Maintainability': {
        'NFR-6.1': 'Comprehensive documentation',
        'NFR-6.2': 'Automated testing coverage > 80%',
        'NFR-6.3': 'Clean code standards enforcement',
        'NFR-6.4': 'Monitoring and alerting system',
      },
    };
  }
  
  // Technical Design Document
  Map<String, dynamic> _generateTDD(String prompt, String projectName) {
    return {
      'a. Architecture Overview': {
        'Frontend': 'React.js with Redux, Typescript',
        'Backend': 'Node.js Express with Typescript',
        'Database': 'PostgreSQL with Redis for caching',
        'Infrastructure': 'AWS (ECS, RDS, S3, CloudFront)',
        'DevOps': 'CI/CD with GitHub Actions, Docker',
      },
      'b. Data Model': [
        'Users (id, email, password_hash, role, created_at, updated_at)',
        'Profiles (user_id, name, avatar, preferences, bio)',
        'Content (id, user_id, title, body, status, created_at, updated_at)',
        'Comments (id, content_id, user_id, body, created_at)',
        'Subscriptions (id, user_id, plan_id, status, start_date, end_date)',
      ],
      'c. API Architecture': {
        'Authentication': 'JWT-based authentication with refresh tokens',
        'Endpoints Structure': 'RESTful API with versioning (/api/v1/resource)',
        'Rate Limiting': '100 requests per minute per IP',
        'Payload Format': 'JSON with consistent error responses',
      },
      'd. Security Architecture': {
        'Authentication': 'OAuth 2.0 / OpenID Connect',
        'Authorization': 'Role-based access control (RBAC)',
        'Data Protection': 'AES-256 encryption for sensitive data',
        'API Security': 'HTTPS, CSP, CORS, input validation',
      },
      'e. Scalability Approach': {
        'Load Balancing': 'AWS Application Load Balancer',
        'Auto Scaling': 'ECS auto-scaling groups',
        'Database Scaling': 'Read replicas, connection pooling',
        'CDN': 'CloudFront for static assets',
      },
      'f. Third-party Integrations': {
        'Payment Processing': 'Stripe API',
        'Email Services': 'SendGrid',
        'Analytics': 'Google Analytics, Mixpanel',
        'File Storage': 'AWS S3',
      },
      'g. Monitoring & Logging': {
        'Application Monitoring': 'New Relic, Datadog',
        'Log Management': 'ELK Stack (Elasticsearch, Logstash, Kibana)',
        'Error Tracking': 'Sentry',
        'Performance Metrics': 'Prometheus with Grafana',
      },
    };
  }
  
  // UI/UX Documentation
  Map<String, dynamic> _generateUIUX(String prompt, String projectName) {
    return {
      'a. Design Principles': [
        'User-centered design with focus on intuitiveness',
        'Consistent visual language across all platforms',
        'Clear information hierarchy and content organization',
        'Responsive design for all device sizes',
        'Accessibility as a core design requirement',
      ],
      'b. Color Palette': {
        'Primary': '#3A86FF - Used for primary buttons, links, and highlights',
        'Secondary': '#FF006E - Used for secondary actions and accents',
        'Neutral': '#8D99AE - Used for text, borders, and inactive states',
        'Background': '#F8F9FA - Main background color',
        'Success': '#02C39A - Positive messages and actions',
        'Warning': '#FFBE0B - Warning messages and notifications',
        'Error': '#F94144 - Error messages and destructive actions',
      },
      'c. Typography': {
        'Primary Font': 'Inter - Used for all UI text',
        'Heading Sizes': 'H1: 32px, H2: 24px, H3: 20px, H4: 18px, H5: 16px',
        'Body Text': '16px for desktop, 14px for mobile',
        'Line Height': '1.5 for body text, 1.2 for headings',
        'Font Weights': 'Regular (400), Medium (500), Bold (700)',
      },
      'd. Component Library': [
        'Buttons (primary, secondary, tertiary, icon buttons)',
        'Input fields (text, number, date, dropdown, checkbox, radio)',
        'Cards (standard, interactive, information)',
        'Navigation (header, footer, sidebar, tabs)',
        'Modals and dialogs',
        'Tables and data display components',
        'Loaders and progress indicators',
      ],
      'e. User Flows': [
        'User registration and onboarding',
        'Authentication process',
        'Main feature navigation',
        'Content creation and management',
        'Checkout and payment process',
        'Account management',
      ],
      'f. Responsive Breakpoints': {
        'Mobile': '< 768px',
        'Tablet': '768px - 1023px',
        'Desktop': '1024px - 1439px',
        'Large Desktop': '≥ 1440px',
      },
      'g. Accessibility Guidelines': [
        'Color contrast ratio of at least 4.5:1 for normal text',
        'Keyboard navigation for all interactive elements',
        'Screen reader compatible with appropriate ARIA labels',
        'Support for text resizing up to a minimum of 200%',
        'Focus states for all interactive elements',
      ],
    };
  }
  
  // API Documentation
  Map<String, dynamic> _generateAPIDocs(String prompt, String projectName) {
    return {
      'a. API Overview': {
        'Base URL': 'https://api.example.com/v1',
        'Authentication': 'Bearer token in Authorization header',
        'Rate Limits': '100 requests per minute',
        'Formats': 'JSON for request and response bodies',
      },
      'b. Authentication': {
        'POST /auth/login': {
          'Description': 'Authenticate a user and receive access token',
          'Request Body': '{ "email": "string", "password": "string" }',
          'Response': '{ "access_token": "string", "refresh_token": "string", "expires_in": number }',
          'Status Codes': '200 OK, 401 Unauthorized, 429 Too Many Requests',
        },
        'POST /auth/refresh': {
          'Description': 'Refresh an expired access token',
          'Request Body': '{ "refresh_token": "string" }',
          'Response': '{ "access_token": "string", "refresh_token": "string", "expires_in": number }',
          'Status Codes': '200 OK, 401 Unauthorized, 429 Too Many Requests',
        },
      },
      'c. Users': {
        'GET /users/{id}': {
          'Description': 'Retrieve user information',
          'Parameters': 'id (path): User ID',
          'Response': '{ "id": "string", "email": "string", "name": "string", "role": "string", "created_at": "string" }',
          'Status Codes': '200 OK, 401 Unauthorized, 403 Forbidden, 404 Not Found',
        },
        'PUT /users/{id}': {
          'Description': 'Update user information',
          'Parameters': 'id (path): User ID',
          'Request Body': '{ "name": "string", "email": "string" }',
          'Response': '{ "id": "string", "email": "string", "name": "string", "role": "string", "updated_at": "string" }',
          'Status Codes': '200 OK, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found',
        },
      },
      'd. Content': {
        'GET /content': {
          'Description': 'List all content with pagination',
          'Parameters': 'page (query): Page number, limit (query): Items per page, status (query): Content status',
          'Response': '{ "items": [{ "id": "string", "title": "string", "status": "string", "created_at": "string" }], "total": number, "page": number, "limit": number }',
          'Status Codes': '200 OK, 401 Unauthorized, 403 Forbidden',
        },
        'POST /content': {
          'Description': 'Create new content',
          'Request Body': '{ "title": "string", "body": "string", "status": "string" }',
          'Response': '{ "id": "string", "title": "string", "body": "string", "status": "string", "created_at": "string" }',
          'Status Codes': '201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden',
        },
      },
      'e. Subscriptions': {
        'GET /subscriptions/{id}': {
          'Description': 'Retrieve subscription details',
          'Parameters': 'id (path): Subscription ID',
          'Response': '{ "id": "string", "user_id": "string", "plan_id": "string", "status": "string", "start_date": "string", "end_date": "string" }',
          'Status Codes': '200 OK, 401 Unauthorized, 403 Forbidden, 404 Not Found',
        },
        'POST /subscriptions': {
          'Description': 'Create a new subscription',
          'Request Body': '{ "plan_id": "string", "payment_method_id": "string" }',
          'Response': '{ "id": "string", "user_id": "string", "plan_id": "string", "status": "string", "start_date": "string", "end_date": "string" }',
          'Status Codes': '201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden',
        },
      },
    };
  }
  
  // Test Cases
  Map<String, dynamic> _generateTestCases(String prompt, String projectName) {
    return {
      'a. Unit Tests': {
        'UT-001: User Authentication': {
          'Description': 'Verify user authentication functionality',
          'Test Steps': [
            'Initialize authentication service with mock dependencies',
            'Call login method with valid credentials',
            'Verify returned token is valid',
            'Call login method with invalid credentials',
            'Verify error is thrown with appropriate message',
          ],
          'Expected Results': 'Valid credentials return a token, invalid credentials throw an error',
          'Priority': 'High',
        },
        'UT-002: Input Validation': {
          'Description': 'Verify input validation for user registration',
          'Test Steps': [
            'Initialize validation service',
            'Test email validation with valid and invalid emails',
            'Test password validation with valid and invalid passwords',
            'Test username validation with valid and invalid usernames',
          ],
          'Expected Results': 'Valid inputs pass validation, invalid inputs fail with specific error messages',
          'Priority': 'High',
        },
      },
      'b. Integration Tests': {
        'IT-001: User Registration Flow': {
          'Description': 'Verify end-to-end user registration process',
          'Test Steps': [
            'Send POST request to /api/users with valid user data',
            'Verify response status is 201 Created',
            'Verify confirmation email is sent',
            'Access confirmation link and verify account activation',
            'Attempt login with new credentials',
          ],
          'Expected Results': 'User successfully registered, email sent, account activated, and login successful',
          'Priority': 'High',
        },
        'IT-002: Payment Processing': {
          'Description': 'Verify payment processing and subscription creation',
          'Test Steps': [
            'Authenticate as a user',
            'Send POST request to /api/subscriptions with valid payment method',
            'Verify payment processor is called with correct amount',
            'Verify subscription is created with correct status',
            'Verify user has access to premium features',
          ],
          'Expected Results': 'Payment processed, subscription created, user has premium access',
          'Priority': 'High',
        },
      },
      'c. UI Tests': {
        'UI-001: Responsive Design': {
          'Description': 'Verify application is responsive across different screen sizes',
          'Test Steps': [
            'Load application in browser',
            'Test at mobile breakpoint (375px width)',
            'Test at tablet breakpoint (768px width)',
            'Test at desktop breakpoint (1024px width)',
            'Test at large desktop breakpoint (1440px width)',
          ],
          'Expected Results': 'UI elements adapt properly to each screen size without overflow or distortion',
          'Priority': 'Medium',
        },
        'UI-002: Form Validation': {
          'Description': 'Verify form validation in the UI',
          'Test Steps': [
            'Navigate to registration form',
            'Submit empty form and verify error messages',
            'Enter invalid email and verify specific error',
            'Enter weak password and verify specific error',
            'Enter valid data and verify form submission',
          ],
          'Expected Results': 'Appropriate error messages display for invalid inputs, form submits with valid data',
          'Priority': 'Medium',
        },
      },
      'd. Performance Tests': {
        'PT-001: Load Testing': {
          'Description': 'Verify system performance under load',
          'Test Steps': [
            'Configure load testing tool (e.g., JMeter) for 1000 concurrent users',
            'Simulate gradual ramp-up over 5 minutes',
            'Maintain peak load for 15 minutes',
            'Monitor response times, error rates, and system resources',
            'Gradually decrease load over 5 minutes',
          ],
          'Expected Results': 'Response times remain under 2s, error rate below 1%, no resource exhaustion',
          'Priority': 'Medium',
        },
        'PT-002: Database Performance': {
          'Description': 'Verify database performance for common queries',
          'Test Steps': [
            'Execute common database queries with query analyzer',
            'Verify execution plans are optimal',
            'Test with various data volumes (1K, 10K, 100K records)',
            'Measure query execution times',
          ],
          'Expected Results': 'Query execution times remain under 100ms for common operations',
          'Priority': 'Medium',
        },
      },
      'e. Security Tests': {
        'ST-001: Authentication Security': {
          'Description': 'Verify security of authentication mechanism',
          'Test Steps': [
            'Attempt brute force login with automated tool',
            'Verify rate limiting kicks in after multiple failures',
            'Test password reset functionality for security flaws',
            'Verify session timeout functionality',
            'Test for session fixation vulnerabilities',
          ],
          'Expected Results': 'Authentication mechanisms resist common attack vectors',
          'Priority': 'High',
        },
        'ST-002: API Security': {
          'Description': 'Verify API endpoints are secure',
          'Test Steps': [
            'Test endpoints for proper authorization checks',
            'Attempt accessing resources without proper permissions',
            'Test for SQL injection in query parameters',
            'Test for XSS vulnerabilities in response data',
            'Verify all sensitive data is encrypted in transit',
          ],
          'Expected Results': 'API endpoints properly validate authentication and authorization',
          'Priority': 'High',
        },
      },
    };
  }
  
  // Deployment Guide
  Map<String, dynamic> _generateDeploymentGuide(String prompt, String projectName) {
    return {
      'a. System Requirements': {
        'Production Server': 'AWS EC2 t3.large or equivalent (4 vCPU, 8GB RAM)',
        'Database': 'PostgreSQL 13+ (AWS RDS db.t3.medium or higher)',
        'Cache': 'Redis 6+ (AWS ElastiCache)',
        'Storage': 'AWS S3 for file storage, minimum 100GB',
        'CDN': 'CloudFront or similar for static assets',
        'SSL Certificate': 'Required for all environments',
      },
      'b. Prerequisites': [
        'AWS account with appropriate permissions',
        'Domain name registered and configured',
        'Docker installed for containerized deployment',
        'AWS CLI configured with deployment credentials',
        'Access to CI/CD system (GitHub Actions, Jenkins, etc.)',
        'Database backup strategy implemented',
      ],
      'c. Environment Setup': {
        'Development': {
          'Setup': 'Local Docker environment with docker-compose',
          'Database': 'PostgreSQL in Docker container',
          'Configuration': 'Use .env.development for environment variables',
        },
        'Staging': {
          'Setup': 'AWS ECS with scaled-down resources',
          'Database': 'RDS instance (smaller size than production)',
          'Configuration': 'Use Parameter Store for environment variables',
        },
        'Production': {
          'Setup': 'AWS ECS with auto-scaling',
          'Database': 'RDS instance with read replicas',
          'Configuration': 'Use Parameter Store with encryption for sensitive values',
        },
      },
      'd. Deployment Process': [
        '1. Merge code to appropriate branch (develop for staging, main for production)',
        '2. CI/CD pipeline automatically builds Docker images',
        '3. Run automated tests (unit, integration, security)',
        '4. Push Docker images to ECR repository',
        '5. Update ECS task definitions with new image URIs',
        '6. Perform database migrations if necessary',
        '7. Deploy new ECS tasks with blue/green deployment strategy',
        '8. Verify health checks pass for new deployment',
        '9. Switch traffic to new deployment if health checks pass',
        '10. Monitor application metrics after deployment',
      ],
      'e. Configuration': {
        'Environment Variables': [
          'DATABASE_URL: Connection string for PostgreSQL',
          'REDIS_URL: Connection string for Redis',
          'AWS_S3_BUCKET: Name of S3 bucket for file storage',
          'JWT_SECRET: Secret key for JWT signing',
          'API_RATE_LIMIT: Rate limit for API endpoints',
          'LOG_LEVEL: Logging level (debug, info, warn, error)',
        ],
        'Feature Flags': [
          'USE_NEW_PAYMENT_SYSTEM: Enable new payment processing system',
          'ENABLE_BETA_FEATURES: Show beta features to users',
          'MAINTENANCE_MODE: Put application in maintenance mode',
        ],
      },
      'f. Monitoring': {
        'Services': {
          'Application Monitoring': 'New Relic or Datadog',
          'Log Management': 'CloudWatch Logs with Elasticsearch',
          'Error Tracking': 'Sentry',
          'Performance Metrics': 'Prometheus with Grafana dashboards',
        },
        'Key Metrics': [
          'Response time by endpoint',
          'Error rate by endpoint',
          'Database query performance',
          'User signup and activity metrics',
          'System resource utilization',
        ],
      },
      'g. Rollback Procedure': [
        '1. Identify issue requiring rollback',
        '2. Update ECS service to use previous task definition',
        '3. Verify rollback deployment passes health checks',
        '4. Switch traffic back to previous version',
        '5. Revert database migrations if necessary',
        '6. Document rollback reason and follow-up actions',
      ],
      'h. Backup and Recovery': {
        'Database Backups': 'Automated daily backups with 30-day retention',
        'User Uploads': 'S3 versioning enabled with 90-day retention',
        'Configuration': 'Infrastructure as Code with version control',
        'Disaster Recovery': 'Cross-region replication for critical data',
      },
    };
  }
  
  // User Manual
  Map<String, dynamic> _generateUserManual(String prompt, String projectName) {
    return {
      'a. Introduction': {
        'About': 'Welcome to $projectName. This manual will guide you through the features and functionality of the application.',
        'Target Audience': 'This manual is intended for end users of the application.',
        'System Requirements': 'Modern web browser (Chrome, Firefox, Safari, Edge), internet connection',
        'Conventions': 'Bold text indicates UI elements, italic text indicates user input',
      },
      'b. Getting Started': {
        'Account Creation': {
          'Step 1': 'Navigate to the homepage and click **Sign Up**',
          'Step 2': 'Enter your email address and create a password',
          'Step 3': 'Check your email for a verification link',
          'Step 4': 'Click the verification link to activate your account',
        },
        'Logging In': {
          'Step 1': 'Navigate to the homepage and click **Log In**',
          'Step 2': 'Enter your email and password',
          'Step 3': 'Enable "Remember Me" for persistent login (optional)',
          'Step 4': 'Click **Log In** button to access your account',
        },
        'Resetting Password': {
          'Step 1': 'On the login page, click **Forgot Password**',
          'Step 2': 'Enter the email associated with your account',
          'Step 3': 'Check your email for password reset instructions',
          'Step 4': 'Create a new password following the provided guidelines',
        },
      },
      'c. Main Features': {
        'Dashboard': {
          'Overview': 'The dashboard displays a summary of your activity and quick access to main features',
          'Widgets': 'Customizable widgets show recent activity, statistics, and shortcuts',
          'Customization': 'Drag and drop widgets to rearrange your dashboard layout',
        },
        'Profile Management': {
          'Viewing Profile': 'Click your avatar in the top right corner, then select **Profile**',
          'Editing Profile': 'On your profile page, click **Edit Profile** to update personal information',
          'Privacy Settings': 'Manage your privacy preferences under the **Privacy** tab',
          'Notification Settings': 'Configure email and in-app notifications under the **Notifications** tab',
        },
        'Content Creation': {
          'Creating New Content': 'Click the **+** button in the navigation bar and select content type',
          'Saving Drafts': 'Click **Save Draft** to save your work without publishing',
          'Publishing': 'Click **Publish** when your content is ready to be visible to others',
          'Editing': 'Access your published content and click **Edit** to make changes',
        },
      },
      'd. Advanced Features': {
        'Search Functionality': {
          'Basic Search': 'Use the search bar at the top of the page to find content',
          'Advanced Search': 'Click the filter icon next to the search bar for advanced options',
          'Search Operators': 'Use quotes for exact phrases, AND/OR for boolean logic, and hashtags for topics',
        },
        'Collaboration Tools': {
          'Sharing Content': 'Click the **Share** button on any content to generate a shareable link',
          'Permission Settings': 'Set view, comment, or edit permissions when sharing',
          'Comments': 'Leave comments on content by clicking the comment icon',
          'Notifications': 'Receive notifications when others interact with your shared content',
        },
        'Subscription Management': {
          'Viewing Plans': 'Navigate to **Settings > Subscription** to view available plans',
          'Upgrading': 'Click **Upgrade** on your desired plan to proceed to payment',
          'Payment Information': 'Enter payment details in the secure payment form',
          'Managing Subscription': 'Cancel or change your subscription from the **Subscription** page',
        },
      },
      'e. Mobile App': {
        'Installation': {
          'iOS': 'Download from the App Store by searching for "$projectName"',
          'Android': 'Download from Google Play Store by searching for "$projectName"',
        },
        'Key Differences': {
          'Navigation': 'Use the bottom tab bar instead of the side navigation',
          'Gestures': 'Swipe left/right for additional actions',
          'Offline Mode': 'Access recently viewed content even without internet connection',
        },
        'Push Notifications': {
          'Enabling': 'When prompted, allow the app to send notifications',
          'Managing': 'Configure notification types in app settings',
          'Do Not Disturb': 'Set quiet hours for notifications',
        },
      },
      'f. Troubleshooting': {
        'Common Issues': {
          'Login Problems': 'Ensure caps lock is off, try password reset if needed',
          'Content Not Loading': 'Check your internet connection, refresh the page',
          'Payment Declined': 'Verify your payment information and bank authorization',
        },
        'Error Messages': {
          '404 Not Found': 'The requested page or resource does not exist',
          '403 Forbidden': 'You do not have permission to access this resource',
          '500 Server Error': 'A system error has occurred, please try again later',
        },
        'Contact Support': {
          'Email': 'support@example.com',
          'Live Chat': 'Available from the Help menu, Monday-Friday 9am-5pm',
          'Help Center': 'Browse knowledge base articles at help.example.com',
        },
      },
      'g. Glossary': {
        'API': 'Application Programming Interface - allows different software to communicate',
        'Dashboard': 'Main control panel showing overview of account activity',
        'OAuth': 'Authentication method using third-party services like Google or Facebook',
        'SSL': 'Secure Sockets Layer - technology for creating encrypted connections',
        'Two-Factor Authentication': 'Security feature requiring two forms of identification',
        'Widget': 'Small application component performing a specific function',
      },
      'h. Appendices': {
        'Keyboard Shortcuts': {
          'Ctrl/Cmd + F': 'Search within page',
          'Ctrl/Cmd + S': 'Save current work',
          'Ctrl/Cmd + P': 'Print current page',
          'Esc': 'Close current dialog or cancel operation',
        },
        'System Status': 'Check current system status at status.example.com',
        'Legal Information': 'Terms of Service and Privacy Policy available at example.com/legal',
        'Version History': 'Release notes for each version available at example.com/releases',
      },
    };
  }
  
  // Method to update an editable document
  Future<void> updateDocument(String documentType, String newContent) async {
    _documents[documentType] = newContent;
    notifyListeners();
  }
  
  // Method to delete a document
  void deleteDocument(String documentType) {
    if (_documents.containsKey(documentType)) {
      // Keep a copy for potential undo functionality
      final deletedContent = _documents[documentType];
      
      // Remove the document
      _documents.remove(documentType);
      notifyListeners();
    }
  }
  
  // Method to check if a document exists
  bool hasDocument(String documentType) {
    return _documents.containsKey(documentType);
  }
  
  // Method to adjust pricing manually
  void updatePricing({double? initialFee, double? monthlyFee}) {
    if (initialFee != null) {
      _projectEstimates['revenueEstimate']['initial'] = initialFee;
    }
    
    if (monthlyFee != null) {
      _projectEstimates['revenueEstimate']['monthly'] = monthlyFee;
      // Recalculate yearly total
      double initial = _projectEstimates['revenueEstimate']['initial'] ?? 0.0;
      double monthly = _projectEstimates['revenueEstimate']['monthly'] ?? 0.0;
      _projectEstimates['revenueEstimate']['yearlyTotal'] = initial + (monthly * 12);
    }
    
    notifyListeners();
  }
} 