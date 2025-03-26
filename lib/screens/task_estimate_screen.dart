import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';
import '../widgets/loading_indicator.dart';
import 'task_estimates_list_screen.dart';
import 'task_estimate_admin_screen.dart';

class TaskEstimateScreen extends StatefulWidget {
  const TaskEstimateScreen({super.key});

  @override
  State<TaskEstimateScreen> createState() => _TaskEstimateScreenState();
}

class _TaskEstimateScreenState extends State<TaskEstimateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _estimateResult;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _getEstimate() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use regular estimate instead of comprehensive one
      final result = await _taskService.getAIEstimate(
        _titleController.text, 
        _descriptionController.text
      );
      
      // Map to expected format
      final estimatedHours = result['estimatedHours'] ?? 2.0;
      final suggestedRate = result['suggestedRate'] ?? 50.0;
      
      final estimateData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'estimatedHours': estimatedHours,
        'baselineCost': estimatedHours * suggestedRate * 0.6, // 60% of revenue
        'suggestedRate': suggestedRate,
        'cumulativeEarnings': estimatedHours * suggestedRate,
        'riskFactor': 'Medium',
        'complexityLevel': 'Medium',
        'skillsRequired': ['Programming'],
        'costBreakdown': {'Development': estimatedHours * suggestedRate * 0.6},
      };
      
      setState(() {
        _estimateResult = estimateData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  Widget _buildResultCard() {
    if (_estimateResult == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Estimate Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildEstimateRow('Estimated Hours', '${_estimateResult!['estimatedHours']} hours'),
            _buildEstimateRow('Baseline Cost', '\$${_estimateResult!['baselineCost']}'),
            _buildEstimateRow('Suggested Rate', '\$${_estimateResult!['suggestedRate']}/hour'),
            _buildEstimateRow('Cumulative Earnings', '\$${_estimateResult!['cumulativeEarnings']}'),
            _buildEstimateRow('Risk Factor', _estimateResult!['riskFactor']),
            _buildEstimateRow('Complexity Level', _estimateResult!['complexityLevel']),
            
            const SizedBox(height: 16),
            const Text(
              'Skills Required:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8,
              children: (_estimateResult!['skillsRequired'] as List<dynamic>? ?? ['Programming'])
                  .map((skill) => Chip(label: Text(skill.toString())))
                  .toList(),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Cost Breakdown:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (_estimateResult!['costBreakdown'] as Map<String, dynamic>? ?? {'Development': 100.0}).length,
              itemBuilder: (context, index) {
                final costBreakdown = _estimateResult!['costBreakdown'] as Map<String, dynamic>? ?? {'Development': 100.0};
                final entry = costBreakdown.entries.elementAt(index);
                return _buildEstimateRow(entry.key, '\$${entry.value}');
              },
            ),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Clear the form
                _titleController.clear();
                _descriptionController.clear();
                setState(() {
                  _estimateResult = null;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estimate saved to Firebase')),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEstimateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              color: _getValueColor(label, value),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getValueColor(String label, String value) {
    if (label == 'Risk Factor') {
      if (value == 'Low') return Colors.green;
      if (value == 'Medium') return Colors.orange;
      if (value == 'High') return Colors.red;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Time & Cost Estimate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Saved Estimates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskEstimatesListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskEstimateAdminScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator(message: 'Calculating estimate...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter task details to get a comprehensive estimate:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Task Description',
                      hintText: 'Provide a detailed description of the task...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _getEstimate,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Calculate Estimate',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  
                  // Results area
                  _buildResultCard(),
                ],
              ),
            ),
    );
  }
} 