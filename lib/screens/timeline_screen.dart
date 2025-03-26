import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class TimelineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'Project Timeline & Milestones',
      initialData: PlanData.timeline,
      heroTag: 'hero_Project Timeline & Milestones',
    );
  }
} 