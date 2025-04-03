import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/brd_component.dart';

class GlossaryForm extends StatefulWidget {
  final BRDComponent component;
  final Function(Map<String, dynamic>) onUpdate;

  const GlossaryForm({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<GlossaryForm> createState() => _GlossaryFormState();
}

class _GlossaryFormState extends State<GlossaryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _termsController = TextEditingController();
  bool _isLoading = true;
  Map<String, dynamic> _glossaryData = {};
  List<Map<String, String>> _glossaryItems = [];

  @override
  void initState() {
    super.initState();
    _loadComponentData();
  }

  @override
  void dispose() {
    _termsController.dispose();
    super.dispose();
  }

  void _loadComponentData() {
    setState(() => _isLoading = true);
    
    try {
      if (widget.component.content.isNotEmpty) {
        _glossaryData = jsonDecode(widget.component.content) as Map<String, dynamic>;
        
        // For the glossary, the content might be in different formats based on how it was generated
        if (_glossaryData.containsKey('terms')) {
          // Format: Original form style with separate terms field
          _parseTermsFromString(_glossaryData['terms'] as String? ?? '');
        } else if (_glossaryData.containsKey('content')) {
          // Format: AI generated with just a content field
          _parseTermsFromString(_glossaryData['content'] as String? ?? '');
        } else if (_glossaryData.containsKey('rawContent')) {
          // Format: Raw content
          _parseTermsFromString(_glossaryData['rawContent'] as String? ?? '');
        }
      }
    } catch (e) {
      print('Error loading glossary data: $e');
      // If there's an error, start with empty data
      _glossaryItems = [];
    }
    
    setState(() => _isLoading = false);
  }

  void _parseTermsFromString(String content) {
    _glossaryItems = [];
    
    // Try to extract terms from a markdown formatted list
    final lines = content.split('\n');
    
    for (var line in lines) {
      // Skip empty lines
      if (line.trim().isEmpty) continue;
      
      // Try to find term and definition patterns
      if (line.contains(':') || line.contains(' - ')) {
        String term;
        String definition;
        
        if (line.contains(':')) {
          final parts = line.split(':');
          term = parts[0].trim().replaceAll(RegExp(r'^[-*•]'), '').trim();
          definition = parts.sublist(1).join(':').trim();
        } else {
          final parts = line.split(' - ');
          term = parts[0].trim().replaceAll(RegExp(r'^[-*•]'), '').trim();
          definition = parts.sublist(1).join(' - ').trim();
        }
        
        if (term.isNotEmpty && definition.isNotEmpty) {
          _glossaryItems.add({
            'term': term,
            'definition': definition,
          });
        }
      }
    }
    
    // Sort alphabetically
    _glossaryItems.sort((a, b) => a['term']!.compareTo(b['term']!));
  }

  void _saveData() {
    // Format the terms and definitions into a structured format
    final termsData = _glossaryItems.map((item) {
      return '${item['term']}: ${item['definition']}';
    }).join('\n\n');
    
    _glossaryData = {
      'terms': termsData,
    };
    
    widget.onUpdate(_glossaryData);
  }

  void _addTerm() {
    TextEditingController termController = TextEditingController();
    TextEditingController definitionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Term'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: termController,
                  decoration: const InputDecoration(
                    labelText: 'Term',
                    hintText: 'e.g., API',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a term';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: definitionController,
                  decoration: const InputDecoration(
                    labelText: 'Definition',
                    hintText: 'e.g., Application Programming Interface',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a definition';
                    }
                    return null;
                  },
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
                _glossaryItems.add({
                  'term': termController.text,
                  'definition': definitionController.text,
                });
                
                // Sort alphabetically
                _glossaryItems.sort((a, b) => a['term']!.compareTo(b['term']!));
                
                setState(() {});
                
                // Save data
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

  void _removeTerm(int index) {
    setState(() {
      _glossaryItems.removeAt(index);
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
              'Glossary / Appendix',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: _addTerm,
              icon: const Icon(Icons.add),
              label: const Text('Add Term'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Define key terms and acronyms used in the document to ensure clarity for all readers.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _glossaryItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No glossary terms yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _addTerm,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Term'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _glossaryItems.length,
                  itemBuilder: (context, index) {
                    final item = _glossaryItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          item['term']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item['definition']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTerm(index),
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