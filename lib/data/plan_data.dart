class PlanData {
  static final Map<String, dynamic> brd = {
    'a. Project Name': 'AI-Powered Learning Assistant',
    'b. Executive Summary': 'A smart AI-enabled platform that helps users learn new concepts through personalized tutoring, quizzes, and video explanations.',
    'c. Business Objectives': [
      'Automate tutoring using AI',
      'Increase accessibility to quality education',
      'Reduce human dependency for teaching',
    ],
    'd. Stakeholders': [
      'Product Owner',
      'End Users (Students, Educators)',
      'Technical Team (Dev, QA, UI/UX)',
      'Business Analyst',
      'Investors / Sponsors',
    ],
    'e. Scope': {
      'In Scope': 'User onboarding, course selection, and AI tutoring, Admin dashboard, Quiz generation',
      'Out of Scope': 'Certification engine (Phase 2), Multilingual support (future roadmap)',
    },
    'f. Success Metrics': [
      'Launch in 90 days',
      '10,000 users in 6 months',
      '80%+ satisfaction in user feedback',
      '50% repeat usage within 7 days',
    ],
  };

  static final Map<String, dynamic> frd = {
    'a. User Roles': [
      'Guest',
      'Registered User',
      'Admin',
      'Tutor (Optional for hybrid AI + Human models)',
    ],
    'b. Functional Modules': {
      'F1: User Signup/Login': 'Email, Google OAuth (High Priority)',
      'F2: Dashboard': 'Personalized interface (High Priority)',
      'F3: AI Tutor': 'NLP-based learning assistant (High Priority)',
      'F4: Quiz Generator': 'AI-powered auto quizzes (Medium Priority)',
      'F5: Admin Panel': 'Manage users/content (High Priority)',
      'F6: Feedback System': 'Ratings and comments (Low Priority)',
    },
  };

  static final Map<String, dynamic> nfr = {
    'Performance': 'Response time < 2s',
    'Scalability': '10,000 concurrent users',
    'Availability': '99.9% uptime',
    'Security': 'JWT, OAuth2, data encryption',
    'SEO': 'Basic SEO tags and schema markup',
    'Accessibility': 'WCAG 2.1 AA compliance',
  };

  static final Map<String, dynamic> tdd = {
    'a. Architecture': [
      'Frontend: React.js / Next.js / Tailwind',
      'Backend: Node.js / NestJS / Python (Flask for AI)',
      'Database: PostgreSQL / MongoDB',
      'AI Layer: OpenAI API, LangChain, Hugging Face',
      'Hosting: Vercel / AWS / GCP',
    ],
    'b. Component Design': [
      'Auth Service',
      'AI Service',
      'Course Service',
      'User & Session Tracking',
      'Notification System (Email/SMS)',
    ],
    'c. APIs': {
      'Register User': 'POST /api/auth/register - Create new user',
      'Get Courses': 'GET /api/courses - List of courses',
      'Ask AI Tutor': 'POST /api/ai/ask - Query AI tutor',
      'Submit Feedback': 'POST /api/feedback - Save user feedback',
    },
  };

  static final Map<String, dynamic> uiux = {
    'a. Design Tools': ['Figma / Adobe XD'],
    'b. Design Deliverables': [
      'User Journey Map',
      'Wireframes (low and high fidelity)',
      'Responsive UI for mobile and desktop',
      'Accessibility checks',
      'Color palette and font guide',
    ],
  };

  static final Map<String, dynamic> timeline = {
    'Week 1–2': 'Planning - BRD, FRD, TDD',
    'Week 3–4': 'Design - UI mockups',
    'Week 5–7': 'Dev Sprint 1 - Auth, Dashboard',
    'Week 8–10': 'Dev Sprint 2 - AI Tutor, Quiz Engine',
    'Week 11': 'Testing - Unit, Integration',
    'Week 12': 'Deployment - Live on cloud',
    'Week 13+': 'Feedback Loop - Monitor, Bugfixes',
  };

  static final Map<String, dynamic> testing = {
    'a. Testing Types': [
      'Unit Testing',
      'Integration Testing',
      'E2E Testing',
      'Load Testing',
      'Vulnerability & Security Testing',
      'User Acceptance Testing (UAT)',
    ],
    'b. Tools': [
      'Jest, Cypress',
      'Postman',
      'Lighthouse',
      'OWASP ZAP (Security)',
    ],
  };

  static final Map<String, dynamic> deployment = {
    'a. Environments': [
      'Local',
      'Development (Staging)',
      'Production (Live)',
    ],
    'b. CI/CD Setup': [
      'GitHub Actions / GitLab CI',
      'Docker-based deployment',
      'Rollback strategy',
    ],
    'c. Monitoring': [
      'Logs: Winston / LogRocket',
      'Alerts: Sentry / Datadog',
      'Performance: Google Lighthouse, New Relic',
    ],
  };

  static final Map<String, dynamic> support = {
    'Documentation': 'Dev + API docs (Swagger)',
    'Bug Fixing': 'SLA-based resolution',
    'Versioning': 'Semantic versioning (v1.0.0)',
    'Feedback': 'In-app survey + Google Form',
    'Training': 'Admin training & knowledge base',
  };

  static final Map<String, dynamic> risks = {
    'Delay in AI API response': 'Medium likelihood, High impact - Cache common queries',
    'Feature creep': 'High likelihood, Medium impact - Freeze MVP scope',
    'Budget overrun': 'Medium likelihood, High impact - Weekly burn tracking',
    'Tech debt': 'High likelihood, Medium impact - Dedicated refactor sprints',
  };

  static final Map<String, dynamic> docs = {
    'Documentation Checklist': [
      '✅ BRD',
      '✅ FRD',
      '✅ NFR',
      '✅ TDD',
      '✅ UI/UX Docs',
      '✅ API Docs (Swagger)',
      '✅ Test Cases',
      '✅ Deployment Guide',
      '✅ User Manual',
    ],
  };

  static final Map<String, dynamic> cost = {
    'Frontend Dev': '160 hours × \$40/hr = \$6,400',
    'Backend Dev': '160 hours × \$45/hr = \$7,200',
    'AI Engineer': '100 hours × \$60/hr = \$6,000',
    'UI/UX': '60 hours × \$30/hr = \$1,800',
    'PM': '80 hours × \$50/hr = \$4,000',
    'Total Estimate': '~\$25,000 – \$30,000',
  };
} 