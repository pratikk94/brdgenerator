import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'task_model.dart';

class Board {
  String id;
  String name;
  Color color;
  List<Task> tasks;
  DateTime createdAt;
  DateTime? lastUpdatedAt;
  
  // User tracking fields
  String createdBy; // User ID who created this board
  String? lastUpdatedBy; // User ID who last updated this board
  List<BoardActivity> activityLog; // Activity log for board-level events
  
  // Constructor
  Board({
    required this.id,
    required this.name,
    this.color = Colors.blue,
    this.tasks = const [],
    required this.createdAt,
    this.lastUpdatedAt,
    required this.createdBy,
    this.lastUpdatedBy,
    this.activityLog = const [],
  });
  
  // Factory method to create a board with a random ID
  factory Board.create(String name, {Color color = Colors.blue, required String createdBy}) {
    final now = DateTime.now();
    return Board(
      id: const Uuid().v4(),
      name: name,
      color: color,
      tasks: [],
      createdAt: now,
      lastUpdatedAt: now,
      createdBy: createdBy,
      lastUpdatedBy: createdBy,
      activityLog: [
        BoardActivity(
          timestamp: now,
          userId: createdBy,
          action: BoardActivityAction.create,
          details: 'Board created',
        ),
      ],
    );
  }
  
  // Create a copy of the board with new values
  Board copyWith({
    String? id,
    String? name,
    Color? color,
    List<Task>? tasks,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? createdBy,
    String? lastUpdatedBy,
    List<BoardActivity>? activityLog,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      activityLog: activityLog ?? this.activityLog,
    );
  }
  
  // Add activity to the board log
  Board addActivity(BoardActivityAction action, String userId, {String? details}) {
    final now = DateTime.now();
    final activity = BoardActivity(
      timestamp: now,
      userId: userId,
      action: action,
      details: details ?? action.description,
    );
    
    final newActivityLog = List<BoardActivity>.from(activityLog)..add(activity);
    
    return copyWith(
      lastUpdatedAt: now,
      lastUpdatedBy: userId,
      activityLog: newActivityLog,
    );
  }
  
  // Add a task to the board
  Board addTask(Task task) {
    final updatedTasks = List<Task>.from(tasks)..add(task);
    
    // Add activity entry for task creation
    final now = DateTime.now();
    final activity = BoardActivity(
      timestamp: now,
      userId: task.createdBy,
      action: BoardActivityAction.addTask,
      details: 'Task "${task.title}" added to board',
      relatedTaskId: task.id,
    );
    
    final newActivityLog = List<BoardActivity>.from(activityLog)..add(activity);
    
    return copyWith(
      tasks: updatedTasks,
      lastUpdatedAt: now,
      lastUpdatedBy: task.createdBy,
      activityLog: newActivityLog,
    );
  }
  
