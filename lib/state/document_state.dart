import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class DocumentState extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await _firebaseService.getAllBRDs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDocument(Map<String, dynamic> document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.saveBRD(document);
      await loadDocuments();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDocument(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateBRD(id, updates);
      await loadDocuments();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteBRD(id);
      await loadDocuments();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 