import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../services/brd_generator_service.dart';
import '../services/auth_service.dart';
import '../widgets/loading_indicator.dart';

class BRDUploadScreen extends StatefulWidget {
  const BRDUploadScreen({Key? key}) : super(key: key);

  @override
  _BRDUploadScreenState createState() => _BRDUploadScreenState();
}

class _BRDUploadScreenState extends State<BRDUploadScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final BRDGeneratorService _generatorService = BRDGeneratorService();
  final AuthService _authService = AuthService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  
  File? _selectedFile;
  String? _fileContent;
  String? _filePreview;
  bool _isLargeDocument = false;
  int _wordCount = 0;
  double _processingProgress = 0.0;
  bool _isLoading = false;
  bool _isProcessing = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    super.dispose();
  }
  
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'doc', 'docx', 'pdf'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _isLoading = true;
          _fileContent = null;
          _filePreview = null;
          _isLargeDocument = false;
          _wordCount = 0;
        });
        
        // If it's a text file, read its content
        if (result.files.single.path!.endsWith('.txt') || 
            result.files.single.path!.endsWith('.md')) {
          final content = await _selectedFile!.readAsString();
          
          // Count words
          final words = content.split(RegExp(r'\s+'));
          final filteredWords = words.where((word) => word.trim().isNotEmpty).toList();
          final wordCount = filteredWords.length;
          
          // Check if it's a large document
          final isLargeDoc = wordCount > 5000; // Consider large if over 5000 words
          
          // For preview, only show first 1000 words
          final previewWords = filteredWords.take(1000).join(' ');
          final previewText = isLargeDoc 
              ? '$previewWords\n\n[... ${wordCount - 1000} more words ...]'
              : content;
          
          setState(() {
            _fileContent = content;
            _filePreview = previewText;
            _isLargeDocument = isLargeDoc;
            _wordCount = wordCount;
            _isLoading = false;
          });
        } else {
          // For non-text files, set content to null
          setState(() {
            _fileContent = null;
            _filePreview = 'Content preview not available for this file type.';
            _isLoading = false;
          });
        }
        
        // Extract filename without extension as title suggestion
        final fileName = result.files.single.name;
        final fileNameWithoutExt = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;
        
        _titleController.text = fileNameWithoutExt;
      }
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }
  
  // Process large document in chunks
  Future<Map<String, dynamic>> _processLargeDocument(String content) async {
    final int chunkSize = 5000; // Process 5000 words at a time
    final List<String> words = content.split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    
    final int totalChunks = (words.length / chunkSize).ceil();
    List<Map<String, dynamic>> chunkResults = [];
    
    for (int i = 0; i < totalChunks; i++) {
      setState(() {
        _processingProgress = (i / totalChunks);
      });
      
      final int start = i * chunkSize;
      final int end = (start + chunkSize < words.length) ? start + chunkSize : words.length;
      final String chunkText = words.sublist(start, end).join(' ');
      
      // Process this chunk
      try {
        final chunkResult = await _generatorService.generateEstimatesFromText(chunkText);
        chunkResults.add(chunkResult);
      } catch (e) {
        print('Error processing chunk $i: $e');
        // Continue with other chunks even if one fails
      }
    }
    
    // Combine results from all chunks
    return _combineChunkResults(chunkResults);
  }
  
  // Combine results from multiple chunks
  Map<String, dynamic> _combineChunkResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return {
        'error': 'Failed to process any chunks of the document',
        'timelineTotal': 12,
        'costTotal': 20000,
        'maintenanceCost': 500,
      };
    }
    
    // For numeric values, take the average
    double timelineTotal = 0;
    double costTotal = 0;
    double maintenanceCost = 0;
    double estimatedHours = 0;
    double suggestedRate = 0;
    
    // For categorical values, take the most common
    Map<String, int> riskFactorCounts = {};
    Map<String, int> complexityLevelCounts = {};
    Map<String, int> skillsRequired = {};
    
    // For breakdowns, combine them
    Map<String, double> timelineBreakdown = {};
    Map<String, double> costBreakdown = {};
    
    for (var result in results) {
      // Add numeric values
      timelineTotal += (result['timelineTotal'] as num?)?.toDouble() ?? 0;
      costTotal += (result['costTotal'] as num?)?.toDouble() ?? 0;
      maintenanceCost += (result['maintenanceCost'] as num?)?.toDouble() ?? 0;
      estimatedHours += (result['estimatedHours'] as num?)?.toDouble() ?? 0;
      suggestedRate += (result['suggestedRate'] as num?)?.toDouble() ?? 0;
      
      // Count categorical values
      final risk = result['riskFactor'] as String? ?? 'Medium';
      riskFactorCounts[risk] = (riskFactorCounts[risk] ?? 0) + 1;
      
      final complexity = result['complexityLevel'] as String? ?? 'Medium';
      complexityLevelCounts[complexity] = (complexityLevelCounts[complexity] ?? 0) + 1;
      
      // Combine skills
      final skills = result['skillsRequired'] as List<dynamic>? ?? [];
      for (var skill in skills) {
        skillsRequired[skill.toString()] = (skillsRequired[skill.toString()] ?? 0) + 1;
      }
      
      // Combine timeline breakdown
      if (result.containsKey('timelineBreakdown')) {
        (result['timelineBreakdown'] as Map<String, dynamic>).forEach((phase, weeks) {
          timelineBreakdown[phase] = (timelineBreakdown[phase] ?? 0) + (weeks as num).toDouble();
        });
      }
      
      // Combine cost breakdown
      if (result.containsKey('costBreakdown')) {
        (result['costBreakdown'] as Map<String, dynamic>).forEach((category, cost) {
          costBreakdown[category] = (costBreakdown[category] ?? 0) + (cost as num).toDouble();
        });
      }
    }
    
    // Calculate averages
    final count = results.length;
    timelineTotal /= count;
    costTotal /= count;
    maintenanceCost /= count;
    estimatedHours /= count;
    suggestedRate /= count;
    
    // Find most common categorical values
    String riskFactor = 'Medium';
    int maxRiskCount = 0;
    riskFactorCounts.forEach((risk, count) {
      if (count > maxRiskCount) {
        riskFactor = risk;
        maxRiskCount = count;
      }
    });
    
    String complexityLevel = 'Medium';
    int maxComplexityCount = 0;
    complexityLevelCounts.forEach((complexity, count) {
      if (count > maxComplexityCount) {
        complexityLevel = complexity;
        maxComplexityCount = count;
      }
    });
    
    // Convert skills to sorted list (most frequent first)
    var sortedEntries = skillsRequired.entries.toList();
    sortedEntries.sort((a, b) => b.value.compareTo(a.value));
    List<String> topSkills = sortedEntries
        .take(10) // Take top 10 skills
        .map((e) => e.key)
        .toList();
    
    // Normalize breakdowns
    timelineBreakdown.forEach((phase, weeks) {
      timelineBreakdown[phase] = weeks / count;
    });
    
    costBreakdown.forEach((category, cost) {
      costBreakdown[category] = cost / count;
    });
    
    // Return combined result
    return {
      'timelineTotal': timelineTotal.round(),
      'costTotal': costTotal.round(),
      'maintenanceCost': maintenanceCost.round(),
      'estimatedHours': estimatedHours.round(),
      'suggestedRate': suggestedRate.round(),
      'riskFactor': riskFactor,
      'complexityLevel': complexityLevel,
      'skillsRequired': topSkills,
      'timelineBreakdown': timelineBreakdown,
      'costBreakdown': costBreakdown,
    };
  }
  
  Future<void> _processAndUploadBRD() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _processingProgress = 0.0;
    });
    
    try {
      // Create a BRD data object
      final brdData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'industry': _industryController.text,
        'fileName': _selectedFile!.path.split('/').last,
        'fileSize': _selectedFile!.lengthSync(),
        'wordCount': _wordCount,
        'isLargeDocument': _isLargeDocument,
        'content': _fileContent ?? 'Content not available in text format',
        'uploadedBy': _authService.currentUser?.uid ?? 'anonymous',
        'uploadedByName': _authService.currentUser?.displayName ?? 'Anonymous',
      };
      
      // If text content is available, generate estimates from it
      if (_fileContent != null && _fileContent!.isNotEmpty) {
        try {
          // Handle large documents differently
          Map<String, dynamic> estimates;
          if (_isLargeDocument) {
            // Process large document in chunks
            estimates = await _processLargeDocument(_fileContent!);
          } else {
            // Process normally for smaller documents
            estimates = await _generatorService.generateEstimatesFromText(_fileContent!);
          }
          
          brdData['estimates'] = estimates;
          
          setState(() {
            _processingProgress = 0.5; // 50% complete after estimates
          });
          
          // Extract potential execution steps, risks, and earnings projections
          // For large documents, use a summarized version or first chunk
          String contentForAnalysis = _isLargeDocument ? 
              _fileContent!.split(RegExp(r'\s+')).take(5000).join(' ') : 
              _fileContent!;
              
          brdData['executionSteps'] = await _generatorService.extractExecutionStepsFromText(contentForAnalysis);
          
          setState(() {
            _processingProgress = 0.7; // 70% complete
          });
          
          brdData['riskAssessment'] = await _generatorService.extractRisksFromText(contentForAnalysis);
          
          setState(() {
            _processingProgress = 0.9; // 90% complete
          });
          
          brdData['earningsProjection'] = await _generatorService.generateSimpleEarningsProjection(estimates);
        } catch (e) {
          print('Error generating estimates: $e');
          // Use default values if estimation fails
          brdData['estimates'] = {
            'timelineTotal': 12,
            'costTotal': 10000,
            'maintenanceCost': 500,
          };
        }
      }
      
      // Save to Firebase
      final brdId = await _firebaseService.saveBRDDocument(brdData);
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingProgress = 1.0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('BRD uploaded successfully and pending approval'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/brd_approvals');
              },
            ),
          ),
        );
        
        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _industryController.clear();
        setState(() {
          _selectedFile = null;
          _fileContent = null;
          _filePreview = null;
          _isLargeDocument = false;
          _wordCount = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingProgress = 0.0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading BRD: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload BRD'),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(message: 'Processing and uploading BRD...'),
                  SizedBox(height: 16),
                  if (_isLargeDocument) ...[
                    Text(
                      'Processing large document (${_wordCount} words)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 300,
                      child: LinearProgressIndicator(
                        value: _processingProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(_processingProgress * 100).toStringAsFixed(0)}% complete',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload an existing BRD document to get estimates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // File upload area
                  InkWell(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedFile != null 
                                      ? Icons.check_circle 
                                      : Icons.cloud_upload,
                                  size: 48,
                                  color: _selectedFile != null 
                                      ? Colors.green 
                                      : Colors.indigo,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFile != null
                                      ? 'File selected: ${_selectedFile!.path.split('/').last}'
                                      : 'Click to select a BRD file',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                if (_selectedFile != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (_wordCount > 0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_wordCount words',
                                      style: TextStyle(
                                        color: _isLargeDocument ? Colors.orange : Colors.grey[600],
                                        fontWeight: _isLargeDocument ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (_isLargeDocument) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Large document detected. Processing may take longer.',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // BRD information form
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'BRD Title*',
                      hintText: 'Enter a title for this BRD',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of this BRD',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _industryController,
                    decoration: const InputDecoration(
                      labelText: 'Industry',
                      hintText: 'e.g., Healthcare, Finance, E-commerce',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Preview of text content if available
                  if (_filePreview != null && _filePreview!.isNotEmpty) ...[
                    const Text(
                      'Document Preview:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _filePreview!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload & Get Estimates'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _selectedFile != null ? _processAndUploadBRD : null,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Note: Uploaded BRDs will need admin approval before being added to estimates.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
} 