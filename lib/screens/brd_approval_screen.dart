import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class BRDApprovalScreen extends StatefulWidget {
  const BRDApprovalScreen({Key? key}) : super(key: key);

  @override
  _BRDApprovalScreenState createState() => _BRDApprovalScreenState();
}

class _BRDApprovalScreenState extends State<BRDApprovalScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _pendingBRDs = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadBRDs();
  }

  Future<void> _checkAdminAndLoadBRDs() async {
    try {
      final isAdmin = await _authService.isCurrentUserAdmin();
      if (!isAdmin) {
        setState(() {
          _errorMessage = 'You do not have permission to access this page.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isAdmin = true;
      });

      await _loadPendingBRDs();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPendingBRDs() async {
    try {
      final brds = await _firebaseService.getPendingBRDs();
      if (mounted) {
        setState(() {
          _pendingBRDs = brds;
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

  Future<void> _handleApproval(String brdId, String status) async {
    final commentsController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status.substring(0, 1).toUpperCase()}${status.substring(1)} BRD'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to $status this BRD?'),
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
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text(status.substring(0, 1).toUpperCase() + status.substring(1)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseService.updateBRDApprovalStatus(
          brdId,
          status,
          commentsController.text,
        );
        await _loadPendingBRDs();
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRD Approvals'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : !_isAdmin
                  ? const Center(
                      child: Text('You do not have permission to access this page.'))
                  : _pendingBRDs.isEmpty
                      ? const Center(child: Text('No pending BRDs'))
                      : ListView.builder(
                          itemCount: _pendingBRDs.length,
                          itemBuilder: (context, index) {
                            final brd = _pendingBRDs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text(brd['title'] as String? ?? 'Untitled'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Created: ${DateTime.parse(brd['createdAt'] as String).toString().split('.')[0]}',
                                    ),
                                    Text(
                                      'By: ${brd['createdBy'] ?? 'Unknown'}',
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle),
                                      color: Colors.green,
                                      onPressed: () => _handleApproval(
                                          brd['id'] as String, 'approve'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel),
                                      color: Colors.red,
                                      onPressed: () => _handleApproval(
                                          brd['id'] as String, 'reject'),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/brd_detail',
                                    arguments: brd['id'] as String,
                                  );
                                },
                              ),
                            );
                          },
                        ),
    );
  }
} 