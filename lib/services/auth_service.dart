import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './firebase_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/google_signin_fix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  
  // Firebase service for user data management
  final FirebaseService _firebaseService = FirebaseService();
  
  // Current user stream
  Stream<User?> get user => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firebaseService.isUserAdmin(user.uid);
    }
    return false;
  }
  
  // Helper method to interpret PlatformException error codes
  String interpretPlatformException(PlatformException e) {
    if (e.code == 'sign_in_failed') {
      // Check if this is error 10 (DEVELOPER_ERROR)
      if (e.message?.contains('10:') == true) {
        return 'Developer error: Your SHA-1 certificate fingerprint is not correctly configured in the Firebase Console. Please check your Firebase configuration.';
      } else if (e.message?.contains('12501') == true) {
        return 'Sign-in was canceled by user.';
      } else if (e.message?.contains('network_error') == true) {
        return 'Network error. Please check your internet connection.';
      }
    }
    return 'Sign-in failed: ${e.message ?? e.code}';
  }
  
  // Sign in with Google - using the helper class
  Future<User?> signInWithGoogle() async {
    try {
      // Clear any existing sessions first
      await _clearAllCaches();
      
      // Use our more reliable helper class
      final UserCredential? userCredential = await GoogleSignInFix.signInWithGoogle();
      
      // If sign-in was successful
      if (userCredential != null && userCredential.user != null) {
        final User user = userCredential.user!;
        
        // Save user info to Firebase
        await _firebaseService.saveUserInfo(user.uid, {
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        print('Successfully signed in: ${user.displayName}');
        return user;
      }
      
      return null;
    } catch (e) {
      print('Error in AuthService.signInWithGoogle: $e');
      return null;
    }
  }
  
  // Clean login attempt - use this for a fresh authentication attempt
  Future<User?> cleanSignInWithEmailPassword(String email, String password) async {
    try {
      // Clear all caches and tokens first
      await _clearAllCaches();
      
      // Get a fresh App Check token
      await _refreshAppCheckToken();
      
      // Now try signing in
      return await signInWithEmailPassword(email, password);
    } catch (e) {
      print('Clean sign-in attempt failed: $e');
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      // Make sure to use the proper configuration for email/password authentication
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        // Update last login timestamp
        await _firebaseService.saveUserInfo(user.uid, {
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        print('Successfully signed in with email: ${user.email}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign-in';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many attempts. Please try again later';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.code.contains('recaptcha') || e.code.contains('captcha')) {
        // Handle reCAPTCHA verification errors more specifically
        errorMessage = 'Security verification failed. Please try again';
        print('reCAPTCHA issue: ${e.code} - ${e.message}');
        
        // Clear cached reCAPTCHA tokens and try to force refresh
        await _clearReCaptchaCache();
      } else if (e.message?.contains('invalid-image-data') == true || e.message?.contains('invalid image data') == true) {
        // Handle the "invalid image data" error
        errorMessage = 'App verification error. Please restart the app and try again';
        print('Invalid image data error: ${e.code} - ${e.message}');
        await _clearAllCaches();
      }
      
      print('Error signing in with email/password: $errorMessage (${e.code})');
      throw errorMessage;
    } catch (e) {
      print('Error signing in with email/password: $e');
      
      // Check if it's the "invalid image data" error
      if (e.toString().contains('invalid-image-data') || 
          e.toString().contains('invalid image data')) {
        await _clearAllCaches();
        throw 'App verification error. Please restart the app and try again';
      }
      
      throw 'Failed to sign in. Please try again.';
    }
  }
  
  // Helper method to refresh the App Check token
  Future<void> _refreshAppCheckToken() async {
    try {
      // Try to get a token, but don't fail if it's not available
      try {
        await FirebaseAppCheck.instance.getToken();
      } catch (e) {
        // Log but continue if App Check is not available
        print('Warning: App Check token refresh failed (expected in some environments): $e');
      }
    } catch (e) {
      print('Error refreshing App Check token: $e');
    }
  }
  
  // Helper method to clear all caches before authentication
  Future<void> _clearAllCaches() async {
    try {
      // Clear reCAPTCHA cache
      await _clearReCaptchaCache();
      
      // Sign out from any existing auth sessions
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignore errors during sign out
        print('Error signing out Google during cache clearing: $e');
      }
      
      try {
        await _auth.signOut();
      } catch (e) {
        // Ignore errors during sign out
        print('Error signing out Firebase during cache clearing: $e');
      }
      
      // Get a fresh App Check token if available
      try {
        await FirebaseAppCheck.instance.getToken();
      } catch (e) {
        // Log but continue if App Check is not available
        print('Warning: App Check token refresh failed (expected in some environments): $e');
      }
    } catch (e) {
      print('Error clearing caches: $e');
    }
  }
  
  // Helper method to clear reCAPTCHA cache
  Future<void> _clearReCaptchaCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear Firebase cached reCAPTCHA tokens
      final captchaKeys = prefs.getKeys()
          .where((key) => key.contains('recaptcha') || 
                         key.contains('captcha') ||
                         key.contains('token') ||
                         key.contains('image'))
          .toList();
      
      for (final key in captchaKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing reCAPTCHA cache: $e');
    }
  }
  
  // Register with email and password
  Future<User?> registerWithEmailPassword(String email, String password, String displayName) async {
    try {
      // Clear caches for a clean registration attempt
      await _clearAllCaches();
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        // Update profile with display name
        await user.updateDisplayName(displayName);
        
        // Save user info to Firebase
        await _firebaseService.saveUserInfo(user.uid, {
          'displayName': displayName,
          'email': email,
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        print('Successfully registered: $displayName');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      
      if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists with this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Email/password accounts are not enabled';
      } else if (e.code.contains('recaptcha') || e.code.contains('captcha')) {
        errorMessage = 'Security verification failed. Please try again';
        await _clearReCaptchaCache();
      } else if (e.message?.contains('invalid-image-data') == true || e.message?.contains('invalid image data') == true) {
        errorMessage = 'App verification error. Please restart the app and try again';
        await _clearAllCaches();
      }
      
      print('Error registering with email/password: $errorMessage');
      throw errorMessage;
    } catch (e) {
      print('Error registering with email/password: $e');
      throw 'Registration failed. Please try again.';
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send password reset email';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }
      
      print('Error resetting password: $errorMessage');
      throw errorMessage;
    } catch (e) {
      print('Error resetting password: $e');
      throw 'Failed to send reset email. Please try again.';
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
  
  // Create a test account for demonstration purposes
  Future<void> createTestAccount() async {
    const String testEmail = 'test@example.com';
    const String testPassword = 'test123456';
    const String testName = 'Test User';
    
    try {
      // Check if the test account already exists
      try {
        await _auth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        // If successful, the account exists, sign out and return
        await _auth.signOut();
        print('Test account already exists');
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'user-not-found') {
          // If error is not "user not found", something else is wrong
          print('Unexpected error checking for test account: ${e.code}');
          return;
        }
        // If user not found, continue to create the account
      }
      
      // Create the test account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        // Update profile with display name
        await user.updateDisplayName(testName);
        
        // Save user info to Firebase
        await _firebaseService.saveUserInfo(user.uid, {
          'displayName': testName,
          'email': testEmail,
          'isAdmin': true, // Make test user an admin
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        // Sign out after creating the account
        await _auth.signOut();
        
        print('Test account created successfully');
      }
    } catch (e) {
      print('Error creating test account: $e');
    }
  }
} 