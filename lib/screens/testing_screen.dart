import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class TestingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'Testing Plan',
      initialData: PlanData.testing,
      heroTag: 'hero_Testing Plan',
    );
  }
} 