import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../state/task_state.dart';
import '../state/document_state.dart';

class TaskStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  
  const TaskStatisticsCard({
    Key? key, 
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskState = Provider.of<TaskState>(context);
    final documentState = Provider.of<DocumentState>(context);
    
    final totalEstimatedHours = statistics['totalEstimatedHours'] as double;
    final totalActualHours = statistics['totalActualHours'] as double;
    final remainingHours = totalEstimatedHours - totalActualHours;
    
    final totalRevenuePotential = statistics['totalRevenuePotential'] as double;
    final totalRevenueGenerated = statistics['totalRevenueGenerated'] as double;
    final remainingRevenue = totalRevenuePotential - totalRevenueGenerated;
    
    final overallEfficiency = statistics['overallEfficiency'] as double;
    final completionPercentage = statistics['completionPercentage'] as double;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTaskCountsRow(),
            const Divider(height: 24),
            _buildTimeMetricsRow(),
            const Divider(height: 24),
            _buildRevenueRow(context),
            const Divider(height: 24),
            _buildEfficiencyRow(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaskCountsRow() {
    final taskCounts = statistics['taskCounts'] as Map<TaskStatus, int>;
    final totalTasks = taskCounts.values.fold<int>(0, (a, b) => a + b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTaskCountItem(
          'Total',
          totalTasks,
          Colors.indigo,
          Icons.assignment,
        ),
        _buildTaskCountItem(
          'To Do',
          taskCounts[TaskStatus.todo] ?? 0,
          Colors.grey,
          Icons.checklist,
        ),
        _buildTaskCountItem(
          'Doing',
          taskCounts[TaskStatus.doing] ?? 0,
          Colors.blue,
          Icons.play_circle_outline,
        ),
        _buildTaskCountItem(
          'Done',
          taskCounts[TaskStatus.done] ?? 0,
          Colors.green,
          Icons.check_circle_outline,
        ),
      ],
    );
  }
  
  Widget _buildTaskCountItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeMetricsRow() {
    final totalEstimatedHours = statistics['totalEstimatedHours'] as double;
    final totalActualHours = statistics['totalActualHours'] as double;
    final remainingHours = totalEstimatedHours - totalActualHours;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem(
          'Estimated Hours',
          '${totalEstimatedHours.toStringAsFixed(1)} hrs',
          Icons.timer_outlined,
          Colors.blue,
        ),
        _buildMetricItem(
          'Actual Hours',
          '${totalActualHours.toStringAsFixed(1)} hrs',
          Icons.hourglass_bottom,
          Colors.orange,
        ),
        _buildMetricItem(
          'Remaining',
          '${remainingHours.toStringAsFixed(1)} hrs',
          Icons.hourglass_empty,
          Colors.green,
        ),
      ],
    );
  }
  
  Widget _buildRevenueRow(BuildContext context) {
    final documentState = Provider.of<DocumentState>(context);
    final totalRevenuePotential = statistics['totalRevenuePotential'] as double;
    final totalRevenueGenerated = statistics['totalRevenueGenerated'] as double;
    final remainingRevenue = totalRevenuePotential - totalRevenueGenerated;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem(
          'Potential Revenue',
          documentState.formatCurrency(totalRevenuePotential),
          Icons.attach_money,
          Colors.blue,
        ),
        _buildMetricItem(
          'Generated Revenue',
          documentState.formatCurrency(totalRevenueGenerated),
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildMetricItem(
          'Remaining',
          documentState.formatCurrency(remainingRevenue),
          Icons.timeline,
          remainingRevenue >= 0 ? Colors.purple : Colors.red,
        ),
      ],
    );
  }
  
  Widget _buildEfficiencyRow() {
    final overallEfficiency = statistics['overallEfficiency'] as double;
    final completionPercentage = statistics['completionPercentage'] as double;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Completion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${completionPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completionPercentage / 100,
          backgroundColor: Colors.grey.shade200,
          color: _getCompletionColor(completionPercentage),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Team Efficiency',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            Row(
              children: [
                Icon(
                  overallEfficiency >= 1.0 ? Icons.thumb_up : Icons.thumb_down,
                  color: overallEfficiency >= 1.0 ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(overallEfficiency * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: overallEfficiency >= 1.0 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: overallEfficiency > 2.0 ? 1.0 : overallEfficiency / 2,
          backgroundColor: Colors.grey.shade200,
          color: _getEfficiencyColor(overallEfficiency),
        ),
      ],
    );
  }
  
  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  Color _getCompletionColor(double percentage) {
    if (percentage <= 25) return Colors.red;
    if (percentage <= 50) return Colors.orange;
    if (percentage <= 75) return Colors.amber;
    return Colors.green;
  }
  
  Color _getEfficiencyColor(double efficiency) {
    if (efficiency < 0.5) return Colors.red;
    if (efficiency < 0.8) return Colors.orange;
    if (efficiency < 1.0) return Colors.amber;
    if (efficiency < 1.2) return Colors.green;
    return Colors.blue;
  }
} 