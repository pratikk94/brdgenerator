import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../widgets/loading_indicator.dart';

class TaskEstimateAdminScreen extends StatefulWidget {
  const TaskEstimateAdminScreen({super.key});

  @override
  State<TaskEstimateAdminScreen> createState() => _TaskEstimateAdminScreenState();
}

class _TaskEstimateAdminScreenState extends State<TaskEstimateAdminScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _estimates = [];
  Map<String, dynamic> _analytics = {
    'totalEstimates': 0,
    'averageHours': 0.0,
    'averageRate': 0.0,
    'totalPotentialEarnings': 0.0,
    'riskBreakdown': {'Low': 0, 'Medium': 0, 'High': 0},
    'complexityBreakdown': {'Low': 0, 'Medium': 0, 'High': 0},
    'skillsFrequency': <String, int>{},
  };
  
  // Settings controllers
  final TextEditingController _defaultRateController = TextEditingController(text: '50.0');
  final TextEditingController _profitMarginController = TextEditingController(text: '30.0');
  final TextEditingController _riskMultiplierController = TextEditingController(text: '1.5');
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEstimates();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _defaultRateController.dispose();
    _profitMarginController.dispose();
    _riskMultiplierController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    try {
      // Load admin settings from Firebase
      final settings = await _firebaseService.getAdminSettings();
      if (settings != null) {
        setState(() {
          _defaultRateController.text = settings['defaultRate']?.toString() ?? '50.0';
          _profitMarginController.text = settings['profitMargin']?.toString() ?? '30.0';
          _riskMultiplierController.text = settings['riskMultiplier']?.toString() ?? '1.5';
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final settings = {
        'defaultRate': double.parse(_defaultRateController.text),
        'profitMargin': double.parse(_profitMarginController.text),
        'riskMultiplier': double.parse(_riskMultiplierController.text),
      };
      
      await _firebaseService.saveAdminSettings(settings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }
  
  Future<void> _loadEstimates() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final estimates = await _firebaseService.getAllTaskEstimates();
      setState(() {
        _estimates = estimates;
        _isLoading = false;
      });
      _calculateAnalytics();
    } catch (e) {
      print('Error loading estimates: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading estimates: $e')),
      );
    }
  }
  
  void _calculateAnalytics() {
    if (_estimates.isEmpty) return;
    
    double totalHours = 0;
    double totalRate = 0;
    double totalEarnings = 0;
    final riskBreakdown = {'Low': 0, 'Medium': 0, 'High': 0};
    final complexityBreakdown = {'Low': 0, 'Medium': 0, 'High': 0};
    final skillsFrequency = <String, int>{};
    
    for (final estimate in _estimates) {
      // Calculate totals
      totalHours += (estimate['estimatedHours'] as num).toDouble();
      totalRate += (estimate['suggestedRate'] as num).toDouble();
      totalEarnings += (estimate['cumulativeEarnings'] as num).toDouble();
      
      // Risk breakdown
      final risk = estimate['riskFactor'] as String? ?? 'Medium';
      riskBreakdown[risk] = (riskBreakdown[risk] ?? 0) + 1;
      
      // Complexity breakdown
      final complexity = estimate['complexityLevel'] as String? ?? 'Medium';
      complexityBreakdown[complexity] = (complexityBreakdown[complexity] ?? 0) + 1;
      
      // Skills frequency
      final skills = (estimate['skillsRequired'] as List<dynamic>?) ?? [];
      for (final skill in skills) {
        skillsFrequency[skill.toString()] = (skillsFrequency[skill.toString()] ?? 0) + 1;
      }
    }
    
    setState(() {
      _analytics = {
        'totalEstimates': _estimates.length,
        'averageHours': totalHours / _estimates.length,
        'averageRate': totalRate / _estimates.length,
        'totalPotentialEarnings': totalEarnings,
        'riskBreakdown': riskBreakdown,
        'complexityBreakdown': complexityBreakdown,
        'skillsFrequency': skillsFrequency,
      };
    });
  }
  
  Future<void> _approveEstimate(String estimateId, bool approved) async {
    try {
      // Find the estimate
      final index = _estimates.indexWhere((e) => e['id'] == estimateId);
      if (index == -1) return;
      
      // Update the approval status
      final updatedEstimate = Map<String, dynamic>.from(_estimates[index]);
      updatedEstimate['approved'] = approved;
      updatedEstimate['reviewedAt'] = DateTime.now().toIso8601String();
      
      // Save to Firebase
      await _firebaseService.updateTaskEstimate(estimateId, updatedEstimate);
      
      // Update local state
      setState(() {
        _estimates[index] = updatedEstimate;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approved ? 'Estimate approved' : 'Estimate rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating estimate: $e')),
      );
    }
  }
  
  Future<void> _deleteEstimate(String estimateId) async {
    try {
      await _firebaseService.deleteTaskEstimate(estimateId);
      await _loadEstimates();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estimate deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting estimate: $e')),
      );
    }
  }
  
  // Build the estimates list tab
  Widget _buildEstimatesTab() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading estimates...'));
    }
    
    if (_estimates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No estimates found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _estimates.length,
      itemBuilder: (context, index) {
        final estimate = _estimates[index];
        final createdAt = DateTime.parse(estimate['createdAt'] as String);
        final formattedDate = DateFormat.yMMMd().add_jm().format(createdAt);
        final isApproved = estimate['approved'] as bool? ?? false;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    estimate['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isApproved ? 'Approved' : 'Pending',
                    style: TextStyle(
                      color: isApproved ? Colors.green : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text('\$${estimate['cumulativeEarnings']}'),
                      backgroundColor: Colors.green.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${estimate['estimatedHours']} hours'),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estimate['description'] as String,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildDetailRow('Risk Factor', estimate['riskFactor']),
                    _buildDetailRow('Complexity', estimate['complexityLevel']),
                    _buildDetailRow('Baseline Cost', '\$${estimate['baselineCost']}'),
                    _buildDetailRow('Hourly Rate', '\$${estimate['suggestedRate']}/hour'),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'Skills Required:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (estimate['skillsRequired'] as List<dynamic>? ?? ['Programming'])
                          .map((skill) => Chip(label: Text(skill.toString())))
                          .toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            _deleteEstimate(estimate['id'] as String);
                          },
                        ),
                        const SizedBox(width: 16),
                        if (!isApproved) ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              _approveEstimate(estimate['id'] as String, true);
                            },
                          ),
                        ] else ...[
                          TextButton.icon(
                            icon: const Icon(Icons.cancel, color: Colors.orange),
                            label: const Text('Revoke Approval', style: TextStyle(color: Colors.orange)),
                            onPressed: () {
                              _approveEstimate(estimate['id'] as String, false);
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build the analytics tab
  Widget _buildAnalyticsTab() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading analytics...'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildStatRow('Total Estimates', _analytics['totalEstimates'].toString()),
                  _buildStatRow('Average Hours', _analytics['averageHours'].toStringAsFixed(1)),
                  _buildStatRow('Average Rate', '\$${_analytics['averageRate'].toStringAsFixed(2)}/hour'),
                  _buildStatRow('Total Potential Earnings', '\$${_analytics['totalPotentialEarnings'].toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Risk Breakdown Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risk Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatPill('Low', _analytics['riskBreakdown']['Low'].toString(), Colors.green),
                      _buildStatPill('Medium', _analytics['riskBreakdown']['Medium'].toString(), Colors.orange),
                      _buildStatPill('High', _analytics['riskBreakdown']['High'].toString(), Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Complexity Breakdown Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complexity Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatPill('Low', _analytics['complexityBreakdown']['Low'].toString(), Colors.green),
                      _buildStatPill('Medium', _analytics['complexityBreakdown']['Medium'].toString(), Colors.blue),
                      _buildStatPill('High', _analytics['complexityBreakdown']['High'].toString(), Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Top Skills Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Most Requested Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getTopSkills(5).entries.map((entry) => 
                      Chip(
                        label: Text('${entry.key} (${entry.value})'),
                        backgroundColor: Colors.indigo.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.indigo),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the settings tab
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default Estimation Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Default hourly rate
                  TextField(
                    controller: _defaultRateController,
                    decoration: const InputDecoration(
                      labelText: 'Default Hourly Rate (USD)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Default profit margin
                  TextField(
                    controller: _profitMarginController,
                    decoration: const InputDecoration(
                      labelText: 'Default Profit Margin (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Risk multiplier
                  TextField(
                    controller: _riskMultiplierController,
                    decoration: const InputDecoration(
                      labelText: 'Risk Multiplier (for high-risk tasks)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build a stat row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build a stat pill
  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get top skills
  Map<String, int> _getTopSkills(int count) {
    final skillsMap = Map<String, int>.from(_analytics['skillsFrequency'] as Map<String, int>? ?? {});
    
    // Sort by count and take top 'count'
    final sortedEntries = skillsMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final result = <String, int>{};
    for (int i = 0; i < sortedEntries.length && i < count; i++) {
      result[sortedEntries[i].key] = sortedEntries[i].value;
    }
    
    return result;
  }
  
  // Helper method to build detail row
  Widget _buildDetailRow(String label, dynamic value) {
    Color valueColor = Colors.black;
    
    if (label == 'Risk Factor') {
      if (value == 'Low') valueColor = Colors.green;
      if (value == 'Medium') valueColor = Colors.orange;
      if (value == 'High') valueColor = Colors.red;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value.toString(),
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Estimate Admin'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Estimates'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEstimates,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEstimatesTab(),
          _buildAnalyticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }
} 