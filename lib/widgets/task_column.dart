import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_card.dart';

class TaskColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(TaskStatus) onAddTask;
  final Color? customColor;

  const TaskColumn({
    Key? key,
    required this.status,
    required this.tasks,
    required this.onTaskTap,
    required this.onAddTask,
    this.customColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: tasks.isEmpty 
                ? _buildEmptyState() 
                : _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final Color headerColor = customColor ?? status.color;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: headerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getIconForStatus(),
                color: headerColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                status.name,
                style: TextStyle(
                  color: headerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tasks.length.toString(),
                  style: TextStyle(
                    color: headerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: headerColor,
            onPressed: () => onAddTask(status),
            tooltip: 'Add task',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => onTaskTap(task),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForStatus(),
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessageForStatus(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => onAddTask(status),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: status.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus() {
    switch (status) {
      case TaskStatus.todo:
        return Icons.checklist;
      case TaskStatus.doing:
        return Icons.play_circle_outline;
      case TaskStatus.done:
        return Icons.check_circle_outline;
    }
  }

  String _getEmptyMessageForStatus() {
    switch (status) {
      case TaskStatus.todo:
        return 'No tasks to do yet.\nAdd a new task to get started.';
      case TaskStatus.doing:
        return 'No tasks in progress.\nStart working on a task from To Do.';
      case TaskStatus.done:
        return 'No completed tasks yet.\nComplete a task to see it here.';
    }
  }
} 