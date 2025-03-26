import 'dart:io';
import 'package:flutter/foundation.dart';

class SPenDetector {
  // List of Samsung Galaxy Note and S-series with S Pen support
  static const List<String> _sPenDeviceModels = [
    // Note series
    'SM-N9', // Covers Note series (starts with SM-N9)
    
    // S21 Ultra
    'SM-G998',
    
    // S22 Ultra
    'SM-S908',
    
    // S23 Ultra
    'SM-S918',
    
    // S24 Ultra
    'SM-S928',
    
    // Tab S series with S Pen
    'SM-T', // Most Tab S devices
  ];
  
  // Keep track of if we've checked for stylus support
  static bool _hasCheckedStylusSupport = false;
  static bool _hasStylusSupport = false;
  
  /// Checks if the current device is likely to be a Samsung device with S Pen support
  static bool isSPenSupported() {
    if (!Platform.isAndroid) {
      return false; // S Pen only supported on Android devices
    }
    
    // In a real implementation, you would use platform-specific code to check
    // for actual S Pen support. This is a simplified version.
    String deviceModel = getDeviceModel();
    return _sPenDeviceModels.any((model) => deviceModel.startsWith(model));
  }
  
  /// Gets the device model
  /// In a real implementation, this would use native code to get the actual device model
  static String getDeviceModel() {
    // This is a placeholder implementation
    // In a real app, you'd use a platform channel or package like device_info_plus
    // to get the actual device model
    
    // For testing, let's have S Pen support in debug mode only
    if (kDebugMode) {
      return 'SM-S918'; // Simulating S23 Ultra for testing
    } else {
      // In release mode, let's assume a non-S Pen device by default
      // You would replace this with actual device detection
      return 'SM-A123'; // A typical non-S Pen Samsung model
    }
  }
  
  /// Checks if the S Pen is currently detached from the device
  /// In a real implementation, this would use native code to check S Pen state
  static bool isSPenDetached() {
    // This is a placeholder implementation
    // In a real app, you'd use platform-specific code to check S Pen status
    return true; // Always assume the S Pen is detached for testing
  }
  
  /// Determines if we should show stylus features
  /// This checks both hardware support and user preferences
  static bool shouldShowStylusFeatures() {
    // If we haven't checked yet, do it now
    if (!_hasCheckedStylusSupport) {
      // Check for any kind of stylus support (S Pen or other)
      // In a real implementation, you would also check for Apple Pencil on iOS
      // and other stylus support on different platforms
      _hasStylusSupport = isSPenSupported() || _hasOtherStylusSupport();
      _hasCheckedStylusSupport = true;
    }
    
    return _hasStylusSupport;
  }
  
  /// Check for other types of stylus support besides S Pen
  static bool _hasOtherStylusSupport() {
    // In a real implementation, you would check for:
    // 1. Apple Pencil on iPads
    // 2. Windows Ink on Windows devices
    // 3. Generic stylus/pen input on other devices
    
    // For now, we'll just return false as a placeholder
    return false;
  }
} 