  // Update a task on the board
  Board updateTask(Task updatedTask) {
    final updatedTasks = tasks.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      }
      return task;
    }).toList();
    
    // Add activity entry for task update if there's a last modifier
    final userId = updatedTask.lastModifiedBy ?? updatedTask.createdBy;
    final now = DateTime.now();
    final activity = BoardActivity(
      timestamp: now,
      userId: userId,
      action: BoardActivityAction.updateTask,
      details: 'Task "${updatedTask.title}" updated',
      relatedTaskId: updatedTask.id,
    );
    
    final newActivityLog = List<BoardActivity>.from(activityLog)..add(activity);
    
    return copyWith(
      tasks: updatedTasks,
      lastUpdatedAt: now,
      lastUpdatedBy: userId,
      activityLog: newActivityLog,
    );
  }
  
  // Remove a task from the board
  Board removeTask(String taskId) {
    // Find the task before removal for activity log
    final task = tasks.firstWhere((t) => t.id == taskId);
    final userId = task.lastModifiedBy ?? task.createdBy;
    
    final updatedTasks = tasks.where((task) => task.id != taskId).toList();
    
    // Add activity entry for task removal
    final now = DateTime.now();
    final activity = BoardActivity(
      timestamp: now,
      userId: userId,
      action: BoardActivityAction.removeTask,
      details: 'Task "${task.title}" removed from board',
      relatedTaskId: taskId,
    );
    
    final newActivityLog = List<BoardActivity>.from(activityLog)..add(activity);
    
    return copyWith(
      tasks: updatedTasks,
      lastUpdatedAt: now,
      lastUpdatedBy: userId,
      activityLog: newActivityLog,
    );
  }
  
  // Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return tasks.where((task) => task.status == status).toList();
  }
  
  // Get tasks by user (either created by or assigned to)
  List<Task> getTasksByUser(String userId) {
    return tasks.where((task) => 
      task.assignee == userId || task.createdBy == userId
    ).toList();
  }
  
  // Get the counts of tasks by status
  Map<TaskStatus, int> getTaskCounts() {
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = getTasksByStatus(status).length;
    }
    return counts;
  }
  
  // Get the total estimated time for all tasks
  double get totalEstimatedHours {
    return tasks.fold(0.0, (double sum, task) => sum + task.estimatedHours);
  }
  
  // Get the total actual time spent on tasks
  double get totalActualHours {
    return tasks.fold(0.0, (double sum, task) => sum + task.actualHours);
  }
  
  // Get the total revenue potential
  double get totalRevenuePotential {
    return tasks.fold(0.0, (double sum, task) => sum + task.revenuePotential);
  }
  
  // Get the total revenue generated
  double get totalRevenueGenerated {
    return tasks.fold(0.0, (double sum, task) => sum + task.revenue);
  }
  
  // Calculate overall efficiency
  double get overallEfficiency {
    if (tasks.isEmpty || totalActualHours == 0) {
      return 1.0;
    }
    
    final doneTasks = tasks.where((task) => task.status == TaskStatus.done).toList();
    if (doneTasks.isEmpty) {
      return 1.0;
    }
    
    final totalEstimated = doneTasks.fold(0.0, (double sum, task) => sum + task.estimatedHours);
    final totalActual = doneTasks.fold(0.0, (double sum, task) => sum + task.actualHours);
    
    if (totalActual == 0) {
      return 1.0;
    }
    
    return totalEstimated / totalActual;
  }
  
  // Calculate completion percentage
  double get completionPercentage {
    if (tasks.isEmpty) {
      return 0.0;
    }
    
    final doneTasks = tasks.where((task) => task.status == TaskStatus.done).length;
    return (doneTasks / tasks.length) * 100;
  }
  
  // Create a board from JSON
  factory Board.fromJson(Map<String, dynamic> json) {
    // Parse tasks
    final List<Task> tasksList = [];
    if (json['tasks'] != null) {
      final tasksData = json['tasks'] as List<dynamic>;
      tasksList.addAll(tasksData
          .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
          .toList());
    }
    
    // Parse activity log
    List<BoardActivity> activityList = [];
    if (json['activityLog'] != null) {
      final activityData = json['activityLog'] as List<dynamic>;
      activityList = activityData
          .map((activity) => BoardActivity.fromJson(activity as Map<String, dynamic>))
          .toList();
    }
    
    // Parse color
    final colorValue = json['color'] as int? ?? Colors.blue.value;
    
    return Board(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(colorValue),
      tasks: tasksList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] != null 
          ? DateTime.parse(json['lastUpdatedAt'] as String) 
          : null,
      createdBy: json['createdBy'] as String? ?? 'unknown',
      lastUpdatedBy: json['lastUpdatedBy'] as String?,
      activityLog: activityList,
    );
  }
  
  // Convert board to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'lastUpdatedBy': lastUpdatedBy,
      'activityLog': activityLog.map((activity) => activity.toJson()).toList(),
    };
  }
}

// Activity log for boards
class BoardActivity {
  final DateTime timestamp;
  final String userId;
  final BoardActivityAction action;
  final String details;
  final String? relatedTaskId;
  
  BoardActivity({
    required this.timestamp,
    required this.userId,
    required this.action,
    required this.details,
    this.relatedTaskId,
  });
  
  // Create from JSON
  factory BoardActivity.fromJson(Map<String, dynamic> json) {
    return BoardActivity(
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      action: BoardActivityAction.values.firstWhere(
        (e) => e.toString() == 'BoardActivityAction.${json['action']}',
        orElse: () => BoardActivityAction.other,
      ),
      details: json['details'] as String,
      relatedTaskId: json['relatedTaskId'] as String?,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'action': action.toString().split('.').last,
      'details': details,
      'relatedTaskId': relatedTaskId,
    };
  }
}

// Types of board activity
enum BoardActivityAction {
  create,
  rename,
  changeColor,
  addTask,
  updateTask,
  removeTask,
  other,
}

// Extension to get description for board activity actions
extension BoardActivityActionExtension on BoardActivityAction {
  String get description {
    switch (this) {
      case BoardActivityAction.create: return 'Board created';
      case BoardActivityAction.rename: return 'Board renamed';
      case BoardActivityAction.changeColor: return 'Board color changed';
      case BoardActivityAction.addTask: return 'Task added';
      case BoardActivityAction.updateTask: return 'Task updated';
      case BoardActivityAction.removeTask: return 'Task removed';
      case BoardActivityAction.other: return 'Other board activity';
    }
  }
} 