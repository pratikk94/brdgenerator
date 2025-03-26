import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class BRDResultScreen extends StatefulWidget {
  final String brdContent;
  final String proposalContent;
  final Map<String, dynamic> estimates;
  final Map<String, dynamic> executionSteps;
  final Map<String, dynamic> riskAssessment;
  final Map<String, dynamic> earningsProjection;

  const BRDResultScreen({
    Key? key,
    required this.brdContent,
    required this.proposalContent,
    required this.estimates,
    required this.executionSteps,
    required this.riskAssessment,
    required this.earningsProjection,
  }) : super(key: key);

  @override
  _BRDResultScreenState createState() => _BRDResultScreenState();
}

class _BRDResultScreenState extends State<BRDResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Copy content to clipboard
  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Documents'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'BRD Document'),
            Tab(text: 'Client Proposal'),
            Tab(text: 'Project Estimate'),
            Tab(text: 'Execution Steps'),
            Tab(text: 'Risk Assessment'),
            Tab(text: 'Earnings Projection'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            tooltip: 'Copy current document',
            onPressed: () {
              switch (_tabController.index) {
                case 0:
                  _copyToClipboard(widget.brdContent);
                  break;
                case 1:
                  _copyToClipboard(widget.proposalContent);
                  break;
                case 2:
                  _copyToClipboard(
                    'Timeline: ${widget.estimates['timelineTotal']} weeks\n'
                    'Budget: \$${widget.estimates['costTotal']}\n'
                    'Monthly maintenance: \$${widget.estimates['maintenanceCost']}'
                  );
                  break;
                case 3:
                  _copyToClipboard(widget.executionSteps.toString());
                  break;
                case 4:
                  _copyToClipboard(widget.riskAssessment.toString());
                  break;
                case 5:
                  _copyToClipboard(widget.earningsProjection.toString());
                  break;
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // BRD Document Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.copy),
                      label: Text('Copy BRD'),
                      onPressed: () => _copyToClipboard(widget.brdContent),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: MarkdownBody(
                      data: widget.brdContent,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Client Proposal Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.copy),
                      label: Text('Copy Proposal'),
                      onPressed: () => _copyToClipboard(widget.proposalContent),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: MarkdownBody(
                      data: widget.proposalContent,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Project Estimates Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Estimates',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Total Timeline
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.blue.shade50,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Timeline',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${widget.estimates['timelineTotal'] ?? 'N/A'} weeks',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Card(
                                color: Colors.green.shade50,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Budget',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '\$${widget.estimates['costTotal'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        // Monthly Maintenance
                        Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.update, color: Colors.orange),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Monthly Maintenance',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${widget.estimates['maintenanceCost'] ?? 'N/A'} per month',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Timeline breakdown
                        if (widget.estimates.containsKey('timelineBreakdown')) ...[
                          Text(
                            'Timeline Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (widget.estimates['timelineBreakdown'] as Map<String, dynamic>).length,
                            itemBuilder: (context, index) {
                              final phase = (widget.estimates['timelineBreakdown'] as Map<String, dynamic>).entries.elementAt(index);
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                title: Text(phase.key),
                                subtitle: Text('${phase.value} weeks'),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                        ],
                        
                        // Cost breakdown
                        if (widget.estimates.containsKey('costBreakdown')) ...[
                          Text(
                            'Cost Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (widget.estimates['costBreakdown'] as Map<String, dynamic>).length,
                            itemBuilder: (context, index) {
                              final category = (widget.estimates['costBreakdown'] as Map<String, dynamic>).entries.elementAt(index);
                              return ListTile(
                                leading: Icon(Icons.attach_money, color: Colors.green),
                                title: Text(category.key),
                                trailing: Text(
                                  '\$${category.value}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Execution Steps Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Execution Steps',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        if (widget.executionSteps.containsKey('phases')) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (widget.executionSteps['phases'] as List).length,
                            itemBuilder: (context, index) {
                              final phase = (widget.executionSteps['phases'] as List)[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 16),
                                child: ExpansionTile(
                                  title: Text(
                                    phase['name'] ?? 'Phase ${index + 1}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Duration: ${phase['duration'] ?? 'Unknown'}',
                                  ),
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            phase['description'] ?? 'No description available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          
                                          if (phase.containsKey('tasks') && phase['tasks'] is List) ...[
                                            Text(
                                              'Tasks:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: (phase['tasks'] as List).length,
                                              itemBuilder: (context, taskIndex) {
                                                final task = (phase['tasks'] as List)[taskIndex];
                                                return ListTile(
                                                  leading: Icon(Icons.check_circle_outline),
                                                  title: Text(task is String ? task : task['name'] ?? 'Task ${taskIndex + 1}'),
                                                  dense: true,
                                                );
                                              },
                                            ),
                                          ],
                                          
                                          if (phase.containsKey('resources') && phase['resources'] is List) ...[
                                            SizedBox(height: 16),
                                            Text(
                                              'Resources needed:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              children: (phase['resources'] as List).map((resource) {
                                                return Chip(
                                                  label: Text(resource is String ? resource : resource.toString()),
                                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                          
                                          if (phase.containsKey('deliverables') && phase['deliverables'] is List) ...[
                                            SizedBox(height: 16),
                                            Text(
                                              'Deliverables:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: (phase['deliverables'] as List).length,
                                              itemBuilder: (context, deliverableIndex) {
                                                final deliverable = (phase['deliverables'] as List)[deliverableIndex];
                                                return ListTile(
                                                  leading: Icon(Icons.file_present),
                                                  title: Text(deliverable is String ? deliverable : deliverable.toString()),
                                                  dense: true,
                                                );
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          Center(
                            child: Text('No execution steps available'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Risk Assessment Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Risk Assessment',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        if (widget.riskAssessment.containsKey('risks')) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (widget.riskAssessment['risks'] as List).length,
                            itemBuilder: (context, index) {
                              final risk = (widget.riskAssessment['risks'] as List)[index];
                              
                              Color getRiskColor(String rating) {
                                switch (rating.toLowerCase()) {
                                  case 'low': return Colors.green;
                                  case 'medium': return Colors.orange;
                                  case 'high': return Colors.red;
                                  default: return Colors.grey;
                                }
                              }
                              
                              return Card(
                                margin: EdgeInsets.only(bottom: 16),
                                child: ExpansionTile(
                                  title: Text(
                                    risk['description'] ?? 'Risk ${index + 1}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Type: ${risk['type'] ?? 'Unknown'}',
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: getRiskColor(risk['rating'] ?? 'Medium'),
                                    foregroundColor: Colors.white,
                                    child: Icon(Icons.warning),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildRiskDetailCard(
                                                  'Probability',
                                                  risk['probability'] ?? 'Medium',
                                                  getRiskColor(risk['probability'] ?? 'Medium'),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: _buildRiskDetailCard(
                                                  'Impact',
                                                  risk['impact'] ?? 'Medium',
                                                  getRiskColor(risk['impact'] ?? 'Medium'),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: _buildRiskDetailCard(
                                                  'Overall Rating',
                                                  risk['rating'] ?? 'Medium',
                                                  getRiskColor(risk['rating'] ?? 'Medium'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          
                                          if (risk.containsKey('mitigation')) ...[
                                            Text(
                                              'Mitigation Strategy:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Text(risk['mitigation']),
                                          ],
                                          
                                          SizedBox(height: 16),
                                          
                                          if (risk.containsKey('contingency')) ...[
                                            Text(
                                              'Contingency Plan:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Text(risk['contingency']),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          Center(
                            child: Text('No risk assessment available'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Earnings Projection Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Earnings Projection',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        if (widget.earningsProjection.containsKey('projections')) ...[
                          // ROI Summary Card
                          if (widget.earningsProjection.containsKey('roi')) ...[
                            Card(
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ROI Summary',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Expected ROI: ${widget.earningsProjection['roi'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Break-Even Point: ${widget.earningsProjection['breakEven'] ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                          
                          // Scenarios Card
                          if (widget.earningsProjection.containsKey('scenarios')) ...[
                            Text(
                              'Earnings Scenarios',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEarningsScenarioCard(
                                    'Pessimistic',
                                    (widget.earningsProjection['scenarios'] as Map<String, dynamic>)['pessimistic']?.toString() ?? 'N/A',
                                    Colors.red.shade100,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildEarningsScenarioCard(
                                    'Realistic',
                                    (widget.earningsProjection['scenarios'] as Map<String, dynamic>)['realistic']?.toString() ?? 'N/A',
                                    Colors.blue.shade100,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildEarningsScenarioCard(
                                    'Optimistic',
                                    (widget.earningsProjection['scenarios'] as Map<String, dynamic>)['optimistic']?.toString() ?? 'N/A',
                                    Colors.green.shade100,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                          
                          // Yearly Projections
                          if (widget.earningsProjection['projections'] is Map<String, dynamic>) ...[
                            Text(
                              'Yearly Projections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: (widget.earningsProjection['projections'] as Map<String, dynamic>).length,
                              itemBuilder: (context, index) {
                                final yearEntry = (widget.earningsProjection['projections'] as Map<String, dynamic>).entries.elementAt(index);
                                final yearData = yearEntry.value;
                                
                                return Card(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ExpansionTile(
                                    title: Text(
                                      'Year ${index + 1}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Total: \$${yearData['total'] ?? 'N/A'}',
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (yearData.containsKey('quarters') && yearData['quarters'] is Map) ...[
                                              Text(
                                                'Quarterly Breakdown:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 8),
                                              
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: (yearData['quarters'] as Map).length,
                                                itemBuilder: (context, quarterIndex) {
                                                  final quarterEntry = (yearData['quarters'] as Map).entries.elementAt(quarterIndex);
                                                  
                                                  return ListTile(
                                                    title: Text('Q${quarterIndex + 1}'),
                                                    trailing: Text(
                                                      '\$${quarterEntry.value}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                            
                                            if (yearData.containsKey('roi')) ...[
                                              SizedBox(height: 8),
                                              Text(
                                                'ROI: ${yearData['roi']}',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                          
                          // Recommendations
                          if (widget.earningsProjection.containsKey('recommendations') && 
                              widget.earningsProjection['recommendations'] is List) ...[
                            SizedBox(height: 24),
                            Text(
                              'Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            
                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var recommendation in widget.earningsProjection['recommendations'] as List)
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.lightbulb, color: Colors.amber),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(recommendation is String ? recommendation : recommendation.toString()),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ] else ...[
                          Center(
                            child: Text('No earnings projection available'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.copy_all),
                  label: Text('Copy All'),
                  onPressed: () {
                    switch (_tabController.index) {
                      case 0:
                        _copyToClipboard(widget.brdContent);
                        break;
                      case 1:
                        _copyToClipboard(widget.proposalContent);
                        break;
                      case 2:
                        _copyToClipboard(
                          'Timeline: ${widget.estimates['timelineTotal']} weeks\n'
                          'Budget: \$${widget.estimates['costTotal']}\n'
                          'Monthly maintenance: \$${widget.estimates['maintenanceCost']}'
                        );
                        break;
                      case 3:
                        _copyToClipboard(widget.executionSteps.toString());
                        break;
                      case 4:
                        _copyToClipboard(widget.riskAssessment.toString());
                        break;
                      case 5:
                        _copyToClipboard(widget.earningsProjection.toString());
                        break;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRiskDetailCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEarningsScenarioCard(String title, String value, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 