import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './firebase_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/google_signin_fix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  
  // Firebase service for user data management
  final FirebaseService _firebaseService = FirebaseService();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isInitialized = false;
  
  AuthService() {
    // Initialize immediately with current auth state
    _isInitialized = true;
    notifyListeners();
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }
  
  // Current user stream
  Stream<User?> get user => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Check if auth is initialized
  bool get isInitialized => _isInitialized;
  
  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      if (_auth.currentUser == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();

      return userDoc.data()?['role'] == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
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
        notifyListeners();
        return user;
      }
      
      return null;
    } catch (e) {
      print('Error in AuthService.signInWithGoogle: $e');
      return null;
    }
  }
  
  // Clean sign in method that handles cache clearing
  Future<UserCredential> cleanSignInWithEmailAndPassword(String email, String password) async {
    try {
      // Clear any cached data before attempting sign in
      await _auth.signOut();
      
      // Attempt sign in with cleared cache
      return await signInWithEmailAndPassword(email, password);
    } catch (e) {
      print('Error in clean sign in: $e');
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Clear any cached data before attempting sign in
      await _clearAllCaches();
      
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _firestore.collection('users').doc(result.user?.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return result;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
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
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      notifyListeners();
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

  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth.currentUser == null) return;

      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({'displayName': displayName});
      }

      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({'photoURL': photoURL});
      }

      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    try {
      if (_auth.currentUser == null) return 'guest';

      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();

      return userDoc.data()?['role'] ?? 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }
} 