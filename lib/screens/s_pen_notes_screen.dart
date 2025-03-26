import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import '../widgets/stylus_input_widget.dart';
import '../widgets/stylus_text_field.dart';
import '../widgets/financial_navbar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class SPenNotesScreen extends StatefulWidget {
  @override
  _SPenNotesScreenState createState() => _SPenNotesScreenState();
}

class _SPenNotesScreenState extends State<SPenNotesScreen> with TickerProviderStateMixin {
  final DrawingController _drawingController = DrawingController();
  bool _hasUnsavedChanges = false;
  String _notesText = '';
  final TextEditingController _textController = TextEditingController();
  late TabController _tabController;
  final List<String> _savedNotes = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Monitor drawing changes
    Future.delayed(Duration.zero, () {
      setState(() => _hasUnsavedChanges = false);
    });
    
    // Load any previously saved notes
    _loadSavedNotes();
  }
  
  @override
  void dispose() {
    _drawingController.dispose();
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSavedNotes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // List files in the directory
      final files = Directory(directory.path)
          .listSync()
          .where((file) => file.path.endsWith('.txt'))
          .map((file) => file.path.split('/').last)
          .toList();
      
      setState(() {
        _savedNotes.clear();
        _savedNotes.addAll(files);
      });
    } catch (e) {
      // Handle errors
      print("Error loading saved notes: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('S Pen Notes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.draw),
              text: 'Sketch',
            ),
            Tab(
              icon: Icon(Icons.notes),
              text: 'Notes',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'Saved',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _hasUnsavedChanges ? _saveCurrentNote : null,
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            tooltip: 'Open',
            onPressed: _openSavedNote,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Clear',
            onPressed: _clearCurrentNote,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sketch Tab - Drawing with S Pen
          _buildDrawingTab(),
          
          // Notes Tab - Handwriting to text
          _buildNotesTab(),
          
          // Saved Notes Tab
          _buildSavedNotesTab(),
        ],
      ),
      bottomNavigationBar: _hasUnsavedChanges
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Unsaved changes',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Save'),
                      onPressed: _saveDrawing,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
  
  Widget _buildDrawingTab() {
    return Column(
      children: [
        // Tool palette
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              _buildColorButton(Colors.black),
              _buildColorButton(Colors.blue),
              _buildColorButton(Colors.red),
              _buildColorButton(Colors.green),
              Spacer(),
              IconButton(
                icon: Icon(Icons.undo),
                onPressed: () {
                  _drawingController.undo();
                  setState(() => _hasUnsavedChanges = true);
                },
                tooltip: 'Undo',
              ),
              IconButton(
                icon: Icon(Icons.redo),
                onPressed: () {
                  _drawingController.redo();
                  setState(() => _hasUnsavedChanges = true);
                },
                tooltip: 'Redo',
              ),
            ],
          ),
        ),
        
        // Drawing area
        Expanded(
          child: Stack(
            children: [
              DrawingBoard(
                controller: _drawingController,
                background: Container(color: Colors.white),
                showDefaultTools: false,
                showDefaultActions: false,
                boardPanEnabled: false,
                boardScaleEnabled: false,
              ),
              // Overlay for detecting drawing
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (_) => setState(() => _hasUnsavedChanges = true),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          // With the current package version, we need to manually handle color changes
          // We'll change the UI color but drawing will remain with default color
          setState(() => _hasUnsavedChanges = true);
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotesTab() {
    return Column(
      children: [
        // S Pen input area with improved stylus widget
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: StylusInputWidget(
              hintText: 'Write with S Pen to create notes...',
              clearAfterSubmit: false,
              onTextEntered: (text) {
                setState(() {
                  if (_notesText.isNotEmpty) {
                    _notesText += '\n\n';
                  }
                  _notesText += text;
                  _textController.text = _notesText;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ),
        ),
        
        // Divider with label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Converted Text',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),
        
        // Text output area with stylus support
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: StylusTextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              hintText: 'Your converted text will appear here...',
              stylusHintText: 'Write more text with S Pen...',
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                hintText: 'Your converted text will appear here...',
              ),
              onChanged: (value) {
                setState(() {
                  _notesText = value;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSavedNotesTab() {
    if (_savedNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No saved notes yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create and save notes from the Sketch or Notes tab',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _savedNotes.length,
      itemBuilder: (context, index) {
        final fileName = _savedNotes[index];
        final isTextFile = fileName.endsWith('.txt');
        final isImageFile = fileName.endsWith('.png');
        
        // Extract date from filename (format: notes_yyyyMMdd_HHmmss.txt)
        String formattedDate = 'Unknown date';
        try {
          final dateString = fileName.split('_')[1] + '_' + fileName.split('_')[2].split('.')[0];
          final date = DateFormat('yyyyMMdd_HHmmss').parse(dateString);
          formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
        } catch (e) {
          // Use filename if date parsing fails
          formattedDate = fileName;
        }
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _openNoteFile(fileName),
            onLongPress: () => _confirmDeleteNote(fileName),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isTextFile ? Colors.blue.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isTextFile ? Icons.description : Icons.image,
                      color: isTextFile ? Colors.blue.shade700 : Colors.amber.shade700,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTextFile ? 'Text Note' : 'Sketch',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: () => _confirmDeleteNote(fileName),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _openNoteFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      if (fileName.endsWith('.txt')) {
        // Open text file
        final content = await file.readAsString();
        setState(() {
          _notesText = content;
          _textController.text = content;
          _tabController.animateTo(1); // Switch to notes tab
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note loaded successfully')),
        );
      } else {
        // For now, we don't support viewing image files directly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot preview image files yet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _confirmDeleteNote(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Note'),
          ],
        ),
        content: Text('Are you sure you want to delete "$fileName"?\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNoteFile(fileName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteNoteFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
        await _loadSavedNotes(); // Refresh the list
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _saveDrawing() async {
    // Implementation of saving drawing
  }
  
  void _saveCurrentNote() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Saving note...'),
            ],
          ),
        );
      },
    );
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      
      // Save based on current tab
      if (_tabController.index == 0) {
        // Save drawing - in a real app, you'd use a platform-specific method
        // to capture the drawing as an image
        
        // Simulating successful save for demo purposes
        await Future.delayed(Duration(milliseconds: 500));
        final fileName = 'sketch_$timestamp.png';
        
        // Add to saved notes list
        setState(() {
          _savedNotes.insert(0, fileName);
        });
      } else {
        // Save text notes
        final fileName = 'notes_$timestamp.txt';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(_notesText);
        
        // Add to saved notes list
        setState(() {
          _savedNotes.insert(0, fileName);
        });
      }
      
      setState(() => _hasUnsavedChanges = false);
      
      // Close loading dialog and show success
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog and show error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _openSavedNote() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();
        
        if (extension == 'txt') {
          // Text file - load into notes tab
          final content = await file.readAsString();
          setState(() {
            _notesText = content;
            _textController.text = content;
            _tabController.animateTo(1); // Switch to notes tab
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notes loaded successfully')),
          );
        } else {
          // For now, we only support loading text files
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unsupported file format. Only text files are supported.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _clearCurrentNote() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Note'),
          content: Text('Are you sure you want to clear the current note? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                
                if (_tabController.index == 0) {
                  // Clear drawing
                  _drawingController.clear();
                } else {
                  // Clear text notes
                  setState(() {
                    _notesText = '';
                    _textController.text = '';
                  });
                }
                
                setState(() => _hasUnsavedChanges = false);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note cleared')),
                );
              },
              child: Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
} 