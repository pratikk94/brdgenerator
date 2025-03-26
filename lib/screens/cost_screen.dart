import 'package:flutter/material.dart';
import '../data/plan_data.dart';

class CostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cost Estimation'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '12. Cost Estimation',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            _buildCostTable(context, PlanData.cost),
          ],
        ),
      ),
    );
  }

  Widget _buildCostTable(BuildContext context, Map<String, dynamic> costData) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Headers
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Role / Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Cost Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            Divider(thickness: 2.0, color: Colors.green.shade100),
            SizedBox(height: 8.0),
            
            // Cost items
            ...costData.entries.map((entry) {
              bool isTotal = entry.key == 'Total Estimate';
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                            fontSize: isTotal ? 16.0 : 15.0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                            fontSize: isTotal ? 16.0 : 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isTotal) 
                    SizedBox.shrink()
                  else
                    Divider(height: 24.0),
                ],
              );
            }).toList(),
            
            // Total
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: Colors.green.shade700),
                  SizedBox(width: 8.0),
                  Text(
                    'Total Budget: ~\$25,000 – \$30,000',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 