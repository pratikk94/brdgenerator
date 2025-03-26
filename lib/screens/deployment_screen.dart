import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class DeploymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'Deployment Plan',
      initialData: PlanData.deployment,
      heroTag: 'hero_Deployment Plan',
    );
  }
} 