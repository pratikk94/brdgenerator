import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Helper class to make Google Sign-In more reliable
class GoogleSignInFix {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  
  /// Attempt direct Google Sign-In, handling common errors
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Clean up existing sign-in states first
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      
      // 2. Start Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Sign-in canceled by user");
        return null;
      }
      
      // 3. Get auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 4. Create and return credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on PlatformException catch (e) {
      print('Platform Exception during Google Sign-In: $e');
      return null;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }
} 