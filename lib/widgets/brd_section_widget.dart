import 'package:flutter/material.dart';
import '../models/brd_section_model.dart';

class BRDSectionWidget extends StatefulWidget {
  final BRDSection section;
  final Function(Map<String, dynamic>) onSave;

  const BRDSectionWidget({
    Key? key,
    required this.section,
    required this.onSave,
  }) : super(key: key);

  @override
  _BRDSectionWidgetState createState() => _BRDSectionWidgetState();
}

class _BRDSectionWidgetState extends State<BRDSectionWidget> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers() {
    switch (widget.section.type) {
      case BRDSectionType.coverPage:
        _controllers['projectName'] = TextEditingController();
        _controllers['companyName'] = TextEditingController();
        _controllers['preparedBy'] = TextEditingController();
        _controllers['version'] = TextEditingController();
        _controllers['date'] = TextEditingController();
        break;
      case BRDSectionType.executiveSummary:
        _controllers['context'] = TextEditingController();
        _controllers['problem'] = TextEditingController();
        _controllers['purpose'] = TextEditingController();
        break;
      case BRDSectionType.businessObjectives:
        _controllers['goals'] = TextEditingController();
        _controllers['kpis'] = TextEditingController();
        _controllers['success_criteria'] = TextEditingController();
        break;
      case BRDSectionType.scope:
        _controllers['in_scope'] = TextEditingController();
        _controllers['out_scope'] = TextEditingController();
        break;
      case BRDSectionType.stakeholders:
        _controllers['internal'] = TextEditingController();
        _controllers['roles'] = TextEditingController();
        break;
      case BRDSectionType.functionalRequirements:
        _controllers['features'] = TextEditingController();
        _controllers['user_stories'] = TextEditingController();
        _controllers['acceptance_criteria'] = TextEditingController();
        break;
      case BRDSectionType.nonFunctionalRequirements:
        _controllers['performance'] = TextEditingController();
        _controllers['security'] = TextEditingController();
        _controllers['usability'] = TextEditingController();
        _controllers['scalability'] = TextEditingController();
        break;
      case BRDSectionType.assumptionsConstraints:
        _controllers['assumptions'] = TextEditingController();
        _controllers['constraints'] = TextEditingController();
        break;
      case BRDSectionType.riskAnalysis:
        _controllers['risks'] = TextEditingController();
        _controllers['impact'] = TextEditingController();
        _controllers['mitigation'] = TextEditingController();
        break;
      case BRDSectionType.timeline:
        _controllers['phases'] = TextEditingController();
        _controllers['milestones'] = TextEditingController();
        _controllers['deliverables'] = TextEditingController();
        break;
      case BRDSectionType.glossary:
        _controllers['terms'] = TextEditingController();
        _controllers['definitions'] = TextEditingController();
        break;
      case BRDSectionType.signOff:
        _controllers['approvers'] = TextEditingController();
        break;
    }

    // Initialize controllers with existing data
    if (widget.section.data.isNotEmpty) {
      widget.section.data.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toString();
        }
      });
    }
  }

  Widget _buildSectionContent() {
    final fields = <Widget>[];

    _controllers.forEach((key, controller) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: key.split('_').map((word) => 
                word[0].toUpperCase() + word.substring(1)
              ).join(' '),
              border: const OutlineInputBorder(),
            ),
            maxLines: null,
            enabled: _isEditing,
          ),
        ),
      );
    });

    if (widget.section.data['generated_content'] != null) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            widget.section.data['generated_content'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(children: fields);
  }

  void _handleSave() {
    final data = <String, dynamic>{};
    _controllers.forEach((key, controller) {
      data[key] = controller.text;
    });
    widget.onSave(data);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(widget.section.title),
            if (widget.section.isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (widget.section.isComplete)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
              ),
          ],
        ),
        subtitle: Text(widget.section.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionContent(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                          if (!_isEditing) {
                            // Reset controllers to last saved values
                            widget.section.data.forEach((key, value) {
                              if (_controllers.containsKey(key)) {
                                _controllers[key]!.text = value.toString();
                              }
                            });
                          }
                        });
                      },
                      child: Text(_isEditing ? 'Cancel' : 'Edit'),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleSave,
                        child: const Text('Save & Generate'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 