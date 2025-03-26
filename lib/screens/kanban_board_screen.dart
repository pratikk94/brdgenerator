import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/board_model.dart';
import '../state/task_state.dart';
import '../widgets/task_column.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_statistics_card.dart';

class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({Key? key}) : super(key: key);

  @override
  _KanbanBoardScreenState createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  bool _showStatistics = false;
  
  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TaskState>(
          builder: (context, taskState, child) {
            if (taskState.isLoading) {
              return const Text('Loading Board...');
            }
            return taskState.currentBoard != null
                ? Text(taskState.currentBoard!.name)
                : const Text('Task Board');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_showStatistics ? Icons.analytics_outlined : Icons.analytics),
            onPressed: () {
              setState(() {
                _showStatistics = !_showStatistics;
              });
            },
            tooltip: _showStatistics ? 'Hide Statistics' : 'Show Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskState>(context, listen: false).refreshCurrentBoard();
            },
            tooltip: 'Refresh board',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuItemSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_board',
                  child: Text('Add New Board'),
                ),
                const PopupMenuItem<String>(
                  value: 'rename_board',
                  child: Text('Rename Board'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete_board',
                  child: Text('Delete Board'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<TaskState>(
        builder: (context, taskState, child) {
          if (taskState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (taskState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${taskState.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<TaskState>(context, listen: false).refreshCurrentBoard();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (taskState.currentBoard == null || taskState.boards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dashboard_customize, size: 64, color: Colors.grey),
                  const SizedBox(height: 24),
                  const Text(
                    'No boards available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create a new board to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Board'),
                    onPressed: () => _handleMenuItemSelected('add_board'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              if (_showStatistics && taskState.currentBoardStatistics != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TaskStatisticsCard(
                    statistics: taskState.currentBoardStatistics!,
                  ),
                ),
              ],
              _buildBoardSelector(taskState),
              Expanded(
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    children: [
                      TaskColumn(
                        status: TaskStatus.todo,
                        tasks: taskState.currentBoard!.getTasksByStatus(TaskStatus.todo),
                        onTaskTap: (task) => _openTaskDialog(task),
                        onAddTask: (status) => _openTaskDialog(null, initialStatus: status),
                      ),
                      const SizedBox(width: 16),
                      TaskColumn(
                        status: TaskStatus.doing,
                        tasks: taskState.currentBoard!.getTasksByStatus(TaskStatus.doing),
                        onTaskTap: (task) => _openTaskDialog(task),
                        onAddTask: (status) => _openTaskDialog(null, initialStatus: status),
                      ),
                      const SizedBox(width: 16),
                      TaskColumn(
                        status: TaskStatus.done,
                        tasks: taskState.currentBoard!.getTasksByStatus(TaskStatus.done),
                        onTaskTap: (task) => _openTaskDialog(task),
                        onAddTask: (status) => _openTaskDialog(null, initialStatus: status),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskDialog(null),
        child: const Icon(Icons.add),
        tooltip: 'Add task',
      ),
    );
  }
  
  Widget _buildBoardSelector(TaskState taskState) {
    if (taskState.boards.length <= 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: taskState.boards.map((board) {
            final isSelected = board.id == taskState.currentBoard?.id;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(board.name),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    Provider.of<TaskState>(context, listen: false)
                        .setCurrentBoard(board.id);
                  }
                },
                selectedColor: board.color.withOpacity(0.3),
                avatar: isSelected ? Icon(Icons.dashboard, color: board.color) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Future<void> _openTaskDialog(Task? task, {TaskStatus initialStatus = TaskStatus.todo}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        initialStatus: initialStatus,
      ),
    );
    
    if (result != null) {
      final taskState = Provider.of<TaskState>(context, listen: false);
      
      if (task != null) {
        // Update existing task
        final updatedTask = task.copyWith(
          title: result['title'],
          description: result['description'],
          estimatedHours: result['estimatedHours'],
          hourlyRate: result['hourlyRate'],
          status: result['status'],
        );
        
        taskState.updateTask(updatedTask);
      } else {
        // Create new task
        taskState.addTask(
          result['title'],
          result['description'],
          result['estimatedHours'],
          result['hourlyRate'],
        );
      }
    }
  }
  
  void _handleMenuItemSelected(String value) async {
    switch (value) {
      case 'add_board':
        _showAddBoardDialog();
        break;
      case 'rename_board':
        _showRenameBoardDialog();
        break;
      case 'delete_board':
        _showDeleteBoardDialog();
        break;
    }
  }
  
  Future<void> _showAddBoardDialog() async {
    final nameController = TextEditingController();
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    Color selectedColor = colorOptions.first;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create New Board'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Board Name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Select Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Provider.of<TaskState>(context, listen: false)
                        .createBoard(nameController.text, color: selectedColor);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
    
    nameController.dispose();
  }
  
  Future<void> _showRenameBoardDialog() async {
    final taskState = Provider.of<TaskState>(context, listen: false);
    if (taskState.currentBoard == null) return;
    
    final nameController = TextEditingController(text: taskState.currentBoard!.name);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Board'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Board Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updatedBoard = taskState.currentBoard!.copyWith(
                  name: nameController.text,
                );
                taskState.updateBoard(updatedBoard);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    
    nameController.dispose();
  }
  
  Future<void> _showDeleteBoardDialog() async {
    final taskState = Provider.of<TaskState>(context, listen: false);
    if (taskState.currentBoard == null) return;
    
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Board'),
        content: Text('Are you sure you want to delete "${taskState.currentBoard!.name}"? '
            'This action cannot be undone and all tasks will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirm) {
      taskState.deleteBoard(taskState.currentBoard!.id);
    }
  }
} 