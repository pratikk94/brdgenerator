import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../widgets/loading_indicator.dart';

class TaskEstimatesListScreen extends StatefulWidget {
  const TaskEstimatesListScreen({super.key});

  @override
  State<TaskEstimatesListScreen> createState() => _TaskEstimatesListScreenState();
}

class _TaskEstimatesListScreenState extends State<TaskEstimatesListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _estimates = [];
  
  @override
  void initState() {
    super.initState();
    _loadEstimates();
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
  
  Widget _buildEstimateCard(Map<String, dynamic> estimate) {
    final createdAt = DateTime.parse(estimate['createdAt'] as String);
    final formattedDate = DateFormat.yMMMd().add_jm().format(createdAt);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          estimate['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                const SizedBox(height: 8),
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
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add as Task'),
                      onPressed: () {
                        // TODO: Implement adding as a task in a board
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task creation to be implemented')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
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
        title: const Text('Saved Task Estimates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEstimates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator(message: 'Loading estimates...'))
          : _estimates.isEmpty
              ? Center(
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
                        'No task estimates found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create New Estimate'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _estimates.length,
                  itemBuilder: (context, index) {
                    return _buildEstimateCard(_estimates[index]);
                  },
                ),
    );
  }
} 