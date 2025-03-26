import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKeyPref = 'openai_api_key';
  const String apiKey = 'YOUR_API_KEY_HERE'; // Use environment variable instead
  
  OpenAIService() {
    _initializeApiKey();
  }

  Future<void> _initializeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_apiKeyPref)) {
      await prefs.setString(_apiKeyPref, apiKey);
    }
  }
  
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
  }
  
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  Future<String> generateBRD(String prompt) async {
    final apiKey = await getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found. Please set your OpenAI API key first.');
    }
    
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional business analyst specializing in creating detailed Business Requirements Documents (BRD). Create a comprehensive BRD based on the user\'s input. Include sections for introduction, project overview, stakeholders, functional requirements, non-functional requirements, constraints, and timelines.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 2500,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate BRD: ${response.body}');
    }
  }
} 