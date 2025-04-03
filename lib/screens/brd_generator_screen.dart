import 'package:flutter/material.dart';
import '../models/brd_section_model.dart';
import '../services/openai_service.dart';
import '../services/brd_validator_service.dart';
import '../widgets/brd_section_widget.dart';

class BRDGeneratorScreen extends StatefulWidget {
  const BRDGeneratorScreen({Key? key}) : super(key: key);

  @override
  _BRDGeneratorScreenState createState() => _BRDGeneratorScreenState();
}

class _BRDGeneratorScreenState extends State<BRDGeneratorScreen> {
  final OpenAIService _openAIService = OpenAIService();
  final BRDValidatorService _validatorService = BRDValidatorService();
  final List<BRDSection> _sections = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initializeSections();
  }

  void _initializeSections() {
    _sections.addAll([
      BRDSection.empty(BRDSectionType.coverPage),
      BRDSection.empty(BRDSectionType.executiveSummary),
      BRDSection.empty(BRDSectionType.businessObjectives),
      BRDSection.empty(BRDSectionType.scope),
      BRDSection.empty(BRDSectionType.stakeholders),
      BRDSection.empty(BRDSectionType.functionalRequirements),
      BRDSection.empty(BRDSectionType.nonFunctionalRequirements),
      BRDSection.empty(BRDSectionType.assumptionsConstraints),
      BRDSection.empty(BRDSectionType.riskAnalysis),
      BRDSection.empty(BRDSectionType.timeline),
      BRDSection.empty(BRDSectionType.glossary),
      BRDSection.empty(BRDSectionType.signOff),
    ]);
  }

  Future<void> _handleSectionSave(int index, Map<String, dynamic> data) async {
    setState(() => _isGenerating = true);

    try {
      final section = _sections[index];
      final validationResult = _validatorService.validateSection(section, data);

      if (!validationResult.isValid) {
        _showValidationError(validationResult.issues);
        return;
      }

      final generatedContent = await _openAIService.generateBRDSection(section, data);
      
      setState(() {
        _sections[index] = BRDSection(
          title: section.title,
          type: section.type,
          description: section.description,
          isRequired: section.isRequired,
          data: {...data, 'generated_content': generatedContent},
          isComplete: true,
        );
      });

      _showSuccessMessage('${section.title} generated successfully');
    } catch (e) {
      _showErrorMessage('Failed to generate content: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showValidationError(List<String> issues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: issues.map((issue) => Text('• $issue')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _generateCompleteBRD() async {
    final validationResult = _validatorService.validateCompleteBRD(_sections);
    
    if (!validationResult.isValid) {
      _showValidationError(validationResult.issues);
      return;
    }

    // TODO: Implement complete BRD generation and export
    _showSuccessMessage('BRD generation complete!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRD Generator'),
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                return BRDSectionWidget(
                  section: _sections[index],
                  onSave: (data) => _handleSectionSave(index, data),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _generateCompleteBRD,
        label: const Text('Generate Complete BRD'),
        icon: const Icon(Icons.description),
      ),
    );
  }
} 