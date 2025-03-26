import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Helper class to properly initialize Firebase with clean state
class FirebaseConfigHelper {
  /// Initialize Firebase with proper configuration
  static Future<void> initializeFirebase() async {
    try {
      // Clear any cached Firebase data
      await _clearFirebaseCache();
      
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Initialize Firebase App Check with just the debug provider
      // This ensures it will work in all environments for now
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        print('Firebase App Check initialized successfully');
      } catch (e) {
        // If App Check fails, log but continue - it's not critical for auth to work
        print('Warning: Firebase App Check activation failed: $e');
        print('App will continue without App Check verification');
      }
      
      print('Firebase initialized successfully');
    } catch (e) {
      if (e.toString().contains('already exists')) {
        // Firebase already initialized, log but continue
        print('Firebase already initialized (expected)');
      } else {
        // Rethrow other errors
        print('Error initializing Firebase: $e');
        rethrow;
      }
    }
  }
  
  /// Clear Firebase cache to avoid configuration conflicts
  static Future<void> _clearFirebaseCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear Firebase cached data
      final firebaseKeys = prefs.getKeys()
          .where((key) => key.startsWith('firebase') || 
                          key.startsWith('google') ||
                          key.contains('oauth') ||
                          key.contains('recaptcha'))
          .toList();
      
      for (final key in firebaseKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing Firebase cache: $e');
      // Continue execution, this is just for cleaning
    }
  }
} 