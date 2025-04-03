import 'package:flutter/material.dart';
import '../data/plan_data.dart';

class BRDScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Requirements'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Business Requirements Document (BRD)',
                style: TextStyle(
                  fontSize: 22.0 * textScaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenSize.height * 0.025),
              _buildContentSection(context, PlanData.brd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, Map<String, dynamic> data) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenSize = MediaQuery.of(context).size;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: TextStyle(
                fontSize: 18.0 * textScaleFactor,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: screenSize.height * 0.015),
            _buildContent(context, entry.value),
            SizedBox(height: screenSize.height * 0.025),
            Divider(),
            SizedBox(height: screenSize.height * 0.015),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildContent(BuildContext context, dynamic content) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenSize = MediaQuery.of(context).size;
    
    if (content is String) {
      return Text(
        content,
        style: TextStyle(fontSize: 16.0 * textScaleFactor),
      );
    } else if (content is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((item) {
          return Padding(
            padding: EdgeInsets.only(
              left: screenSize.width * 0.04,
              bottom: screenSize.height * 0.01
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 16.0 * textScaleFactor)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 16.0 * textScaleFactor),
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
            padding: EdgeInsets.only(
              left: screenSize.width * 0.04,
              bottom: screenSize.height * 0.01
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.key,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0 * textScaleFactor,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  item.value.toString(),
                  style: TextStyle(fontSize: 15.0 * textScaleFactor),
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