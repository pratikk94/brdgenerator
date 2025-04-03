import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class BRDDetailScreen extends StatefulWidget {
  const BRDDetailScreen({Key? key}) : super(key: key);

  @override
  _BRDDetailScreenState createState() => _BRDDetailScreenState();
}

class _BRDDetailScreenState extends State<BRDDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _brd;
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBRD();
  }

  Future<void> _loadBRD() async {
    try {
      final String brdId = ModalRoute.of(context)!.settings.arguments as String;
      final brd = await _firebaseService.getBRDById(brdId);
      final isAdmin = await _authService.isCurrentUserAdmin();

      if (mounted) {
        setState(() {
          _brd = brd;
          _isAdmin = isAdmin;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleApproval(String status, String? comments) async {
    if (!_isAdmin) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.updateBRDApprovalStatus(
        _brd!['id'] as String,
        status,
        comments,
      );
      await _loadBRD();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_brd?['title'] as String? ?? 'BRD Details'),
        actions: [
          if (_isAdmin && _brd != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'approve':
                    _showApprovalDialog('approve');
                    break;
                  case 'reject':
                    _showApprovalDialog('reject');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: Text('Approve BRD'),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Text('Reject BRD'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _brd == null
                  ? const Center(child: Text('BRD not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusChip(),
                          const SizedBox(height: 16),
                          _buildSection('Title', _brd!['title'] as String?),
                          _buildSection(
                              'Description', _brd!['description'] as String?),
                          _buildSection('Business Objectives',
                              _brd!['businessObjectives'] as String?),
                          _buildSection('Scope', _brd!['scope'] as String?),
                          _buildSection(
                              'Stakeholders', _brd!['stakeholders'] as String?),
                          _buildSection('Functional Requirements',
                              _brd!['functionalRequirements'] as String?),
                          _buildSection('Non-Functional Requirements',
                              _brd!['nonFunctionalRequirements'] as String?),
                          _buildSection('Assumptions and Constraints',
                              _brd!['assumptionsConstraints'] as String?),
                          _buildSection(
                              'Risk Analysis', _brd!['riskAnalysis'] as String?),
                          _buildSection('Timeline', _brd!['timeline'] as String?),
                          _buildSection('Glossary', _brd!['glossary'] as String?),
                          _buildSection('Sign-off', _brd!['signOff'] as String?),
                          if (_brd!['approvalComments'] != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Approval Comments:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(_brd!['approvalComments'] as String),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatusChip() {
    final status = _brd!['approvalStatus'] as String? ?? 'pending';
    final color = status == 'approved'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.grey);

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.shade100,
    );
  }

  Widget _buildSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }

  Future<void> _showApprovalDialog(String action) async {
    final commentsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.substring(0, 1).toUpperCase()}${action.substring(1)} BRD'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to $action this BRD?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(action.substring(0, 1).toUpperCase() + action.substring(1)),
            onPressed: () {
              Navigator.pop(context);
              _handleApproval(action, commentsController.text);
            },
          ),
        ],
      ),
    );
  }
} 