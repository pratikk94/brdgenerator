import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'Post-Launch Support',
      initialData: PlanData.support,
      heroTag: 'hero_Post-Launch Support',
    );
  }
} 