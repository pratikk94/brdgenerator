import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/document_state.dart';
import '../widgets/financial_navbar.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/progress_loader.dart';
import '../widgets/stylus_text_field.dart';
import '../utils/s_pen_detector.dart';
// import '../utils/pdf_export.dart';

class DocumentScreen extends StatefulWidget {
  final String documentType;
  final String displayName;

  const DocumentScreen({
    Key? key,
    required this.documentType,
    required this.displayName,
  }) : super(key: key);

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  bool _isEditing = false;
  late TextEditingController _editingController;
  String _originalContent = '';

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentState = Provider.of<DocumentState>(context);
    final content = documentState.getDocumentContent(widget.documentType);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Update controller if content changed and not editing
    if (content != _originalContent && !_isEditing) {
      _originalContent = content;
      _editingController.text = content;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.displayName,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: Icon(Icons.save),
              tooltip: 'Save changes',
              onPressed: () => _saveContent(documentState),
            ),
            IconButton(
              icon: Icon(Icons.cancel),
              tooltip: 'Cancel editing',
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _editingController.text = _originalContent;
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Edit document',
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              tooltip: 'Share document',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share functionality coming soon'))
                );
              },
            ),
          ],
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: content.contains("Error generating document") 
            ? _buildErrorView(content)
            : _isEditing 
                ? _buildEditorView()
                : _buildDocumentView(content),
      ),
    );
  }

  Future<void> _saveContent(DocumentState documentState) async {
    showProgressDialog(context, message: 'Saving changes...');
    
    try {
      await documentState.updateDocument(widget.documentType, _editingController.text);
      _originalContent = _editingController.text;
      
      setState(() {
        _isEditing = false;
      });
      
      hideProgressDialog(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document updated successfully'))
      );
    } catch (e) {
      hideProgressDialog(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating document: $e'))
      );
    }
  }

  Widget _buildEditorView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_note,
                color: Colors.amber[800],
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Text(
                  'Editing Mode - Use markdown formatting',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: StylusTextField(
              controller: _editingController,
              expands: true,
              maxLines: null,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                height: 1.5,
                fontFamily: 'monospace',
              ),
              stylusHintText: 'Write with S Pen to add text to your document...',
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                border: InputBorder.none,
                hintText: 'Enter your markdown content here...',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentView(String content) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getIconForDocumentType(widget.documentType),
                color: Colors.indigo,
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.displayName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI-generated document based on your project description',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.indigo.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Markdown(
              data: content,
              selectable: true,
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              styleSheet: MarkdownStyleSheet(
                h1: TextStyle(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                h2: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                h3: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade600),
                p: TextStyle(fontSize: isSmallScreen ? 14 : 16, height: 1.5),
                listBullet: TextStyle(fontSize: isSmallScreen ? 14 : 16, height: 1.5),
                blockquote: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                tableBody: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForDocumentType(String documentType) {
    switch (documentType) {
      case 'BRD':
        return Icons.business;
      case 'FRD':
        return Icons.assignment;
      case 'NFR':
        return Icons.settings;
      case 'TDD':
        return Icons.code;
      case 'UI/UX':
        return Icons.brush;
      case 'API Docs':
        return Icons.timeline;
      case 'Test Cases':
        return Icons.bug_report;
      case 'Deployment Guide':
        return Icons.rocket_launch;
      case 'User Manual':
        return Icons.headset_mic;
      default:
        return Icons.description;
    }
  }

  Widget _buildErrorView(String errorMessage) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: isSmallScreen ? 48 : 64, color: Colors.red),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            "Error Generating Document",
            style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          ElevatedButton(
            onPressed: () {
              // Implement retry functionality if needed
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: isSmallScreen ? 10 : 12,
              ),
            ),
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }
} 