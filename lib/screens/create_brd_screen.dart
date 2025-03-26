import 'package:flutter/material.dart';
import '../models/brd_model.dart';
import '../services/openai_service.dart';
import '../services/storage_service.dart';

class CreateBRDScreen extends StatefulWidget {
  const CreateBRDScreen({super.key});

  @override
  State<CreateBRDScreen> createState() => _CreateBRDScreenState();
}

class _CreateBRDScreenState extends State<CreateBRDScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  final _openAIService = OpenAIService();
  final _storageService = StorageService();
  bool _isGenerating = false;
  String? _generatedContent;

  Future<void> _generateBRD() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isGenerating = true;
        _generatedContent = null;
      });

      try {
        final content = await _openAIService.generateBRD(_promptController.text);
        if (mounted) {
          setState(() {
            _generatedContent = content;
            _isGenerating = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating BRD: $e')),
          );
          setState(() {
            _isGenerating = false;
          });
        }
      }
    }
  }

  Future<void> _saveBRD() async {
    if (_generatedContent != null && _titleController.text.isNotEmpty) {
      final brd = BRDDocument(
        title: _titleController.text,
        content: _generatedContent!,
        createdAt: DateTime.now(),
      );

      try {
        await _storageService.saveBRDDocument(brd);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('BRD document saved successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving BRD: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create BRD Document'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Document Title',
                  hintText: 'Enter a title for your BRD',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_generatedContent == null) ...[
                Expanded(
                  child: TextFormField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      labelText: 'Project Description',
                      hintText: 'Describe your project in detail to generate a BRD',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project description';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateBRD,
                  child: _isGenerating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('Generating BRD...'),
                          ],
                        )
                      : const Text('Generate BRD'),
                ),
              ] else ...[
                const Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: Text(_generatedContent!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveBRD,
                  child: const Text('Save Document'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 