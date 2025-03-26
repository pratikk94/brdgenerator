import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/task_model.dart';
import '../models/board_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

class TaskService {
  static const String _boardsKey = 'boards';
  final Uuid _uuid = const Uuid();
  final String? _apiKey = dotenv.env['OPENAI_API_KEY'];
  
  // Firebase service
  final FirebaseService _firebaseService = FirebaseService();
  
  // Auth service for current user
  final AuthService _authService = AuthService();
  
  // Firebase Database reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('tasks');
  
  // Get all users for task assignments
  Future<List<UserModel>> getAllUsers() async {
    return await _firebaseService.getAllUsers();
  }
  
  // Get all boards
  Future<List<Board>> getAllBoards() async {
    try {
      // Get from Firebase using FirebaseService
      final boardsData = await _firebaseService.getAllBoards();
      if (boardsData.isNotEmpty) {
        return boardsData.map((boardData) => Board.fromJson(boardData)).toList();
      }
    } catch (e) {
      print('Failed to load from Firebase: $e');
      // Fallback to local storage
    }
    
    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    final boardsJson = prefs.getStringList(_boardsKey) ?? [];
    
    return boardsJson.map((boardString) {
      final boardMap = jsonDecode(boardString) as Map<String, dynamic>;
      return Board.fromJson(boardMap);
    }).toList();
  }
  
  // Get boards filtered by user (either created by or assigned to)
  Future<List<Board>> getBoardsByUser(String userId) async {
    final allBoards = await getAllBoards();
    
    // Filter boards that either:
    // 1. Were created by this user
    // 2. Contain tasks assigned to this user
    return allBoards.where((board) {
      // Check if any task is assigned to or created by this user
      final hasUserTasks = board.tasks.any((task) => 
        task.assignee == userId || task.createdBy == userId);
      
      return hasUserTasks || board.createdBy == userId;
    }).toList();
  }
  
  // Save all boards
  Future<void> saveAllBoards(List<Board> boards) async {
    // Save to Firebase using FirebaseService
    try {
      for (final board in boards) {
        await _firebaseService.saveBoard(board.toJson());
      }
    } catch (e) {
      print('Failed to save to Firebase: $e');
    }
    
    // Backup to local storage
    final prefs = await SharedPreferences.getInstance();
    final boardsJson = boards.map((board) => jsonEncode(board.toJson())).toList();
    await prefs.setStringList(_boardsKey, boardsJson);
  }
  
  // Get a single board by ID
  Future<Board?> getBoardById(String boardId) async {
    try {
      // First try to get from Firebase
      final snapshot = await _dbRef.child('boards/$boardId').get();
      if (snapshot.exists) {
        return Board.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print('Failed to load board from Firebase: $e');
      // Fallback to local storage
    }
    
    final boards = await getAllBoards();
    try {
      return boards.firstWhere((board) => board.id == boardId);
    } catch (e) {
      return null;
    }
  }
  
  // Create a new board
  Future<Board> createBoard(String name, {Color color = Colors.blue}) async {
    final boards = await getAllBoards();
    
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    final newBoard = Board.create(
      name, 
      color: color, 
      createdBy: userId,
    );
    
    boards.add(newBoard);
    await saveAllBoards(boards);
    
    // Log user activity
    await _firebaseService.logUserActivity(
      userId, 
      'create_board', 
      {'boardId': newBoard.id, 'boardName': name}
    );
    
    return newBoard;
  }
  
  // Update an existing board
  Future<Board> updateBoard(Board updatedBoard) async {
    final boards = await getAllBoards();
    final index = boards.indexWhere((board) => board.id == updatedBoard.id);
    
    if (index != -1) {
      // Get current user ID for tracking
      final String userId = _authService.currentUser?.uid ?? 'unknown';
      
      // Update last updated info
      final boardWithUpdate = updatedBoard.copyWith(
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: userId,
      );
      
      boards[index] = boardWithUpdate;
      await saveAllBoards(boards);
      
      // Log user activity
      await _firebaseService.logUserActivity(
        userId, 
        'update_board', 
        {'boardId': updatedBoard.id, 'boardName': updatedBoard.name}
      );
      
      return boards[index];
    } else {
      throw Exception('Board not found');
    }
  }
  
  // Delete a board
  Future<void> deleteBoard(String boardId) async {
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    // Get board name before deletion for activity log
    final board = await getBoardById(boardId);
    final boardName = board?.name ?? 'Unknown Board';
    
    // Delete from Firebase
    try {
      await _dbRef.child('boards/$boardId').remove();
    } catch (e) {
      print('Failed to delete from Firebase: $e');
    }
    
    // Also delete from local storage
    final boards = await getAllBoards();
    final updatedBoards = boards.where((board) => board.id != boardId).toList();
    await saveAllBoards(updatedBoards);
    
    // Log user activity
    await _firebaseService.logUserActivity(
      userId, 
      'delete_board', 
      {'boardId': boardId, 'boardName': boardName}
    );
  }
  
  // Add a task to a board with AI estimation
  Future<Task> addTask(
    String boardId, 
    String title, 
    String description, 
    double estimatedHours, 
    double hourlyRate, 
    {String? assigneeId, DateTime? deadline}
  ) async {
    final board = await getBoardById(boardId);
    if (board == null) {
      throw Exception('Board not found');
    }
    
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    // If estimated hours is 0, use AI to estimate
    bool isAiEstimated = false;
    if (estimatedHours <= 0) {
      final aiEstimate = await getAIEstimate(title, description);
      estimatedHours = aiEstimate['estimatedHours'] ?? 2.0;
      hourlyRate = aiEstimate['suggestedRate'] ?? 50.0;
      isAiEstimated = true;
    }
    
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      status: TaskStatus.todo,
      createdAt: now,
      estimatedHours: estimatedHours,
      hourlyRate: hourlyRate,
      aiEstimated: isAiEstimated,
      assignee: assigneeId,
      deadline: deadline,
      createdBy: userId,
      lastModifiedBy: userId,
      lastModifiedAt: now,
      activityLog: [
        TaskActivity(
          timestamp: now,
          userId: userId,
          action: TaskActivityAction.create,
          details: 'Task created',
        )
      ],
    );
    
    final updatedBoard = board.addTask(task);
    await updateBoard(updatedBoard);
    
    // Log activity
    await _firebaseService.trackTaskActivity(
      boardId,
      task.id,
      userId,
      'create',
      {
        'title': title,
        'estimatedHours': estimatedHours,
        'assignee': assigneeId,
      },
    );
    
    return task;
  }
  
