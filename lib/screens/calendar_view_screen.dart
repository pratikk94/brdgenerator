import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../state/task_state.dart';
import '../widgets/task_dialog.dart';
import '../utils/currency_converter.dart';
import '../state/document_state.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/safe_avatar.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Task>> _events = {};
  bool _isLoading = true;
  
  // User filtering
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  String? _selectedUserId;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadUsers();
    _loadTasks();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _calendarFormat = CalendarFormat.week;
            break;
          case 1:
            _calendarFormat = CalendarFormat.month;
            break;
          case 2:
            _calendarFormat = CalendarFormat.month; // Year view uses month format with different UI
            break;
        }
      });
    }
  }
  
  // Load available users for the dropdown
  Future<void> _loadUsers() async {
    try {
      final users = await _firebaseService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          // Only set selected user if we have users and current user is in the list
          if (_authService.currentUser != null) {
            final currentUserId = _authService.currentUser!.uid;
            // Check if current user is in the list
            final userExists = users.any((user) => user.uid == currentUserId);
            if (userExists) {
              _selectedUserId = currentUserId;
            } else if (users.isNotEmpty) {
              // Fallback to first user if current user not found
              _selectedUserId = users.first.uid;
            }
          }
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      // Set empty list but don't crash
      if (mounted) {
        setState(() {
          _users = [];
          _selectedUserId = null;
        });
      }
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final taskState = Provider.of<TaskState>(context, listen: false);
      await taskState.refreshCurrentBoard();
      
      // Ensure we have a current board
      if (taskState.currentBoard != null) {
        final Map<DateTime, List<Task>> eventMap = {};
        
        // Get tasks to display based on filter
        List<Task> tasksToDisplay = taskState.currentBoard!.tasks;
        
        // Filter by selected user if one is selected
        if (_selectedUserId != null) {
          tasksToDisplay = tasksToDisplay.where((task) =>
            // Show tasks assigned to selected user or if they created it
            (task.assignee != null && task.assignee == _selectedUserId) || 
            (task.createdBy != null && task.createdBy == _selectedUserId)
          ).toList();
        }
        
        // Process filtered tasks and organize them by date
        for (final task in tasksToDisplay) {
          try {
            // For todo tasks, use deadline as the event date
            if (task.status == TaskStatus.todo && task.deadline != null) {
              final dateKey = DateTime(
                task.deadline!.year, 
                task.deadline!.month, 
                task.deadline!.day
              );
              
              if (!eventMap.containsKey(dateKey)) {
                eventMap[dateKey] = [];
              }
              eventMap[dateKey]!.add(task);
            }
            
            // For doing tasks, use startedAt as the event date
            if (task.status == TaskStatus.doing && task.startedAt != null) {
              final dateKey = DateTime(
                task.startedAt!.year, 
                task.startedAt!.month, 
                task.startedAt!.day
              );
              
              if (!eventMap.containsKey(dateKey)) {
                eventMap[dateKey] = [];
              }
              eventMap[dateKey]!.add(task);
            }
            
            // For done tasks, use completedAt as the event date
            if (task.status == TaskStatus.done && task.completedAt != null) {
              final dateKey = DateTime(
                task.completedAt!.year, 
                task.completedAt!.month, 
                task.completedAt!.day
              );
              
              if (!eventMap.containsKey(dateKey)) {
                eventMap[dateKey] = [];
              }
              eventMap[dateKey]!.add(task);
            }
          } catch (e) {
            print('Error processing task for calendar: $e');
            // Skip this task but continue processing others
          }
        }
        
        if (mounted) {
          setState(() {
            _events = eventMap;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _events = {};
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading tasks: $e');
      if (mounted) {
        setState(() {
          _events = {};
          _isLoading = false;
        });
      }
    }
  }

  List<Task> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  List<Task> _getEventsForWeek(DateTime week) {
    final List<Task> events = [];
    for (int i = 0; i < 7; i++) {
      final day = week.add(Duration(days: i));
      events.addAll(_getEventsForDay(day));
    }
    return events;
  }

  List<Task> _getEventsForMonth(DateTime month) {
    final List<Task> events = [];
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(month.year, month.month, i);
      events.addAll(_getEventsForDay(day));
    }
    return events;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'WEEKLY'),
            Tab(text: 'MONTHLY'),
            Tab(text: 'YEARLY'),
          ],
        ),
        actions: [
          // User filter dropdown
          _buildUserDropdown(),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh calendar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWeeklyView(),
                _buildMonthlyView(),
                _buildYearlyView(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _openTaskDialog(null, deadline: _selectedDay);
          _loadTasks();
        },
        child: const Icon(Icons.add),
        tooltip: 'Add task for selected date',
      ),
    );
  }
  
  // Build the user selection dropdown
  Widget _buildUserDropdown() {
    // First validate that the selected user exists in the list
    bool userExists = false;
    if (_selectedUserId != null) {
      userExists = _users.any((user) => user.uid == _selectedUserId);
      if (!userExists) {
        // Reset to null if user not in list
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedUserId = null;
          });
        });
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String?>(
        value: userExists ? _selectedUserId : null,
        hint: const Text('All Users'),
        icon: const Icon(Icons.person),
        underline: Container(height: 0),
        onChanged: (String? newValue) {
          setState(() {
            _selectedUserId = newValue;
          });
          _loadTasks(); // Reload tasks with new filter
        },
        items: [
          // "All users" option
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All Users'),
          ),
          // Individual user options
          ..._users.map((user) {
            return DropdownMenuItem<String?>(
              value: user.uid,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.photoURL != null)
                    SafeAvatar(
                      imageUrl: user.photoURL!,
                      radius: 12,
                      fallbackWidget: const Icon(Icons.person, size: 16),
                    )
                  else
                    const SafeAvatar(
                      radius: 12,
                      fallbackWidget: Icon(Icons.person, size: 16),
                    ),
                  const SizedBox(width: 8),
                  Text(user.displayName ?? 'Unknown User'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.week,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: _getEventsForDay,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: _buildTaskList(_getEventsForWeek(_selectedDay)),
        ),
      ],
    );
  }

  Widget _buildMonthlyView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: _getEventsForDay,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: _buildTaskList(_getEventsForDay(_selectedDay)),
        ),
      ],
    );
  }

  Widget _buildYearlyView() {
    final currentYear = _focusedDay.year;
    final months = List.generate(12, (index) => DateTime(currentYear, index + 1));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year - 1, _focusedDay.month);
                  });
                },
              ),
              Text(
                currentYear.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month);
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: months.map((month) {
              final monthEvents = _getEventsForMonth(month);
              final todoCount = monthEvents.where((task) => task.status == TaskStatus.todo).length;
              final doingCount = monthEvents.where((task) => task.status == TaskStatus.doing).length;
              final doneCount = monthEvents.where((task) => task.status == TaskStatus.done).length;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _focusedDay = month;
                    _selectedDay = DateTime(month.year, month.month, 1);
                    _tabController.animateTo(1); // Switch to monthly view
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMMM').format(month),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatusCount('To Do', todoCount, Colors.grey),
                              _buildStatusCount('Doing', doingCount, Colors.blue),
                              _buildStatusCount('Done', doneCount, Colors.green),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${monthEvents.length} task${monthEvents.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCount(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks for this period'),
      );
    }
    
    // Sort tasks by date
    tasks.sort((a, b) {
      // Use deadline for todo tasks
      final DateTime? dateA = a.deadline ?? a.startedAt ?? a.completedAt;
      final DateTime? dateB = b.deadline ?? b.startedAt ?? b.completedAt;
      
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      
      return dateA.compareTo(dateB);
    });
    
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final dateString = _getTaskDateString(task);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: task.status.color.withOpacity(0.2),
              child: Icon(
                _getTaskIcon(task),
                color: task.status.color,
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateString),
                // Show assignee if available
                if (task.assignee != null)
                  FutureBuilder<UserModel?>(
                    future: _firebaseService.getUserById(task.assignee!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 0);
                      }
                      
                      final user = snapshot.data;
                      if (user == null) {
                        return const SizedBox(height: 0);
                      }
                      
                      return Row(
                        children: [
                          const Icon(Icons.person, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            user.displayName ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyConverter.format(task.revenuePotential, 'USD'),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${task.estimatedHours}h',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            onTap: () async {
              await _openTaskDialog(task);
              _loadTasks();
            },
          ),
        );
      },
    );
  }

  String _getTaskDateString(Task task) {
    switch (task.status) {
      case TaskStatus.todo:
        if (task.deadline != null) {
          final daysUntil = task.daysToDeadline;
          final deadlineStr = DateFormat('MMM d, y').format(task.deadline!);
          
          if (daysUntil < 0) {
            return 'Overdue: $deadlineStr (${daysUntil.abs()} days ago)';
          } else if (daysUntil == 0) {
            return 'Due today: $deadlineStr';
          } else if (daysUntil == 1) {
            return 'Due tomorrow: $deadlineStr';
          } else {
            return 'Due in $daysUntil days: $deadlineStr';
          }
        }
        return 'To Do';
        
      case TaskStatus.doing:
        if (task.startedAt != null) {
          final daysAgo = DateTime.now().difference(task.startedAt!).inDays;
          final startedStr = DateFormat('MMM d').format(task.startedAt!);
          
          if (daysAgo == 0) {
            return 'Started today';
          } else if (daysAgo == 1) {
            return 'Started yesterday';
          } else {
            return 'Started $daysAgo days ago ($startedStr)';
          }
        }
        return 'In Progress';
        
      case TaskStatus.done:
        if (task.completedAt != null) {
          final daysAgo = DateTime.now().difference(task.completedAt!).inDays;
          final completedStr = DateFormat('MMM d').format(task.completedAt!);
          
          if (daysAgo == 0) {
            return 'Completed today';
          } else if (daysAgo == 1) {
            return 'Completed yesterday';
          } else {
            return 'Completed $daysAgo days ago ($completedStr)';
          }
        }
        return 'Completed';
    }
  }

  IconData _getTaskIcon(Task task) {
    switch (task.status) {
      case TaskStatus.todo:
        return task.isOverdue ? Icons.warning : Icons.schedule;
      case TaskStatus.doing:
        return Icons.play_arrow;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  Future<void> _openTaskDialog(Task? task, {DateTime? deadline}) async {
    await showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        deadline: deadline ?? task?.deadline,
        onSaved: (_) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
} 