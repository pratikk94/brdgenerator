import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class UIUXScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'UI/UX Plan',
      initialData: PlanData.uiux,
      heroTag: 'hero_UI/UX Plan',
    );
  }
} 