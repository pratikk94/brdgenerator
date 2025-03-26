import 'package:flutter/material.dart';
import '../widgets/section_content.dart';
import '../data/plan_data.dart';

class ProjectPlanScreen extends StatefulWidget {
  @override
  _ProjectPlanScreenState createState() => _ProjectPlanScreenState();
}

class _ProjectPlanScreenState extends State<ProjectPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'BRD',
    'FRD',
    'NFRs',
    'TDD',
    'UI/UX',
    'Timeline',
    'Testing',
    'Deployment',
    'Support',
    'Risks',
    'Docs',
    'Cost',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Implementation Plan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SectionContent(title: '1. Business Requirements Document (BRD)', content: PlanData.brd),
          SectionContent(title: '2. Functional Requirements Document (FRD)', content: PlanData.frd),
          SectionContent(title: '3. Non-Functional Requirements (NFRs)', content: PlanData.nfr),
          SectionContent(title: '4. Technical Design Document (TDD)', content: PlanData.tdd),
          SectionContent(title: '5. UI/UX Plan', content: PlanData.uiux),
          SectionContent(title: '6. Project Timeline & Milestones', content: PlanData.timeline),
          SectionContent(title: '7. Testing Plan', content: PlanData.testing),
          SectionContent(title: '8. Deployment Plan', content: PlanData.deployment),
          SectionContent(title: '9. Post-Launch Support', content: PlanData.support),
          SectionContent(title: '10. Risk Management Plan', content: PlanData.risks),
          SectionContent(title: '11. Documentation Checklist', content: PlanData.docs),
          SectionContent(title: '12. Cost Estimation', content: PlanData.cost),
        ],
      ),
    );
  }
} 