import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/brd_model.dart';

class StorageService {
  static const String _documentsKey = 'brd_documents';
  
  Future<List<BRDDocument>> getBRDDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getStringList(_documentsKey) ?? [];
    
    return documentsJson
        .map((json) => BRDDocument.fromJson(jsonDecode(json)))
        .toList();
  }
  
  Future<void> saveBRDDocument(BRDDocument document) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getStringList(_documentsKey) ?? [];
    
    documentsJson.add(jsonEncode(document.toJson()));
    await prefs.setStringList(_documentsKey, documentsJson);
    
    // Also save as a markdown file
    await _saveBRDToFile(document);
  }
  
  Future<void> deleteBRDDocument(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getStringList(_documentsKey) ?? [];
    final documents = documentsJson
        .map((json) => BRDDocument.fromJson(jsonDecode(json)))
        .toList();
    
    documents.removeWhere((doc) => doc.title == title);
    
    final updatedJsonList = documents
        .map((doc) => jsonEncode(doc.toJson()))
        .toList();
    
    await prefs.setStringList(_documentsKey, updatedJsonList);
    
    // Delete the file as well
    await _deleteBRDFile(title);
  }
  
  Future<String> _getBRDDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final brdDir = Directory('${directory.path}/brd_documents');
    
    if (!await brdDir.exists()) {
      await brdDir.create(recursive: true);
    }
    
    return brdDir.path;
  }
  
  Future<void> _saveBRDToFile(BRDDocument document) async {
    final dirPath = await _getBRDDirectory();
    final fileName = '${document.title.replaceAll(' ', '_')}.md';
    final file = File('$dirPath/$fileName');
    
    await file.writeAsString(document.content);
  }
  
  Future<void> _deleteBRDFile(String title) async {
    final dirPath = await _getBRDDirectory();
    final fileName = '${title.replaceAll(' ', '_')}.md';
    final file = File('$dirPath/$fileName');
    
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  Future<String?> getBRDFilePath(String title) async {
    final dirPath = await _getBRDDirectory();
    final fileName = '${title.replaceAll(' ', '_')}.md';
    final file = File('$dirPath/$fileName');
    
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }
} 