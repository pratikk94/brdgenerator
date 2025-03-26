import 'package:flutter/material.dart';
import '../data/plan_data.dart';

class DocsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documentation Checklist'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '11. Documentation Checklist',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            _buildContentSection(context, PlanData.docs),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Card(
          margin: EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 3.0,
          color: Colors.deepPurple.shade50,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 10.0),
                _buildContent(context, entry.value),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent(BuildContext context, dynamic content) {
    if (content is String) {
      return Text(
        content,
        style: TextStyle(fontSize: 16.0),
      );
    } else if (content is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((item) {
          return Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• '),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
    return SizedBox.shrink();
  }
} 