import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'dart:async';

class StylusInputWidget extends StatefulWidget {
  final Function(String) onTextEntered;
  final String hintText;
  final bool clearAfterSubmit;

  const StylusInputWidget({
    Key? key,
    required this.onTextEntered,
    this.hintText = 'Write with S Pen...',
    this.clearAfterSubmit = true,
  }) : super(key: key);

  @override
  _StylusInputWidgetState createState() => _StylusInputWidgetState();
}

class _StylusInputWidgetState extends State<StylusInputWidget> {
  final DrawingController _drawingController = DrawingController();
  bool _isDrawing = false;
  bool _isConverting = false;
  final List<String> _convertedTextHistory = [];
  int _strokeCount = 0;

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Stylus drawing area
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  // Drawing board
                  DrawingBoard(
                    controller: _drawingController,
                    background: Container(
                      color: Colors.white,
                      child: _isDrawing 
                          ? null 
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.grey.shade300,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.hintText,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    ),
                    showDefaultActions: false,
                    showDefaultTools: false,
                    boardPanEnabled: false,
                    boardScaleEnabled: false,
                  ),
                  // Overlay to detect drawing starts
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (_) => _onStrokeStart(),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // History of converted text (if any)
          if (_convertedTextHistory.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _convertedTextHistory.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => widget.onTextEntered(_convertedTextHistory[index]),
                      child: Chip(
                        label: Text(_convertedTextHistory[index]),
                        deleteIcon: Icon(Icons.arrow_forward, size: 16),
                        onDeleted: () => widget.onTextEntered(_convertedTextHistory[index]),
                        backgroundColor: Colors.indigo.shade50,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Bottom toolbar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Clear button
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  label: Text('Clear'),
                  onPressed: () {
                    _drawingController.clear();
                    setState(() {
                      _isDrawing = false;
                      _strokeCount = 0;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                Spacer(),
                // Auto-convert checkbox
                if (_isDrawing)
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Auto-convert',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                SizedBox(width: 12),
                // Convert button
                ElevatedButton.icon(
                  onPressed: _isDrawing && !_isConverting ? _submitHandwriting : null,
                  icon: _isConverting 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.text_fields),
                  label: Text(_isConverting ? 'Converting...' : 'Convert to Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onStrokeStart() {
    setState(() {
      _isDrawing = true;
      _strokeCount++;
    });
    
    // If user has drawn several strokes, auto-convert after a delay
    if (_strokeCount > 5) {
      // Wait for user to finish drawing
      Timer(Duration(milliseconds: 2000), () {
        if (_strokeCount > 5 && mounted && !_isConverting) {
          _submitHandwriting();
        }
      });
    }
  }

  void _submitHandwriting() {
    // In a real implementation, we'd use a handwriting recognition API
    _simulateHandwritingRecognition();
  }

  void _simulateHandwritingRecognition() {
    setState(() {
      _isConverting = true;
    });
    
    // In a real app, you would call a handwriting recognition API here
    
    // For demonstration, simulate processing delay and provide sample results
    Future.delayed(Duration(milliseconds: 800), () {
      if (!mounted) return;
      
      setState(() {
        _isConverting = false;
      });
      
      // Simulate different recognized texts based on stroke count
      // In a real app, this would be the result from the recognition API
      final List<String> possibleTexts = [
        "Hello world",
        "Meeting notes",
        "Important task",
        "Follow up with client",
        "Project deadline Friday",
        "Call John regarding project",
        "Schedule team meeting",
        "Review documentation",
        "Implement feature request",
        "Fix critical bug",
      ];
      
      final recognizedText = possibleTexts[_strokeCount % possibleTexts.length];
      
      // Add to history for quick reuse
      setState(() {
        if (!_convertedTextHistory.contains(recognizedText)) {
          _convertedTextHistory.insert(0, recognizedText);
          // Limit history size
          if (_convertedTextHistory.length > 5) {
            _convertedTextHistory.removeLast();
          }
        }
      });
      
      // Show options dialog with the recognized text
      _showRecognizedTextDialog(recognizedText);
    });
  }
  
  void _showRecognizedTextDialog(String recognizedText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.text_fields, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Recognized Text'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The following text was recognized:'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                recognizedText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo.shade800,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You can edit this text if needed.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Clear the drawing area if requested
              if (widget.clearAfterSubmit) {
                _drawingController.clear();
                setState(() {
                  _isDrawing = false;
                  _strokeCount = 0;
                });
              }
            },
            child: Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              // Pass recognized text to parent widget
              widget.onTextEntered(recognizedText);
              
              // Close dialog
              Navigator.pop(context);
              
              // Clear the drawing area if requested
              if (widget.clearAfterSubmit) {
                _drawingController.clear();
                setState(() {
                  _isDrawing = false;
                  _strokeCount = 0;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
            ),
            child: Text('Use This Text'),
          ),
        ],
      ),
    );
  }
}

// Widget to add stylus input button to any text field
class StylusInputButton extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  
  const StylusInputButton({
    Key? key,
    required this.controller,
    this.hintText = 'Write with S Pen...',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      tooltip: 'Write with S Pen',
      onPressed: () {
        _showStylusInputDialog(context);
      },
    );
  }
  
  void _showStylusInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    'S Pen Input',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: StylusInputWidget(
                  hintText: hintText,
                  onTextEntered: (text) {
                    // Insert text at cursor position
                    final currentText = controller.text;
                    final selection = controller.selection;
                    final newText = currentText.replaceRange(
                      selection.start,
                      selection.end,
                      text,
                    );
                    
                    // Update controller
                    controller.text = newText;
                    controller.selection = TextSelection.collapsed(
                      offset: selection.start + text.length,
                    );
                    
                    // Close dialog
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 