  // Update a task
  Future<void> updateTask(String boardId, Task updatedTask) async {
    final board = await getBoardById(boardId);
    if (board == null) {
      throw Exception('Board not found');
    }
    
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    // Add activity log entry
    final taskWithActivity = updatedTask.addActivity(
      TaskActivityAction.update,
      userId,
      details: 'Task details updated',
    );
    
    // Update the board with new task
    final updatedBoard = board.updateTask(taskWithActivity);
    await updateBoard(updatedBoard);
    
    // Log activity
    await _firebaseService.trackTaskActivity(
      boardId,
      updatedTask.id,
      userId,
      'update',
      {
        'title': updatedTask.title,
        'estimatedHours': updatedTask.estimatedHours,
        'assignee': updatedTask.assignee,
      },
    );
  }
  
  // Change task status
  Future<void> changeTaskStatus(String boardId, String taskId, TaskStatus newStatus) async {
    final board = await getBoardById(boardId);
    if (board == null) {
      throw Exception('Board not found');
    }
    
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    // Find the task
    final index = board.tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw Exception('Task not found');
    }
    
    // Get current task
    final task = board.tasks[index];
    
    // Update status and add activity log
    final updatedTask = task.updateStatus(newStatus, userId);
    
    // Update the board with new task
    final updatedBoard = board.updateTask(updatedTask);
    await updateBoard(updatedBoard);
    
