import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/document_state.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import 'brd_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  bool _isAdmin = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadAppInfoAsync();
  }

  void _loadAppInfoAsync() async {
    _isAdmin = await _authService.isCurrentUserAdmin();
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
      _buildDashboard(),
      const BRDGeneratorScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(
              Icons.assessment_outlined,
              size: 32,
            ),
            SizedBox(width: 12),
            Text('DestinPQ'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            tooltip: 'Saved BRDs',
            onPressed: () => _showSavedBRDsDialog(context),
          ),
          if (_isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Actions',
              onSelected: (value) {
                if (value == 'brd_approvals') {
                  Navigator.pushNamed(context, '/brd_approvals');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'brd_approvals',
                  child: Text('BRD Approvals'),
                ),
              ],
            ),
          IconButton(
            icon: _authService.isLoggedIn
                ? const Icon(Icons.account_circle)
                : const Icon(Icons.login),
            tooltip: _authService.isLoggedIn ? 'Profile' : 'Sign In',
            onPressed: () => _handleAuthAction(),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'BRD',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to DestinPQ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your all-in-one solution for project documentation and management',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildRecentDocuments(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New BRD',
                  onPressed: () => _onItemTapped(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildRecentDocuments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Documents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: FirebaseService().getRecentDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Error loading recent documents');
                }
                final documents = snapshot.data as List<Map<String, dynamic>>? ?? [];
                if (documents.isEmpty) {
                  return const Text('No recent documents');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(doc['title'] as String? ?? 'Untitled'),
                      subtitle: Text(doc['type'] as String? ?? 'Document'),
                      trailing: Text(doc['date'] as String? ?? ''),
                      onTap: () {
                        if (doc['id'] != null) {
                          Navigator.pushNamed(
                            context,
                            '/brd_detail',
                            arguments: doc['id'] as String,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAuthAction() {
    if (_authService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_authService.currentUser?.displayName ?? 'User'),
              Text(_authService.currentUser?.email ?? ''),
              const SizedBox(height: 8),
              Text(_isAdmin ? 'Admin User' : 'Regular User'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                await _authService.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _showSavedBRDsDialog(BuildContext context) async {
    final firebaseService = FirebaseService();
    final brds = await firebaseService.getAllBRDs();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved BRDs'),
        content: SizedBox(
          width: double.maxFinite,
          child: brds.isEmpty
              ? const Center(child: Text('No saved BRDs found'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: brds.length,
                  itemBuilder: (context, index) {
                    final brd = brds[index];
                    final status = brd['approvalStatus'] as String? ?? 'pending';
                    final createdAt = DateTime.parse(brd['createdAt'] as String);
                    final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
                    
                    return ListTile(
                      title: Text(brd['title'] as String? ?? 'Untitled BRD'),
                      subtitle: Text('Created: $formattedDate'),
                      trailing: Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: status == 'approved' 
                            ? Colors.green.shade100 
                            : (status == 'rejected' ? Colors.red.shade100 : Colors.grey.shade100),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/brd_detail',
                          arguments: brd['id'] as String,
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
} 