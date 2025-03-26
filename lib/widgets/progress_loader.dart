import 'package:flutter/material.dart';

class ProgressLoader extends StatefulWidget {
  final String message;
  final double progress;
  final bool isIndeterminate;

  const ProgressLoader({
    Key? key,
    this.message = 'Processing...',
    this.progress = 0.0,
    this.isIndeterminate = true,
  }) : super(key: key);

  @override
  _ProgressLoaderState createState() => _ProgressLoaderState();
}

class _ProgressLoaderState extends State<ProgressLoader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 80,
              height: 80,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                value: widget.isIndeterminate ? null : widget.progress,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          if (!widget.isIndeterminate) ...[
            SizedBox(height: 16),
            Container(
              width: 200,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper function to show the loader as a dialog
void showProgressDialog(BuildContext context, {String message = 'Processing...', double progress = 0.0, bool isIndeterminate = true}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ProgressLoader(
          message: message,
          progress: progress,
          isIndeterminate: isIndeterminate,
        ),
      );
    },
  );
}

// Helper function to update progress
void updateProgressDialog(BuildContext context, double progress, {String? message}) {
  Navigator.of(context).pop();
  showProgressDialog(
    context, 
    progress: progress,
    message: message ?? 'Processing...',
    isIndeterminate: false,
  );
}

// Helper function to hide the loader
void hideProgressDialog(BuildContext context) {
  Navigator.of(context).pop();
} 