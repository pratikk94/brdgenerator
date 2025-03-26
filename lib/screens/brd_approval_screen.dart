import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/loading_indicator.dart';
import 'brd_result_screen.dart';

class BRDApprovalScreen extends StatefulWidget {
  const BRDApprovalScreen({Key? key}) : super(key: key);

  @override
  _BRDApprovalScreenState createState() => _BRDApprovalScreenState();
}

class _BRDApprovalScreenState extends State<BRDApprovalScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _brds = [];
  
  final TextEditingController _commentsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadBRDs();
  }
  
  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
  
  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }
  
  Future<void> _loadBRDs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final brds = await _firebaseService.getAllBRDs();
      setState(() {
        _brds = brds;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading BRDs: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading BRDs: $e')),
      );
    }
  }
  
  Future<void> _updateBRDStatus(String brdId, String status) async {
    // Show a dialog to confirm and add comments if needed
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'approved' ? 'Approve BRD' : 'Reject BRD'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status == 'approved'
                  ? 'Are you sure you want to approve this BRD?'
                  : 'Are you sure you want to reject this BRD?',
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: 'Comments (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(status == 'approved' ? 'Approve' : 'Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          final currentUser = _authService.currentUser;
          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You must be logged in to perform this action')),
            );
            return;
          }
          
          await _firebaseService.updateBRDApprovalStatus(
            brdId,
            status,
            currentUser.uid,
            _commentsController.text.isNotEmpty ? _commentsController.text : null,
          );
          
          // If approved, add to estimates
          if (status == 'approved') {
            await _firebaseService.addBRDToEstimates(brdId);
          }
          
          _commentsController.clear();
          await _loadBRDs();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('BRD ${status == 'approved' ? 'approved' : 'rejected'} successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating BRD status: $e')),
          );
        }
      }
    });
  }
  
  Future<void> _viewBRDDetails(Map<String, dynamic> brd) async {
    // Navigate to the BRD details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BRDResultScreen(
          brdContent: brd['content'] ?? 'Content not available',
          proposalContent: brd['proposalContent'] ?? 'Proposal not available',
          estimates: brd['estimates'] as Map<String, dynamic>? ?? 
              {'timelineTotal': 12, 'costTotal': 10000, 'maintenanceCost': 500},
          executionSteps: brd['executionSteps'] as Map<String, dynamic>? ?? 
              {'phases': []},
          riskAssessment: brd['riskAssessment'] as Map<String, dynamic>? ?? 
              {'risks': []},
          earningsProjection: brd['earningsProjection'] as Map<String, dynamic>? ?? 
              {'projections': {}},
        ),
      ),
    );
  }
  
  Widget _buildBRDCard(Map<String, dynamic> brd) {
    final createdAt = DateTime.parse(brd['createdAt'] as String);
    final formattedDate = DateFormat.yMMMd().add_jm().format(createdAt);
    final status = brd['approvalStatus'] as String? ?? 'pending';
    
    Color getStatusColor(String status) {
      switch (status) {
        case 'approved': return Colors.green;
        case 'rejected': return Colors.red;
        default: return Colors.orange;
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                brd['title'] as String? ?? 'Untitled BRD',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: getStatusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate),
            if (brd['reviewedAt'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Reviewed: ${DateFormat.yMMMd().format(DateTime.parse(brd['reviewedAt'] as String))}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (brd['description'] != null) ...[
                  Text(
                    brd['description'] as String,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
                
                if (brd['comments'] != null) ...[
                  Text(
                    'Comments:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(brd['comments'] as String),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                      onPressed: () {
                        _viewBRDDetails(brd);
                      },
                    ),
                    const SizedBox(width: 16),
                    if (_isAdmin && status == 'pending') ...[
                      TextButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Reject', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _updateBRDStatus(brd['id'] as String, 'rejected');
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _updateBRDStatus(brd['id'] as String, 'approved');
                        },
                      ),
                    ],
                    if (status == 'approved' && !(brd['addedToEstimates'] as bool? ?? false)) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_chart),
                        label: const Text('Add to Estimates'),
                        onPressed: () async {
                          try {
                            await _firebaseService.addBRDToEstimates(brd['id'] as String);
                            await _loadBRDs();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added to estimates successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding to estimates: $e')),
                            );
                          }
                        },
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRD Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBRDs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator(message: 'Loading BRDs...'))
          : _brds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No BRDs found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create New BRD'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/brd_form');
                        },
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _brds.length,
                  itemBuilder: (context, index) {
                    return _buildBRDCard(_brds[index]);
                  },
                ),
    );
  }
} 