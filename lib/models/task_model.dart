import 'package:flutter/material.dart';

enum TaskStatus {
  todo,
  doing,
  done,
}

extension TaskStatusExtension on TaskStatus {
  String get name {
    switch (this) {
      case TaskStatus.todo: return 'To Do';
      case TaskStatus.doing: return 'Doing';
      case TaskStatus.done: return 'Done';
    }
  }
  
  Color get color {
    switch (this) {
      case TaskStatus.todo: return Colors.grey;
      case TaskStatus.doing: return Colors.blue;
      case TaskStatus.done: return Colors.green;
    }
  }
}

class Task {
  String id;
  String title;
  String description;
  TaskStatus status;
  DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;
  double estimatedHours;
  double hourlyRate;
  String? assignee; // User ID of assignee
  List<String> labels;
  bool aiEstimated;
  DateTime? deadline;
  double baselineCost;
  
  // User activity tracking fields
  String createdBy; // User ID who created this task
  String? lastModifiedBy; // User ID who last modified this task
  DateTime? lastModifiedAt; // When task was last modified
  List<TaskActivity> activityLog; // Activity log for this task
  
  // Calculate time spent on task
  Duration get timeSpent {
    if (status == TaskStatus.todo) {
      return Duration.zero;
    }
    
    if (status == TaskStatus.doing && startedAt != null) {
      return DateTime.now().difference(startedAt!);
    }
    
    if (status == TaskStatus.done && startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    
    return Duration.zero;
  }
  
  // Calculate actual hours spent
  double get actualHours {
    return timeSpent.inMinutes / 60;
  }
  
  // Calculate efficiency rate (estimated vs actual)
  double get efficiencyRate {
    if (status != TaskStatus.done || actualHours == 0) {
      return 1.0; // Default to 1 if task is not done
    }
    return estimatedHours / actualHours;
  }
  
  // Calculate revenue generated
  double get revenue {
    switch (status) {
      case TaskStatus.todo:
        return 0.0;
      case TaskStatus.doing:
        return actualHours * hourlyRate;
      case TaskStatus.done:
        return estimatedHours * hourlyRate;
    }
  }
  
  // Calculate revenue potential
  double get revenuePotential {
    return estimatedHours * hourlyRate;
  }
  
  // Calculate baseline cost (for comparison with actual)
  double get getBaselineCost {
    return baselineCost > 0 ? baselineCost : estimatedHours * hourlyRate * 0.6; // 60% of revenue as cost by default
  }
  
  // Calculate profit margin
  double get profitMargin {
    if (revenue <= 0) return 0;
    return (revenue - getBaselineCost) / revenue * 100;
  }
  
  // Check if task is overdue
  bool get isOverdue {
    if (deadline == null || status == TaskStatus.done) return false;
    return DateTime.now().isAfter(deadline!);
  }
  
  // Calculate days until deadline or days overdue
  int get daysToDeadline {
    if (deadline == null) return 0;
    return deadline!.difference(DateTime.now()).inDays;
  }
  
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.estimatedHours = 1.0,
    this.hourlyRate = 50.0,
    this.assignee,
    this.labels = const [],
    this.aiEstimated = false,
    this.deadline,
    this.baselineCost = 0.0,
    required this.createdBy,
    this.lastModifiedBy,
    this.lastModifiedAt,
    this.activityLog = const [],
  });
  
  // Create a task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    // Convert activity log from JSON
    List<TaskActivity> activityLogList = [];
    if (json['activityLog'] != null) {
      final activityLogData = json['activityLog'] as List<dynamic>;
      activityLogList = activityLogData
          .map((activity) => TaskActivity.fromJson(activity as Map<String, dynamic>))
          .toList();
    }

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.todo,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      assignee: json['assignee'] as String?,
      labels: List<String>.from(json['labels'] as List<dynamic>? ?? []),
      aiEstimated: json['aiEstimated'] as bool? ?? false,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      baselineCost: (json['baselineCost'] as num?)?.toDouble() ?? 0.0,
      createdBy: json['createdBy'] as String? ?? 'unknown',
      lastModifiedBy: json['lastModifiedBy'] as String?,
      lastModifiedAt: json['lastModifiedAt'] != null ? DateTime.parse(json['lastModifiedAt'] as String) : null,
      activityLog: activityLogList,
    );
  }
  
  // Convert task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedHours': estimatedHours,
      'hourlyRate': hourlyRate,
      'assignee': assignee,
      'labels': labels,
      'aiEstimated': aiEstimated,
      'deadline': deadline?.toIso8601String(),
      'baselineCost': baselineCost,
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'activityLog': activityLog.map((activity) => activity.toJson()).toList(),
    };
  }
  
  // Create a copy of the task with new values
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? estimatedHours,
    double? hourlyRate,
    String? assignee,
    List<String>? labels,
    bool? aiEstimated,
    DateTime? deadline,
    double? baselineCost,
    String? createdBy,
    String? lastModifiedBy,
    DateTime? lastModifiedAt,
    List<TaskActivity>? activityLog,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      assignee: assignee ?? this.assignee,
      labels: labels ?? this.labels,
      aiEstimated: aiEstimated ?? this.aiEstimated,
      deadline: deadline ?? this.deadline,
      baselineCost: baselineCost ?? this.baselineCost,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      activityLog: activityLog ?? this.activityLog,
    );
  }
  
  // Update task status and related timestamps
  Task updateStatus(TaskStatus newStatus, String userId) {
    if (newStatus == status) {
      return this;
    }
    
    DateTime? newStartedAt = startedAt;
    DateTime? newCompletedAt = completedAt;
    final now = DateTime.now();
    
    if (newStatus == TaskStatus.doing && status == TaskStatus.todo) {
      newStartedAt = now;
    } else if (newStatus == TaskStatus.done && (status == TaskStatus.todo || status == TaskStatus.doing)) {
      if (newStartedAt == null) {
        newStartedAt = now;
      }
      newCompletedAt = now;
    } else if (newStatus == TaskStatus.todo) {
      newStartedAt = null;
      newCompletedAt = null;
    } else if (newStatus == TaskStatus.doing && status == TaskStatus.done) {
      newCompletedAt = null;
    }
    
    // Create activity log entry
    final activity = TaskActivity(
      timestamp: now,
      userId: userId,
      action: TaskActivityAction.statusChange,
      details: 'Status changed from ${status.name} to ${newStatus.name}',
    );
    
    // Create updated activity log
    final newActivityLog = List<TaskActivity>.from(activityLog);
    newActivityLog.add(activity);
    
    return copyWith(
      status: newStatus,
      startedAt: newStartedAt,
      completedAt: newCompletedAt,
      lastModifiedBy: userId,
      lastModifiedAt: now,
      activityLog: newActivityLog,
    );
  }
  
  // Add an activity log entry
  Task addActivity(TaskActivityAction action, String userId, {String? details}) {
    final now = DateTime.now();
    final activity = TaskActivity(
      timestamp: now,
      userId: userId,
      action: action,
      details: details ?? action.description,
    );
    
    final newActivityLog = List<TaskActivity>.from(activityLog);
    newActivityLog.add(activity);
    
    return copyWith(
      lastModifiedBy: userId,
      lastModifiedAt: now,
      activityLog: newActivityLog,
    );
  }
}

