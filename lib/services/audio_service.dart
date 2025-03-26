import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:typed_data';

class AudioService {
  final Record _audioRecorder = Record();
  String? _currentRecordingPath;
  bool _isRecording = false;
  final String apiKey;

  AudioService({required this.apiKey});

  bool get isRecording => _isRecording;

  Future<bool> checkPermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    return hasPermission;
  }

  Future<String?> startRecording(String sectionName) async {
    if (!await checkPermission()) {
      throw Exception('Microphone permission not granted');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedSectionName = sectionName.replaceAll(RegExp(r'[^\w\s]+'), '_');
      _currentRecordingPath = '${directory.path}/audio_${sanitizedSectionName}_$timestamp.m4a';

      await _audioRecorder.start(
        path: _currentRecordingPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
      
      _isRecording = true;
      return _currentRecordingPath;
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      await _audioRecorder.stop();
      _isRecording = false;
      return _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<String?> transcribeAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file does not exist: $audioPath');
      }

      final fileBytes = await file.readAsBytes();
      final uri = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
      
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $apiKey',
        })
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: 'audio.m4a',
          contentType: MediaType('audio', 'm4a'),
        ))
        ..fields['model'] = 'whisper-1';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text'];
      } else {
        print('Error transcribing audio: ${response.statusCode} $responseBody');
        return null;
      }
    } catch (e) {
      print('Error transcribing audio: $e');
      return null;
    }
  }

  Future<String?> summarizeTranscription(String transcription, String sectionName) async {
    try {
      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that summarizes audio transcriptions for a Business Requirements Document (BRD). Extract the key information and format it concisely.'
            },
            {
              'role': 'user',
              'content': 'This is a transcription of audio for the "$sectionName" section of a BRD. Please summarize the key points in bullet format, extracting the most important information: $transcription'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Error summarizing transcription: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error summarizing transcription: $e');
      return null;
    }
  }

  // Helper function to show recording dialog with animation
  static Future<String?> showRecordingDialog(
    BuildContext context, 
    AudioService audioService,
    String sectionName
  ) async {
    String? recordingPath;
    String? transcription;
    String? summary;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Recording for $sectionName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (audioService.isRecording)
                    _buildRecordingAnimation()
                  else if (transcription != null)
                    Column(
                      children: [
                        Text('Transcription:'),
                        SizedBox(height: 8),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(8),
                            child: Text(transcription!),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (summary != null) ...[
                          Text('Summary:'),
                          SizedBox(height: 8),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(8),
                              child: Text(summary!),
                            ),
                          ),
                        ] else
                          CircularProgressIndicator(),
                      ],
                    )
                  else
                    Text('Tap the microphone to start recording'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (audioService.isRecording) {
                      audioService.stopRecording();
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                if (!audioService.isRecording && transcription == null)
                  ElevatedButton(
                    onPressed: () async {
                      recordingPath = await audioService.startRecording(sectionName);
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                if (audioService.isRecording)
                  ElevatedButton(
                    onPressed: () async {
                      recordingPath = await audioService.stopRecording();
                      setState(() {});
                      
                      if (recordingPath != null) {
                        // Show progress indicator
                        setState(() {
                          transcription = "Transcribing...";
                        });
                        
                        // Transcribe audio
                        final result = await audioService.transcribeAudio(recordingPath!);
                        if (result != null) {
                          transcription = result;
                          setState(() {});
                          
                          // Generate summary
                          final summ = await audioService.summarizeTranscription(
                            transcription!, 
                            sectionName
                          );
                          summary = summ;
                          setState(() {});
                        } else {
                          transcription = "Failed to transcribe audio.";
                          setState(() {});
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                    ),
                    child: Icon(Icons.stop, color: Colors.white),
                  ),
                if (transcription != null && summary != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop('done');
                    },
                    child: Text('Use Summary'),
                  ),
              ],
            );
          },
        );
      },
    );
    
    if (recordingPath != null && transcription != null && summary != null) {
      return recordingPath;
    }
    return null;
  }
  
  static Widget _buildRecordingAnimation() {
    return Container(
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<double>(
              stream: Stream.periodic(Duration(milliseconds: 100)).map((_) => 
                  0.5 + 0.5 * DateTime.now().millisecondsSinceEpoch % 1000 / 1000),
              builder: (context, snapshot) {
                final scale = snapshot.data ?? 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
            SizedBox(height: 16),
            Text(
              'Recording...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 