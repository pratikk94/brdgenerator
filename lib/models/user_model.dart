import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserModel {
  final String uid;
  final String? displayName;
  final String email;
  final String? photoURL;
  final bool isAdmin;
  final DateTime lastLogin;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.uid,
    this.displayName,
    required this.email,
    this.photoURL,
    this.isAdmin = false,
    required this.lastLogin,
    this.preferences,
  });

  // Create from Firebase Auth user
  factory UserModel.fromFirebaseUser(auth.User user, {bool isAdmin = false}) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email ?? '',
      photoURL: user.photoURL,
      isAdmin: isAdmin,
      lastLogin: DateTime.now(),
    );
  }

  // Create from JSON/Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : DateTime.now(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  // Convert to JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'isAdmin': isAdmin,
      'lastLogin': lastLogin.toIso8601String(),
      'preferences': preferences,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isAdmin,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      isAdmin: isAdmin ?? this.isAdmin,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }
} 