// Task activity for tracking who did what
class TaskActivity {
  final DateTime timestamp;
  final String userId;
  final TaskActivityAction action;
  final String details;
  
  TaskActivity({
    required this.timestamp,
    required this.userId,
    required this.action,
    required this.details,
  });
  
  // Create from JSON
  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    return TaskActivity(
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      action: TaskActivityAction.values.firstWhere(
        (e) => e.toString() == 'TaskActivityAction.${json['action']}',
        orElse: () => TaskActivityAction.other,
      ),
      details: json['details'] as String,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'action': action.toString().split('.').last,
      'details': details,
    };
  }
}

// Types of task activity
enum TaskActivityAction {
  create,
  update,
  statusChange,
  assigneeChange,
  delete,
  comment,
  other,
}

// Extension to get description for activity actions
extension TaskActivityActionExtension on TaskActivityAction {
  String get description {
    switch (this) {
      case TaskActivityAction.create: return 'Created task';
      case TaskActivityAction.update: return 'Updated task details';
      case TaskActivityAction.statusChange: return 'Changed task status';
      case TaskActivityAction.assigneeChange: return 'Changed task assignee';
      case TaskActivityAction.delete: return 'Deleted task';
      case TaskActivityAction.comment: return 'Added comment';
      case TaskActivityAction.other: return 'Other activity';
    }
  }
} 