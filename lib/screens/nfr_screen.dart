import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class NFRScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'Non-Functional Requirements',
      initialData: PlanData.nfr,
      heroTag: 'hero_Non-Functional Requirements',
    );
  }
} 