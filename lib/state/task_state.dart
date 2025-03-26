import 'package:flutter/material.dart';
import '../models/board_model.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskState extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  List<Board> _boards = [];
  Board? _currentBoard;
  Map<String, dynamic>? _currentBoardStatistics;
  bool _isLoading = true;
  String? _error;
  
  // Getters
  List<Board> get boards => _boards;
  Board? get currentBoard => _currentBoard;
  Map<String, dynamic>? get currentBoardStatistics => _currentBoardStatistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor initializes data
  TaskState() {
    _initializeData();
  }
  
  // Initialize task data
  Future<void> _initializeData() async {
    _setLoading(true);
    try {
      await _taskService.initializeDefaultBoardIfNeeded();
      await _loadBoards();
      if (_boards.isNotEmpty) {
        await setCurrentBoard(_boards.first.id);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to initialize data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load all boards
  Future<void> _loadBoards() async {
    try {
      _boards = await _taskService.getAllBoards();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load boards: $e');
    }
  }
  
  // Set the current board by ID
  Future<void> setCurrentBoard(String boardId) async {
    _setLoading(true);
    try {
      final board = await _taskService.getBoardById(boardId);
      if (board != null) {
        _currentBoard = board;
        await _loadBoardStatistics(boardId);
      } else {
        _setError('Board not found');
      }
    } catch (e) {
      _setError('Failed to set current board: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load statistics for current board
  Future<void> _loadBoardStatistics(String boardId) async {
    try {
      _currentBoardStatistics = await _taskService.getBoardStatistics(boardId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load board statistics: $e');
    }
  }
  
  // Create a new board
  Future<void> createBoard(String name, {Color color = Colors.blue}) async {
    _setLoading(true);
    try {
      final newBoard = await _taskService.createBoard(name, color: color);
      await _loadBoards();
      await setCurrentBoard(newBoard.id);
      _clearError();
    } catch (e) {
      _setError('Failed to create board: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update a board
  Future<void> updateBoard(Board updatedBoard) async {
    _setLoading(true);
    try {
      await _taskService.updateBoard(updatedBoard);
      await _loadBoards();
      if (_currentBoard?.id == updatedBoard.id) {
        await setCurrentBoard(updatedBoard.id);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to update board: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a board
  Future<void> deleteBoard(String boardId) async {
    _setLoading(true);
    try {
      await _taskService.deleteBoard(boardId);
      await _loadBoards();
      if (_currentBoard?.id == boardId) {
        if (_boards.isNotEmpty) {
          await setCurrentBoard(_boards.first.id);
        } else {
          _currentBoard = null;
          _currentBoardStatistics = null;
        }
      }
      _clearError();
    } catch (e) {
      _setError('Failed to delete board: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a task to the current board
  Future<void> addTask(String title, String description, double estimatedHours, double hourlyRate) async {
    if (_currentBoard == null) {
      _setError('No current board selected');
      return;
    }
    
    _setLoading(true);
    try {
      await _taskService.addTask(
        _currentBoard!.id,
        title,
        description,
        estimatedHours,
        hourlyRate,
      );
      await setCurrentBoard(_currentBoard!.id);
      _clearError();
    } catch (e) {
      _setError('Failed to add task: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update a task
  Future<void> updateTask(Task updatedTask) async {
    if (_currentBoard == null) {
      _setError('No current board selected');
      return;
    }
    
    _setLoading(true);
    try {
      await _taskService.updateTask(_currentBoard!.id, updatedTask);
      await setCurrentBoard(_currentBoard!.id);
      _clearError();
    } catch (e) {
      _setError('Failed to update task: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Change task status
  Future<void> changeTaskStatus(String taskId, TaskStatus newStatus) async {
    if (_currentBoard == null) {
      _setError('No current board selected');
      return;
    }
    
    _setLoading(true);
    try {
      await _taskService.changeTaskStatus(_currentBoard!.id, taskId, newStatus);
      await setCurrentBoard(_currentBoard!.id);
      _clearError();
    } catch (e) {
      _setError('Failed to change task status: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_currentBoard == null) {
      _setError('No current board selected');
      return;
    }
    
    _setLoading(true);
    try {
      await _taskService.deleteTask(_currentBoard!.id, taskId);
      await setCurrentBoard(_currentBoard!.id);
      _clearError();
    } catch (e) {
      _setError('Failed to delete task: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Refresh current board data
  Future<void> refreshCurrentBoard() async {
    if (_currentBoard != null) {
      await setCurrentBoard(_currentBoard!.id);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 