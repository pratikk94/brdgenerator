import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  
  const LoadingIndicator({
    super.key, 
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 