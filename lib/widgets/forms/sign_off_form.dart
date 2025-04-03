import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class SignOffForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const SignOffForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<SignOffForm> createState() => _SignOffFormState();
}

class _SignOffFormState extends State<SignOffForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Map<String, dynamic> _signOffData = {};
  List<Map<String, String>> _approvers = [];

  @override
  void initState() {
    super.initState();
    _loadComponentData();
  }

  void _loadComponentData() {
    setState(() => _isLoading = true);
    
    try {
      if (widget.component.content.isNotEmpty) {
        _signOffData = jsonDecode(widget.component.content) as Map<String, dynamic>;
        
        // The format might vary based on how the data was generated
        if (_signOffData.containsKey('approvers')) {
          _parseApproversFromString(_signOffData['approvers'] as String? ?? '');
        } else if (_signOffData.containsKey('content')) {
          // AI generated content
          _parseApproversFromString(_signOffData['content'] as String? ?? '');
        } else if (_signOffData.containsKey('rawContent')) {
          // Raw content
          _parseApproversFromString(_signOffData['rawContent'] as String? ?? '');
        }
      }
    } catch (e) {
      print('Error loading sign-off data: $e');
      // Start with empty approvers list
      _approvers = [];
    }
    
    setState(() => _isLoading = false);
  }

  void _parseApproversFromString(String content) {
    _approvers = [];
    
    // Try to extract approvers from markdown formatted list
    final lines = content.split('\n');
    
    for (var line in lines) {
      // Skip empty lines
      if (line.trim().isEmpty) continue;
      
      // Try to find approver data
      if (line.contains('|')) {
        // Table format
        final parts = line.split('|').where((part) => part.trim().isNotEmpty).toList();
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final role = parts.length > 1 ? parts[1].trim() : '';
          final date = parts.length > 2 ? parts[2].trim() : '';
          
          if (name.isNotEmpty) {
            _approvers.add({
              'name': name,
              'role': role,
              'date': date,
            });
          }
        }
      } else if (line.contains(':')) {
        // Key-value format
        if (line.toLowerCase().contains('name:') || line.toLowerCase().contains('stakeholder:')) {
          final nameEntry = _extractKeyValue(line);
          if (nameEntry.isNotEmpty) {
            // Look ahead for role and date in subsequent lines
            int idx = lines.indexOf(line);
            String role = '';
            String date = '';
            
            if (idx + 1 < lines.length && lines[idx + 1].toLowerCase().contains('role:')) {
              role = _extractKeyValue(lines[idx + 1]);
            }
            
            if (idx + 2 < lines.length && lines[idx + 2].toLowerCase().contains('date:')) {
              date = _extractKeyValue(lines[idx + 2]);
            }
            
            _approvers.add({
              'name': nameEntry,
              'role': role,
              'date': date,
            });
          }
        }
      } else if (line.contains('-') || line.contains('•')) {
        // Bullet list format - look for name patterns
        final trimmedLine = line.replaceAll(RegExp(r'^[-*•]'), '').trim();
        if (trimmedLine.isNotEmpty) {
          _approvers.add({
            'name': trimmedLine,
            'role': '',
            'date': '',
          });
        }
      }
    }
  }

  String _extractKeyValue(String line) {
    if (line.contains(':')) {
      final parts = line.split(':');
      return parts.sublist(1).join(':').trim();
    }
    return '';
  }

  void _saveData() {
    // Format as a structured approvers list
    final approversData = _approvers.map((approver) {
      return '${approver['name']} | ${approver['role']} | ${approver['date']}';
    }).join('\n');
    
    _signOffData = {
      'approvers': approversData,
    };
    
    widget.onUpdate(_signOffData);
  }

  void _addApprover() {
    TextEditingController nameController = TextEditingController();
    TextEditingController roleController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Approver'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., John Smith',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    hintText: 'e.g., Product Owner',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Sign-Off Date',
                    hintText: 'e.g., 15/04/2023',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _approvers.add({
                  'name': nameController.text,
                  'role': roleController.text,
                  'date': dateController.text,
                });
                
                setState(() {});
                _saveData();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeApprover(int index) {
    setState(() {
      _approvers.removeAt(index);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sign-Off',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: _addApprover,
              icon: const Icon(Icons.add),
              label: const Text('Add Approver'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Specify the stakeholders who need to review and approve this document.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _approvers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No approvers added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _addApprover,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Approver'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _approvers.length,
                  itemBuilder: (context, index) {
                    final approver = _approvers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          approver['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (approver['role']!.isNotEmpty)
                              Text('Role: ${approver['role']}'),
                            if (approver['date']!.isNotEmpty)
                              Text('Date: ${approver['date']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeApprover(index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
} 