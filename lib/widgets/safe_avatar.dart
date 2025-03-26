import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;

/// A safe CircleAvatar that handles invalid image URLs gracefully
class SafeAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final Widget? fallbackWidget;
  final Color? backgroundColor;

  const SafeAvatar({
    Key? key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackWidget,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<SafeAvatar> createState() => _SafeAvatarState();
}

class _SafeAvatarState extends State<SafeAvatar> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // If no image URL or had previous error, display fallback immediately
    if (widget.imageUrl == null || 
        widget.imageUrl!.isEmpty || 
        !isValidImageUrl(widget.imageUrl) || 
        _hasError) {
      return _buildFallbackAvatar();
    }

    // For valid URLs, use a fallback mechanism with error handling
    return _buildAvatarWithErrorHandling();
  }

  Widget _buildFallbackAvatar() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? Colors.grey.shade200,
      child: widget.fallbackWidget ?? Icon(
        Icons.person, 
        size: widget.radius * 0.8,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildAvatarWithErrorHandling() {
    return Stack(
      children: [
        // Base fallback avatar (will show if image fails)
        _buildFallbackAvatar(),
        
        // Attempt to load the image on top with error handling
        ClipOval(
          child: SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: Image.network(
              widget.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // On error, mark as error and return empty widget
                if (!_hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _hasError = true;
                      });
                    }
                  });
                }
                // Return empty, base avatar will show through
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Static convenience method for checking URL validity
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      // Additional validation: make sure it's http/https
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
} 