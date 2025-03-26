import 'package:flutter/material.dart';
import '../widgets/stylus_input_widget.dart';
import '../utils/s_pen_detector.dart';

class StylusTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final bool expands;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool enabled;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String stylusHintText;
  final bool showStylusButton;

  const StylusTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.expands = false,
    this.decoration,
    this.style,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
    this.stylusHintText = 'Write with S Pen...',
    this.showStylusButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isStylusAvailable = showStylusButton && SPenDetector.shouldShowStylusFeatures();
    
    final baseDecoration = decoration ?? InputDecoration(
      hintText: hintText,
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    );
    
    // Add stylus button to decoration if available
    final finalDecoration = isStylusAvailable 
        ? baseDecoration.copyWith(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: StylusInputButton(
                controller: controller,
                hintText: stylusHintText,
              ),
            ),
          )
        : baseDecoration;
    
    return TextField(
      controller: controller,
      maxLines: expands ? null : maxLines,
      expands: expands,
      decoration: finalDecoration,
      style: style,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
} 