import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  
  // Initialize with database URL
  FirebaseService._internal() {
    // Set the database URL explicitly
    FirebaseDatabase.instance.databaseURL = 'https://brd-generator-app-default-rtdb.firebaseio.com';
  }
  
  // Firebase Database reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // User related methods
  
  // Save user info to Firebase
  Future<void> saveUserInfo(String uid, Map<String, dynamic> userData) async {
    try {
      // Ensure user data has last login timestamp
      if (!userData.containsKey('lastLogin')) {
        userData['lastLogin'] = DateTime.now().toIso8601String();
      }
      
      await _dbRef.child('users/$uid').update(userData);
    } catch (e) {
      print('Failed to save user info to Firebase: $e');
      rethrow;
    }
  }
  
  // Get user details by user ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final snapshot = await _dbRef.child('users/$uid').get();
      
      if (snapshot.exists && snapshot.value != null) {
        // Safely convert to Map<String, dynamic>
        final dynamic rawData = snapshot.value;
        if (rawData is Map) {
          final userData = _convertToStringDynamicMap(rawData);
          userData['uid'] = uid; // Add the uid to the map
          return UserModel.fromJson(userData);
        }
      }
      
      return null;
    } catch (e) {
      print('Failed to get user data from Firebase: $e');
      return null;
    }
  }
  
  // Helper method to convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _convertToStringDynamicMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      // Handle null values
      if (value == null) {
        return MapEntry(key.toString(), null);
      }
      // Handle nested maps
      else if (value is Map) {
        return MapEntry(key.toString(), _convertToStringDynamicMap(value));
      }
      // Handle lists containing maps
      else if (value is List) {
        return MapEntry(key.toString(), _convertListItems(value));
      }
      // Handle String conversion - avoid null to String casts
      else if (value is! String && value.toString() == "null") {
        return MapEntry(key.toString(), null);
      }
      // Handle simple values
      else {
        return MapEntry(key.toString(), value);
      }
    });
  }
  
  // Helper method to process list items
  List<dynamic> _convertListItems(List<dynamic> list) {
    return list.map((item) {
      if (item == null) {
        return null;
      } else if (item is Map) {
        return _convertToStringDynamicMap(item);
      }
      return item;
    }).toList();
  }
  
  // Check if user is admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      final snapshot = await _dbRef.child('users/$uid/isAdmin').get();
      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      print('Failed to check if user is admin: $e');
      return false;
    }
  }
  
  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _dbRef.child('users').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawData = snapshot.value;
        if (rawData is Map<dynamic, dynamic>) {
          final List<UserModel> users = [];
          
          rawData.forEach((key, value) {
            if (value is Map) {
              // Convert to Map<String, dynamic>
              final userData = _convertToStringDynamicMap(value);
              userData['uid'] = key.toString(); // Add uid from the key
              try {
                users.add(UserModel.fromJson(userData));
              } catch (e) {
                print('Error converting user data: $e');
              }
            }
          });
          
          return users;
        }
      }
      
      return [];
    } catch (e) {
      print('Failed to get users from Firebase: $e');
      return [];
    }
  }
  
  // Update user preferences
  Future<void> updateUserPreferences(String uid, Map<String, dynamic> preferences) async {
    try {
      await _dbRef.child('users/$uid/preferences').update(preferences);
    } catch (e) {
      print('Failed to update user preferences: $e');
      rethrow;
    }
  }
  
  // Log user activity
  Future<void> logUserActivity(String uid, String action, Map<String, dynamic> details) async {
    try {
      final activityData = {
        'timestamp': DateTime.now().toIso8601String(),
        'action': action,
        'details': details,
      };
      
      await _dbRef.child('user_activity/$uid').push().set(activityData);
    } catch (e) {
      print('Failed to log user activity: $e');
      // Don't rethrow - this is a non-critical operation
    }
  }
  
  // Task related methods
  
  // Save task estimate to Firebase
  Future<void> saveTaskEstimate(Map<String, dynamic> estimateData) async {
    try {
      // Add timestamp
      estimateData['createdAt'] = DateTime.now().toIso8601String();
      
      // Push to 'estimates' collection with auto-generated ID
      await _dbRef.child('estimates').push().set(estimateData);
      
      // Backup to local storage
      await _backupEstimatesToLocal();
    } catch (e) {
      print('Failed to save estimate to Firebase: $e');
      
      // Fallback to local storage
      await _saveEstimateToLocal(estimateData);
      rethrow;
    }
  }
  
  // Backup all estimates to local storage
  Future<void> _backupEstimatesToLocal() async {
    try {
      final estimates = await getAllTaskEstimates();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('estimates_backup', jsonEncode(estimates));
    } catch (e) {
      print('Failed to backup estimates to local storage: $e');
    }
  }
  
  // Save estimate to local storage (fallback)
  Future<void> _saveEstimateToLocal(Map<String, dynamic> estimateData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final estimatesJson = prefs.getString('estimates_backup') ?? '[]';
      final estimates = jsonDecode(estimatesJson) as List<dynamic>;
      
      // Add new estimate
      estimates.add(estimateData);
      
      // Save back to local storage
      await prefs.setString('estimates_backup', jsonEncode(estimates));
    } catch (e) {
      print('Failed to save estimate to local storage: $e');
    }
  }
  
  // Save BRD document to Firebase with local fallback
  Future<String> saveBRDDocument(Map<String, dynamic> brdData) async {
    try {
      // Add timestamp and default approval status
      brdData['createdAt'] = DateTime.now().toIso8601String();
      brdData['approvalStatus'] = 'pending'; // pending, approved, rejected
      brdData['reviewedAt'] = null;
      brdData['reviewedBy'] = null;
      brdData['comments'] = null;
      
      // Push to 'brds' collection with auto-generated ID
      final newRef = _dbRef.child('brds').push();
      await newRef.set(brdData);
      
      // Backup to local storage
      await _backupBRDsToLocal();
      
      return newRef.key ?? '';
    } catch (e) {
      print('Failed to save BRD to Firebase: $e');
      
      // Fallback to local storage
      final localId = await _saveBRDToLocal(brdData);
      return localId;
    }
  }
  
  // Backup BRDs to local storage
  Future<void> _backupBRDsToLocal() async {
    try {
      final brds = await getAllBRDs();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('brds_backup', jsonEncode(brds));
    } catch (e) {
      print('Failed to backup BRDs to local storage: $e');
    }
  }
  
  // Save BRD to local storage (fallback)
  Future<String> _saveBRDToLocal(Map<String, dynamic> brdData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final brdsJson = prefs.getString('brds_backup') ?? '[]';
      final brds = jsonDecode(brdsJson) as List<dynamic>;
      
      // Generate a unique ID
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      brdData['id'] = localId;
      
      // Add new BRD
      brds.add(brdData);
      
      // Save back to local storage
      await prefs.setString('brds_backup', jsonEncode(brds));
      
      return localId;
    } catch (e) {
      print('Failed to save BRD to local storage: $e');
      return 'local_error';
    }
  }
  
  // Sync all local data to Firebase when connectivity is restored
  Future<void> syncLocalDataToFirebase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sync estimates
      final estimatesJson = prefs.getString('estimates_backup') ?? '[]';
      final estimates = jsonDecode(estimatesJson) as List<dynamic>;
      
      for (final estimate in estimates) {
        if (estimate['id'] != null && estimate['id'].toString().startsWith('local_')) {
          // This is a local-only estimate, sync to Firebase
          final estimateData = Map<String, dynamic>.from(estimate as Map);
          estimateData.remove('id'); // Remove local ID
          
          // Push to Firebase
          await _dbRef.child('estimates').push().set(estimateData);
        }
      }
      
      // Sync BRDs
      final brdsJson = prefs.getString('brds_backup') ?? '[]';
      final brds = jsonDecode(brdsJson) as List<dynamic>;
      
      for (final brd in brds) {
        if (brd['id'] != null && brd['id'].toString().startsWith('local_')) {
          // This is a local-only BRD, sync to Firebase
          final brdData = Map<String, dynamic>.from(brd as Map);
          brdData.remove('id'); // Remove local ID
          
          // Push to Firebase
          await _dbRef.child('brds').push().set(brdData);
        }
      }
      
      // Clear local backups after successful sync
      await prefs.remove('estimates_backup');
      await prefs.remove('brds_backup');
      
      // Re-backup from Firebase for consistency
      await _backupEstimatesToLocal();
      await _backupBRDsToLocal();
    } catch (e) {
      print('Failed to sync local data to Firebase: $e');
    }
  }
  
  // Get all BRD documents (with Firebase priority and local fallback)
  Future<List<Map<String, dynamic>>> getAllBRDs() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('brds')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting BRDs: $e');
      return [];
    }
  }
  
  // Get recent documents
  Future<List<Map<String, dynamic>>> getRecentDocuments() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('brds')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting recent documents: $e');
      return [];
    }
  }
  
  // Save new BRD
  Future<void> saveBRD(Map<String, dynamic> brd) async {
    try {
      await _firestore.collection('brds').add({
        ...brd,
        'userId': _auth.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving BRD: $e');
      throw e;
    }
  }
  
  // Update existing BRD
  Future<void> updateBRD(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('brds').doc(id).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating BRD: $e');
      throw e;
    }
  }
  
  // Delete BRD
  Future<void> deleteBRD(String id) async {
    try {
      await _firestore.collection('brds').doc(id).delete();
    } catch (e) {
      print('Error deleting BRD: $e');
      throw e;
    }
  }
  
  // Get BRD by ID
  Future<Map<String, dynamic>?> getBRDById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('brds').doc(id).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting BRD by ID: $e');
      throw e;
    }
  }
  
  // Get BRDs pending approval (admin only)
  Future<List<Map<String, dynamic>>> getPendingBRDs() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('brds')
          .where('approvalStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting pending BRDs: $e');
      return [];
    }
  }
  
  // Update BRD approval status (admin only)
  Future<void> updateBRDApprovalStatus(
      String id, String status, String? comments) async {
    try {
      await _firestore.collection('brds').doc(id).update({
        'approvalStatus': status,
        'approvalComments': comments,
        'approvedBy': _auth.currentUser?.uid,
        'approvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating BRD approval status: $e');
      throw e;
    }
  }
  
  // Get admin settings from Firebase
  Future<Map<String, dynamic>?> getAdminSettings() async {
    try {
      final snapshot = await _dbRef.child('admin/settings').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawData = snapshot.value;
        if (rawData is Map) {
          // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
          return _convertToStringDynamicMap(rawData);
        }
      }
      
      return null;
    } catch (e) {
      print('Failed to get admin settings from Firebase: $e');
      return null;
    }
  }
  
  // Save admin settings to Firebase
  Future<void> saveAdminSettings(Map<String, dynamic> settings) async {
    try {
      await _dbRef.child('admin/settings').set(settings);
    } catch (e) {
      print('Failed to save admin settings to Firebase: $e');
      rethrow;
    }
  }
  
  // Get all task estimates
  Future<List<Map<String, dynamic>>> getAllTaskEstimates() async {
    try {
      final snapshot = await _dbRef.child('estimates').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawData = snapshot.value;
        if (rawData is Map) {
          final List<Map<String, dynamic>> estimates = [];
          
          rawData.forEach((key, value) {
            if (value is Map) {
              // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
              final estimateData = _convertToStringDynamicMap(value);
              // Add the key as id
              estimateData['id'] = key.toString();
              estimates.add(estimateData);
            }
          });
          
          // Sort by created date (newest first)
          estimates.sort((a, b) {
            final dateA = a['createdAt'] != null ? DateTime.parse(a['createdAt'] as String) : DateTime.now();
            final dateB = b['createdAt'] != null ? DateTime.parse(b['createdAt'] as String) : DateTime.now();
            return dateB.compareTo(dateA);
          });
          
          return estimates;
        }
      }
      
      return [];
    } catch (e) {
      print('Failed to get estimates from Firebase: $e');
      return [];
    }
  }
  
  // Get a specific task estimate by ID
  Future<Map<String, dynamic>?> getTaskEstimateById(String estimateId) async {
    try {
      final snapshot = await _dbRef.child('estimates/$estimateId').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawData = snapshot.value;
        if (rawData is Map) {
          // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
          final estimateData = _convertToStringDynamicMap(rawData);
          estimateData['id'] = estimateId;
          return estimateData;
        }
      }
      
      return null;
    } catch (e) {
      print('Failed to get estimate from Firebase: $e');
      return null;
    }
  }
  
  // Delete a task estimate
  Future<void> deleteTaskEstimate(String estimateId) async {
    try {
      await _dbRef.child('estimates/$estimateId').remove();
    } catch (e) {
      print('Failed to delete estimate from Firebase: $e');
      rethrow;
    }
  }
  
  // Save task to Firebase
  Future<void> saveTask(String boardId, Map<String, dynamic> taskData) async {
    try {
      await _dbRef.child('boards/$boardId/tasks/${taskData['id']}').set(taskData);
    } catch (e) {
      print('Failed to save task to Firebase: $e');
      rethrow;
    }
  }
  
  // Save board to Firebase
  Future<void> saveBoard(Map<String, dynamic> boardData) async {
    try {
      await _dbRef.child('boards/${boardData['id']}').set(boardData);
    } catch (e) {
      print('Failed to save board to Firebase: $e');
      rethrow;
    }
  }
  
  // Get all boards with Firebase priority and local fallback
  Future<List<Map<String, dynamic>>> getAllBoards() async {
    try {
      // Try to get from Firebase first
      final snapshot = await _dbRef.child('boards').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawData = snapshot.value;
        if (rawData is Map) {
          final List<Map<String, dynamic>> boards = [];
          
          rawData.forEach((key, value) {
            if (value is Map) {
              // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
              final boardData = _convertToStringDynamicMap(value);
              boards.add(boardData);
            }
          });
          
          // Backup to local storage
          _backupBoardsToLocal(boards);
          
          return boards;
        }
      }
      
      // If no data in Firebase, try local storage
      return _getLocalBoards();
    } catch (e) {
      print('Failed to get boards from Firebase: $e');
      // Fallback to local storage
      return _getLocalBoards();
    }
  }
  
  // Backup boards to local storage
  Future<void> _backupBoardsToLocal(List<Map<String, dynamic>> boards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('boards_backup', jsonEncode(boards));
    } catch (e) {
      print('Failed to backup boards to local storage: $e');
    }
  }
  
  // Get boards from local storage
  Future<List<Map<String, dynamic>>> _getLocalBoards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boardsJson = prefs.getString('boards_backup') ?? '[]';
      final boards = jsonDecode(boardsJson) as List<dynamic>;
      
      return boards.map((board) => Map<String, dynamic>.from(board as Map)).toList();
    } catch (e) {
      print('Failed to get boards from local storage: $e');
      return [];
    }
  }
  
  // Backup all data from Firebase to JSON file (for future implementation)
  Future<String> backupAllData() async {
    try {
      final snapshot = await _dbRef.get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        return jsonEncode(data);
      }
      
      return jsonEncode({});
    } catch (e) {
      print('Failed to backup data from Firebase: $e');
      return jsonEncode({});
    }
  }
  
  // Method to track task changes
  Future<void> trackTaskActivity(String boardId, String taskId, String userId, String action, Map<String, dynamic> details) async {
    try {
      final activityData = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'action': action,
        'details': details,
      };
      
      await _dbRef.child('task_activity/$boardId/$taskId').push().set(activityData);
      
      // Also log to general user activity
      await logUserActivity(userId, 'task_$action', {
        'boardId': boardId,
        'taskId': taskId,
        ...details,
      });
    } catch (e) {
      print('Failed to track task activity: $e');
      // Don't rethrow - this is non-critical
    }
  }
} 