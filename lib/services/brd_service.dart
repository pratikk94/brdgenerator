import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/brd_component.dart';

class BRDService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's BRD collection reference
  CollectionReference<Map<String, dynamic>> _getBRDCollection() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('brds');
  }

  // Create a new BRD document with initial components
  Future<String> createNewBRD() async {
    final brdRef = await _getBRDCollection().add({
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    // Initialize default components
    final components = [
      {'id': 'cover', 'title': 'Cover Page', 'content': ''},
      {'id': 'executive', 'title': 'Executive Summary', 'content': ''},
      {'id': 'problem', 'title': 'Business Objectives', 'content': ''},
      {'id': 'proposed', 'title': 'Functional Requirements', 'content': ''},
      {'id': 'scope', 'title': 'Project Scope', 'content': ''},
      {'id': 'requirements', 'title': 'Non-Functional Requirements', 'content': ''},
      {'id': 'constraints', 'title': 'Assumptions & Constraints', 'content': ''},
      {'id': 'timeline', 'title': 'Timeline & Milestones', 'content': ''},
      {'id': 'resources', 'title': 'Stakeholder Analysis', 'content': ''},
      {'id': 'risks', 'title': 'Risk Analysis', 'content': ''},
      {'id': 'glossary', 'title': 'Glossary / Appendix', 'content': ''},
      {'id': 'signoff', 'title': 'Sign-Off', 'content': ''},
    ];

    // Create a batch write
    final batch = _firestore.batch();
    for (final component in components) {
      final componentRef = brdRef.collection('components').doc(component['id'] as String);
      batch.set(componentRef, {
        ...component,
        'isCompleted': false,
        'lastModified': Timestamp.now(),
      });
    }
    await batch.commit();

    return brdRef.id;
  }

  // Get all BRDs for the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getBRDs() {
    return _getBRDCollection()
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Get all components for a specific BRD
  Stream<List<BRDComponent>> getBRDComponents(String brdId) {
    return _getBRDCollection()
        .doc(brdId)
        .collection('components')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BRDComponent.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Update a specific component
  Future<void> updateComponent(String brdId, BRDComponent component) async {
    await _getBRDCollection()
        .doc(brdId)
        .collection('components')
        .doc(component.id)
        .update(component.toMap());

    // Update the BRD's updatedAt timestamp
    await _getBRDCollection().doc(brdId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  // Update a component directly with values
  Future<void> updateComponentDirect(
    String brdId, 
    String componentId, 
    String title, 
    String content, 
    bool isCompleted
  ) async {
    await _getBRDCollection()
        .doc(brdId)
        .collection('components')
        .doc(componentId)
        .update({
          'id': componentId,
          'title': title,
          'content': content,
          'isCompleted': isCompleted,
          'lastModified': Timestamp.now(),
        });

    // Update the BRD's updatedAt timestamp
    await _getBRDCollection().doc(brdId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  // Delete a BRD and all its components
  Future<void> deleteBRD(String brdId) async {
    // Get all components
    final componentsSnapshot = await _getBRDCollection()
        .doc(brdId)
        .collection('components')
        .get();

    // Create a batch write
    final batch = _firestore.batch();
    
    // Delete all components
    for (final doc in componentsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the BRD document
    batch.delete(_getBRDCollection().doc(brdId));
    
    // Commit the batch
    await batch.commit();
  }
} 