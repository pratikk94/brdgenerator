import 'package:flutter/material.dart';
import '../data/plan_data.dart';

class FRDScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Functional Requirements'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Functional Requirements Document (FRD)',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            _buildContentSection(context, PlanData.frd),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.0),
            _buildContent(context, entry.value),
            SizedBox(height: 20.0),
            Divider(),
            SizedBox(height: 10.0),
          ],
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
    } else if (content is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.entries.map((item) {
          return Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.key,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  item.value.toString(),
                  style: TextStyle(fontSize: 15.0),
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