import 'package:flutter/material.dart';
import 'base_editable_screen.dart';
import '../data/plan_data.dart';

class TDDScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseEditableScreen(
      title: 'Technical Design Document',
      initialData: PlanData.tdd,
      heroTag: 'hero_Technical Design Document',
    );
  }
} 