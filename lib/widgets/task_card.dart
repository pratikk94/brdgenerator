import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../state/task_state.dart';
import '../state/document_state.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({Key? key, required this.task, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final documentState = Provider.of<DocumentState>(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.status.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.status.name,
                      style: TextStyle(
                        color: task.status.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${task.estimatedHours.toStringAsFixed(1)} hrs',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        documentState.formatCurrency(task.revenuePotential),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.status != TaskStatus.todo) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getProgressValue(),
                  backgroundColor: Colors.grey.shade200,
                  color: _getProgressColor(),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time spent: ${_formatDuration(task.timeSpent)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (task.status == TaskStatus.done)
                      Text(
                        task.efficiencyRate >= 1.0 
                            ? 'Efficient 🚀' 
                            : 'Over time ⏰',
                        style: TextStyle(
                          fontSize: 12,
                          color: task.efficiencyRate >= 1.0 
                              ? Colors.green 
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Calculate progress value for progress bar
  double _getProgressValue() {
    if (task.status == TaskStatus.todo) return 0.0;
    
    if (task.status == TaskStatus.doing) {
      double progress = task.actualHours / task.estimatedHours;
      // Cap at 100%
      return progress > 1.0 ? 1.0 : progress;
    }
    
    if (task.status == TaskStatus.done) {
      return 1.0;
    }
    
    return 0.0;
  }

  // Get color for progress bar
  Color _getProgressColor() {
    if (task.status == TaskStatus.done) {
      return task.efficiencyRate >= 1.0 ? Colors.green : Colors.orange;
    }
    
    if (task.status == TaskStatus.doing) {
      double progress = task.actualHours / task.estimatedHours;
      if (progress <= 0.5) return Colors.green;
      if (progress <= 0.8) return Colors.amber;
      return Colors.orange;
    }
    
    return Colors.blue;
  }

  // Format duration to readable string
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Just started';
    }
  }
}

class TaskStatusButton extends StatelessWidget {
  final Task task;
  final TaskStatus targetStatus;
  final IconData icon;
  final String tooltip;

  const TaskStatusButton({
    Key? key,
    required this.task,
    required this.targetStatus,
    required this.icon,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentStatus = task.status == targetStatus;
    
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        color: isCurrentStatus ? targetStatus.color : Colors.grey,
        onPressed: isCurrentStatus
            ? null
            : () {
                Provider.of<TaskState>(context, listen: false)
                    .changeTaskStatus(task.id, targetStatus);
              },
      ),
    );
  }
} 