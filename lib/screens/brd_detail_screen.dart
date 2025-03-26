import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class BrdDetailScreen extends StatefulWidget {
  final String brdId;
  
  const BrdDetailScreen({
    Key? key,
    required this.brdId,
  }) : super(key: key);
  
  @override
  _BrdDetailScreenState createState() => _BrdDetailScreenState();
}

class _BrdDetailScreenState extends State<BrdDetailScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _brdData;
  bool _isLoading = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBrdData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBrdData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final brds = await _firebaseService.getAllBRDs();
      for (final brd in brds) {
        if (brd['id'] == widget.brdId) {
          setState(() {
            _brdData = brd;
            _isLoading = false;
          });
          return;
        }
      }
      
      // BRD not found
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading BRD data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_brdData != null ? (_brdData!['title'] as String? ?? 'BRD Details') : 'BRD Details'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'REQUIREMENTS'),
            Tab(text: 'FINANCIALS'),
            Tab(text: 'TIMELINE'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _brdData == null
              ? const Center(child: Text('BRD not found'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildRequirementsTab(),
                    _buildFinancialsTab(),
                    _buildTimelineTab(),
                  ],
                ),
    );
  }
  
  Widget _buildOverviewTab() {
    if (_brdData == null) return const SizedBox.shrink();
    
    final createdAt = DateTime.parse(_brdData!['createdAt'] as String);
    final formattedDate = DateFormat('MMMM d, yyyy').format(createdAt);
    final status = _brdData!['approvalStatus'] as String? ?? 'pending';
    final description = _brdData!['description'] as String? ?? 'No description available';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _brdData!['title'] as String? ?? 'Untitled BRD',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created on $formattedDate',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: status == 'approved' 
                            ? Colors.green.shade100 
                            : (status == 'rejected' ? Colors.red.shade100 : Colors.grey.shade100),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Project Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Project Type', _brdData!['projectType'] as String? ?? 'Not specified'),
                  _buildDetailRow('Industry', _brdData!['industry'] as String? ?? 'Not specified'),
                  _buildDetailRow('Client', _brdData!['client'] as String? ?? 'Not specified'),
                  _buildDetailRow('Priority', _brdData!['priority'] as String? ?? 'Medium'),
                  _buildDetailRow('Budget', '\$${_brdData!['budget'] ?? 'Not specified'}'),
                ],
              ),
            ),
          ),
          if (status == 'rejected' && _brdData!['comments'] != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rejection Comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_brdData!['comments'] as String),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRequirementsTab() {
    if (_brdData == null) return const SizedBox.shrink();
    
    final requirements = _brdData!['requirements'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (requirements.isEmpty)
                    const Text('No requirements specified')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requirements.length,
                      itemBuilder: (context, index) {
                        final requirement = requirements[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(requirement['title'] as String? ?? 'Requirement'),
                            subtitle: Text(requirement['description'] as String? ?? ''),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFinancialsTab() {
    if (_brdData == null) return const SizedBox.shrink();
    
    final cumulativeEarnings = _brdData!['cumulativeEarnings'] as num? ?? 0.0;
    final baselineCost = _brdData!['baselineCost'] as num? ?? 0.0;
    final profit = cumulativeEarnings - baselineCost;
    final profitMargin = cumulativeEarnings > 0 ? (profit / cumulativeEarnings * 100) : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFinancialRow('Cumulative Earnings', '\$${cumulativeEarnings.toStringAsFixed(2)}', Colors.green),
                  _buildFinancialRow('Baseline Cost', '\$${baselineCost.toStringAsFixed(2)}', Colors.red),
                  _buildFinancialRow('Profit', '\$${profit.toStringAsFixed(2)}', profit >= 0 ? Colors.green : Colors.red),
                  _buildFinancialRow('Profit Margin', '${profitMargin.toStringAsFixed(1)}%', 
                    profitMargin >= 30 ? Colors.green : (profitMargin >= 15 ? Colors.orange : Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineTab() {
    if (_brdData == null) return const SizedBox.shrink();
    
    final timeline = _brdData!['timeline'] as Map<String, dynamic>? ?? {};
    final startDate = timeline['startDate'] as String? ?? 'Not specified';
    final endDate = timeline['endDate'] as String? ?? 'Not specified';
    final duration = timeline['duration'] as String? ?? 'Not specified';
    final milestones = timeline['milestones'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Start Date', startDate),
                  _buildDetailRow('End Date', endDate),
                  _buildDetailRow('Duration', duration),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (milestones.isNotEmpty) 
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Milestones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: milestones.length,
                      itemBuilder: (context, index) {
                        final milestone = milestones[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber,
                              child: Icon(Icons.flag, color: Colors.white),
                            ),
                            title: Text(milestone['title'] as String? ?? 'Milestone'),
                            subtitle: Text(milestone['date'] as String? ?? 'Date not specified'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFinancialRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
} 