    // Log activity
    await _firebaseService.trackTaskActivity(
      boardId,
      taskId,
      userId,
      'status_change',
      {
        'oldStatus': task.status.toString().split('.').last,
        'newStatus': newStatus.toString().split('.').last,
      },
    );
  }
  
  // Delete a task
  Future<void> deleteTask(String boardId, String taskId) async {
    final board = await getBoardById(boardId);
    if (board == null) {
      throw Exception('Board not found');
    }
    
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    // Find the task for activity log
    final task = board.tasks.firstWhere((task) => task.id == taskId);
    
    // Delete the task
    final updatedBoard = board.removeTask(taskId);
    await updateBoard(updatedBoard);
    
    // Log activity
    await _firebaseService.trackTaskActivity(
      boardId,
      taskId,
      userId,
      'delete',
      {
        'title': task.title,
      },
    );
  }
  
  // Assign a task to a user
  Future<void> assignTask(String boardId, String taskId, String assigneeId) async {
    final board = await getBoardById(boardId);
    if (board == null) {
      throw Exception('Board not found');
    }
    
    // Get current user ID for tracking
    final String userId = _authService.currentUser?.uid ?? 'unknown';
    
    // Find the task
    final task = board.tasks.firstWhere((task) => task.id == taskId);
    
    // Get assignee name for activity log
    final assignee = await _firebaseService.getUserById(assigneeId);
    final assigneeName = assignee?.displayName ?? 'Unknown User';
    
    // Update task with new assignee and add activity
    final updatedTask = task.copyWith(assignee: assigneeId).addActivity(
      TaskActivityAction.assigneeChange,
      userId,
      details: 'Assigned to $assigneeName',
    );
    
    // Update the board with new task
    final updatedBoard = board.updateTask(updatedTask);
    await updateBoard(updatedBoard);
    
    // Log activity
    await _firebaseService.trackTaskActivity(
      boardId,
      taskId,
      userId,
      'assign',
      {
        'assigneeId': assigneeId,
        'assigneeName': assigneeName,
      },
    );
  }
  
  // Get all tasks for a specific user
  Future<List<Map<String, dynamic>>> getTasksByUser(String userId) async {
    final allBoards = await getAllBoards();
    final userTasks = <Map<String, dynamic>>[];
    
    for (final board in allBoards) {
      for (final task in board.tasks) {
        if (task.assignee == userId || task.createdBy == userId) {
          userTasks.add({
            'boardId': board.id,
            'boardName': board.name,
            'task': task,
          });
        }
      }
    }
    
    return userTasks;
  }
  
  // Initialize a default board if no boards exist
  Future<void> initializeDefaultBoardIfNeeded() async {
    final boards = await getAllBoards();
    if (boards.isEmpty) {
      await createBoard('My Tasks');
    }
  }
  
  // Get AI estimate for task
  Future<Map<String, double>> getAIEstimate(String title, String description) async {
    if (_apiKey == null) {
      return {'estimatedHours': 2.0, 'suggestedRate': 50.0};
    }
    
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert project manager with extensive experience estimating tasks. '
                  'Provide time estimates and appropriate hourly rates for tasks based on their description. '
                  'Return only a JSON object with estimatedHours (in hours, decimal) and suggestedRate (in USD per hour).',
            },
            {
              'role': 'user',
              'content': 'Estimate the time and appropriate hourly rate for this task: '
                  'Title: $title\nDescription: $description',
            },
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from response
        final jsonRegExp = RegExp(r'({.*})');
        final match = jsonRegExp.firstMatch(content);
        if (match != null) {
          final jsonStr = match.group(1);
          if (jsonStr != null) {
            final parsedData = jsonDecode(jsonStr);
            final estimatedHours = parsedData['estimatedHours'] is int 
              ? (parsedData['estimatedHours'] as int).toDouble()
              : (parsedData['estimatedHours'] as double?) ?? 2.0;
            
            final suggestedRate = parsedData['suggestedRate'] is int
              ? (parsedData['suggestedRate'] as int).toDouble()
              : (parsedData['suggestedRate'] as double?) ?? 50.0;
              
            return {
              'estimatedHours': estimatedHours,
              'suggestedRate': suggestedRate,
            };
          }
        }
      }
      
      // Fallback
      return {'estimatedHours': 2.0, 'suggestedRate': 50.0};
    } catch (e) {
      print('Error getting AI estimate: $e');
      return {'estimatedHours': 2.0, 'suggestedRate': 50.0};
    }
  }
  
  // Get board statistics
  Future<Map<String, dynamic>> getBoardStatistics(String boardId) async {
    final board = await getBoardById(boardId);
    if (board == null) {
      throw Exception('Board not found');
    }
    
    // Calculate basic metrics
    final totalTasks = board.tasks.length;
    final todoTasks = board.tasks.where((t) => t.status == TaskStatus.todo).length;
    final doingTasks = board.tasks.where((t) => t.status == TaskStatus.doing).length;
    final doneTasks = board.tasks.where((t) => t.status == TaskStatus.done).length;
    
    // Group tasks by user
    final Map<String, int> tasksByUser = {};
    
    for (final task in board.tasks) {
      if (task.assignee != null) {
        if (!tasksByUser.containsKey(task.assignee)) {
          tasksByUser[task.assignee!] = 0;
        }
        tasksByUser[task.assignee!] = tasksByUser[task.assignee]! + 1;
      }
    }
    
    // Get user details for display names
    final Map<String, dynamic> userDetails = {};
    for (final userId in tasksByUser.keys) {
      final user = await _firebaseService.getUserById(userId);
      if (user != null) {
        userDetails[userId] = {
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
        };
      }
    }
    
    return {
      'totalTasks': totalTasks,
      'todoTasks': todoTasks,
      'doingTasks': doingTasks,
      'doneTasks': doneTasks,
      'completionPercentage': totalTasks > 0 ? (doneTasks / totalTasks * 100).round() : 0,
      'tasksByUser': tasksByUser,
      'userDetails': userDetails,
      'totalHours': board.totalEstimatedHours,
      'totalRevenue': board.totalRevenuePotential,
      'lastUpdated': board.lastUpdatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
} 