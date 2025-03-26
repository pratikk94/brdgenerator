import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../state/task_state.dart';
import '../state/document_state.dart';
import '../utils/currency_converter.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final TaskStatus initialStatus;
  final DateTime? initialDeadline;
  final DateTime? deadline;
  final Function(Task)? onSaved;
  
  const TaskDialog({
    Key? key,
    this.task,
    this.initialStatus = TaskStatus.todo,
    this.initialDeadline,
    this.deadline,
    this.onSaved,
  }) : super(key: key);
  
  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimatedHoursController;
  late final TextEditingController _hourlyRateController;
  late final TextEditingController _baselineCostController;
  late final TextEditingController _deadlineController;
  late TaskStatus _status;
  DateTime? _deadline;
  bool _useAIEstimation = false;
  bool _isEstimating = false;
  bool _isLoading = false;
  
  // User related fields
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  String? _assigneeId;
  List<UserModel> _users = [];
  
  @override
  void initState() {
    super.initState();
    _status = widget.task?.status ?? widget.initialStatus;
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _estimatedHoursController = TextEditingController(
      text: widget.task?.estimatedHours.toString() ?? '1.0',
    );
    _hourlyRateController = TextEditingController(
      text: widget.task?.hourlyRate.toString() ?? '50.0',
    );
    _baselineCostController = TextEditingController(
      text: widget.task?.baselineCost.toString() ?? '0.0',
    );
    _deadline = widget.task?.deadline ?? widget.deadline ?? widget.initialDeadline;
    _deadlineController = TextEditingController(
      text: _deadline != null ? DateFormat('MMM d, yyyy').format(_deadline!) : '',
    );
    _useAIEstimation = widget.task?.aiEstimated ?? false;
    _assigneeId = widget.task?.assignee;
    
    _loadUsers();
  }
  
  // Load users for assignee dropdown
  Future<void> _loadUsers() async {
    try {
      final users = await _firebaseService.getAllUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    _hourlyRateController.dispose();
    _baselineCostController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  // Select deadline date
  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
        _deadlineController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  // Get AI estimation for task
  Future<void> _getAIEstimate() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title first')),
      );
      return;
    }
    
    setState(() {
      _isEstimating = true;
    });
    
    try {
      final taskService = TaskService();
      final estimates = await taskService.getAIEstimate(
        _titleController.text, 
        _descriptionController.text
      );
      
      setState(() {
        _estimatedHoursController.text = estimates['estimatedHours']!.toStringAsFixed(1);
        _hourlyRateController.text = estimates['suggestedRate']!.toStringAsFixed(0);
        _useAIEstimation = true;
        _isEstimating = false;
      });
      
      // Calculate baseline cost (60% of revenue as default)
      final estimatedHours = estimates['estimatedHours']!;
      final hourlyRate = estimates['suggestedRate']!;
      final revenue = estimatedHours * hourlyRate;
      setState(() {
        _baselineCostController.text = (revenue * 0.6).toStringAsFixed(2);
      });
      
    } catch (e) {
      setState(() {
        _isEstimating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting AI estimate: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final task = widget.task!;
    final revenuePotential = task.revenuePotential;
    final baselineCost = task.getBaselineCost;
    final profitMargin = task.profitMargin;
    final documentState = Provider.of<DocumentState>(context);
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _estimatedHoursController,
                      decoration: InputDecoration(
                        labelText: 'Estimated Hours',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.timer_outlined),
                        suffixIcon: IconButton(
                          icon: _isEstimating 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2)
                              )
                            : const Icon(Icons.auto_awesome),
                          tooltip: 'Get AI estimate',
                          onPressed: _isEstimating ? null : _getAIEstimate,
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final hours = double.tryParse(value);
                        if (hours == null || hours <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (\$)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baselineCostController,
                decoration: const InputDecoration(
                  labelText: 'Baseline Cost (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assessment),
                  helperText: 'Cost to complete this task (materials, expenses)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Deadline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDeadline(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.indigo.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _deadlineController.text.isEmpty ? 'Select deadline' : _deadlineController.text,
                          style: _deadlineController.text.isEmpty 
                              ? TextStyle(color: Colors.grey.shade600)
                              : TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (_deadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _deadline = null;
                              _deadlineController.text = '';
                            });
                          },
                          tooltip: 'Clear deadline',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Task Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskStatus>(
                segments: [
                  ButtonSegment<TaskStatus>(
                    value: TaskStatus.todo,
                    label: Text(TaskStatus.todo.name),
                    icon: const Icon(Icons.checklist),
                  ),
                  ButtonSegment<TaskStatus>(
                    value: TaskStatus.doing,
                    label: Text(TaskStatus.doing.name),
                    icon: const Icon(Icons.play_circle_outline),
                  ),
                  ButtonSegment<TaskStatus>(
                    value: TaskStatus.done,
                    label: Text(TaskStatus.done.name),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                ],
                selected: {_status},
                onSelectionChanged: (Set<TaskStatus> newSelection) {
                  setState(() {
                    _status = newSelection.first;
                  });
                },
              ),
              if (_useAIEstimation) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.indigo),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Estimated',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.indigo,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Confidence: High',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (isEditing && widget.task!.status != TaskStatus.todo) ...[
                const SizedBox(height: 16),
                const Text(
                  'Task Metrics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMetricsCard(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _submitForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
  
  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Create a map with task data
      final taskData = {
        'id': widget.task?.id ?? '',
        'title': _titleController.text,
        'description': _descriptionController.text,
        'estimatedHours': double.parse(_estimatedHoursController.text),
        'hourlyRate': double.parse(_hourlyRateController.text),
        'status': _status,
        'deadline': _deadline,
        'baselineCost': double.parse(_baselineCostController.text),
        'aiEstimated': _useAIEstimation,
      };
      
      Navigator.of(context).pop(taskData);
    }
  }
  
  Widget _buildMetricsCard() {
    if (widget.task == null) return const SizedBox.shrink();
    
    final task = widget.task!;
    final revenuePotential = task.revenuePotential;
    final baselineCost = task.getBaselineCost;
    final profitMargin = task.profitMargin;
    final documentState = Provider.of<DocumentState>(context);
    
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  'Time Spent',
                  _formatDuration(task.timeSpent),
                  Icons.timelapse,
                ),
                _buildMetricItem(
                  'Revenue',
                  documentState.formatCurrency(task.revenue),
                  Icons.attach_money,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  'Potential',
                  documentState.formatCurrency(revenuePotential),
                  Icons.trending_up,
                ),
                _buildMetricItem(
                  'Baseline Cost',
                  documentState.formatCurrency(baselineCost),
                  Icons.assessment,
                ),
              ],
            ),
            if (task.status == TaskStatus.done) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Efficiency:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        task.efficiencyRate >= 1.0 ? Icons.thumb_up : Icons.thumb_down,
                        size: 16,
                        color: task.efficiencyRate >= 1.0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(task.efficiencyRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: task.efficiencyRate >= 1.0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profit Margin:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${profitMargin.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: profitMargin >= 30 ? Colors.green : (profitMargin >= 15 ? Colors.orange : Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
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