import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class ScopeForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const ScopeForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ScopeFormState createState() => _ScopeFormState();
}

class _ScopeFormState extends State<ScopeForm> {
  final _inScopeController = TextEditingController();
  final _outScopeController = TextEditingController();
  final _futureScopeController = TextEditingController();
  
  bool _isLoading = true;
  String _aiGeneratedContent = '';

  @override
  void initState() {
    super.initState();
    _loadComponentData();
  }

  void _loadComponentData() {
    setState(() => _isLoading = true);
    
    try {
      if (widget.component.content.isNotEmpty) {
        final data = jsonDecode(widget.component.content) as Map<String, dynamic>;
        
        _inScopeController.text = data['in_scope'] as String? ?? '';
        _outScopeController.text = data['out_scope'] as String? ?? '';
        _futureScopeController.text = data['future_scope'] as String? ?? '';
        
        // Store the full AI-generated content if available
        _aiGeneratedContent = data['aiContent'] as String? ?? '';
      }
    } catch (e) {
      print('Error loading scope data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _updateFormData() {
    final data = {
      'in_scope': _inScopeController.text,
      'out_scope': _outScopeController.text,
      'future_scope': _futureScopeController.text,
      'aiContent': _aiGeneratedContent,
    };
    
    widget.onUpdate(data);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Content Preview (if available)
          if (_aiGeneratedContent.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'AI-Generated Content',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_aiGeneratedContent),
                  ],
                ),
              ),
            ),
          ],
          
          // Form Fields
          const Text('In-Scope Items', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List all features, functionalities, and deliverables that are included in this project',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _inScopeController,
            decoration: const InputDecoration(
              hintText: 'Enter in-scope items (one per line)',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Out-of-Scope Items', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('List items that are explicitly NOT included in this project',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _outScopeController,
            decoration: const InputDecoration(
              hintText: 'Enter out-of-scope items (one per line)',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            onChanged: (_) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          const Text('Future Scope Items', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Items that may be considered for future phases or releases',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _futureScopeController,
            decoration: const InputDecoration(
              hintText: 'Enter potential future scope items',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (_) => _updateFormData(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inScopeController.dispose();
    _outScopeController.dispose();
    _futureScopeController.dispose();
    super.dispose();
  }
} 