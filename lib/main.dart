import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/brd_form_screen.dart';
import 'screens/kanban_board_screen.dart';
import 'screens/task_estimate_screen.dart';
import 'screens/login_screen.dart';
import 'screens/brd_approval_screen.dart';
import 'screens/brd_upload_screen.dart';
import 'screens/task_estimate_admin_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/brd_detail_screen.dart';
import 'state/document_state.dart';
import 'state/task_state.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'utils/firebase_config_helper.dart';
import 'widgets/safe_avatar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase with our helper
  await FirebaseConfigHelper.initializeFirebase();
  
  // Attempt to sync local data to Firebase if we have connectivity
  _checkConnectivityAndSync();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DocumentState()),
        ChangeNotifierProvider(create: (context) => TaskState()),
      ],
      child: MyApp(),
    ),
  );
}

// Check for connectivity and sync local data if possible
Future<void> _checkConnectivityAndSync() async {
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity != ConnectivityResult.none) {
    // We have connectivity, sync local data to Firebase
    final firebaseService = FirebaseService();
    await firebaseService.syncLocalDataToFirebase();
  }
  
  // Set up listener for future connectivity changes
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      // When connectivity is restored, sync local data
      final firebaseService = FirebaseService();
      firebaseService.syncLocalDataToFirebase();
    }
  });
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DestinPQ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Use either login screen or home screen as initial route depending on authentication status
      home: _authService.isLoggedIn ? MainHomeScreen() : LoginScreen(),
      routes: {
        '/home': (context) => MainHomeScreen(),
        '/login': (context) => LoginScreen(),
        '/brd_form': (context) => BRDFormScreen(),
        '/brd_approvals': (context) => BRDApprovalScreen(),
        '/brd_upload': (context) => BRDUploadScreen(),
        '/task_estimate': (context) => TaskEstimateScreen(),
        '/task_estimate_admin': (context) => TaskEstimateAdminScreen(),
        '/kanban': (context) => KanbanBoardScreen(),
      },
      // Handle BRD detail route with parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/brd_detail') {
          final String brdId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BrdDetailScreen(brdId: brdId),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  bool _isAdmin = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _loadAppInfoAsync();
  }
  
  // Entry point method: retrieves app information asynchronously and updates state
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
      HomeScreen(),
      BRDFormScreen(),
      TaskEstimateScreen(),
      KanbanBoardScreen(),
      CalendarViewScreen(),
    ];
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            const Text('DestinPQ'),
          ],
        ),
        elevation: 2,
        actions: [
          // Saved BRDs button
          IconButton(
            icon: const Icon(Icons.folder),
            tooltip: 'Saved BRDs',
            onPressed: () {
              _showSavedBRDsDialog(context);
            },
          ),
          
          // Show admin button if user is admin
          if (_isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Actions',
              onSelected: (value) {
                switch (value) {
                  case 'brd_approvals':
                    Navigator.pushNamed(context, '/brd_approvals');
                    break;
                  case 'task_estimate_admin':
                    Navigator.pushNamed(context, '/task_estimate_admin');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'brd_approvals',
                  child: Text('BRD Approvals'),
                ),
                const PopupMenuItem(
                  value: 'task_estimate_admin',
                  child: Text('Task Estimate Admin'),
                ),
              ],
            ),
          
          // Upload BRD button
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload BRD',
            onPressed: () {
              Navigator.pushNamed(context, '/brd_upload');
            },
          ),
          
          // User profile or login button
          IconButton(
            icon: _authService.isLoggedIn
                ? const Icon(Icons.account_circle)
                : const Icon(Icons.login),
            tooltip: _authService.isLoggedIn ? 'Profile' : 'Sign In',
            onPressed: () {
              if (_authService.isLoggedIn) {
                // Show user profile or sign out dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('User Account'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_authService.currentUser?.photoURL != null)
                          SafeAvatar(
                            imageUrl: _authService.currentUser!.photoURL!,
                            radius: 40,
                            fallbackWidget: Icon(Icons.person, size: 40, color: Colors.grey.shade300),
                          ),
                        const SizedBox(height: 16),
                        Text(_authService.currentUser?.displayName ?? 'User'),
                        Text(_authService.currentUser?.email ?? ''),
                        const SizedBox(height: 8),
                        Text(_isAdmin ? 'Admin User' : 'Regular User'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Sign Out'),
                        onPressed: () async {
                          await _authService.signOut();
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.of(context).pushNamed('/login');
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Estimate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Kanban',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
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
  
  // Show dialog with saved BRDs
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
                        Navigator.of(context).pop();
                        // Navigate to BRD detail screen (you'll need to implement this)
                        Navigator.pushNamed(
                          context, 
                          '/brd_detail',
                          arguments: brd['id'] as String
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class BRDHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BRD Generator'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 100,
                color: Colors.indigo,
              ),
              SizedBox(height: 24),
              Text(
                'Business Requirements Document Generator',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Create comprehensive BRDs, client proposals, and project estimates using AI',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Create New BRD'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BRDFormScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(Icons.history),
                label: Text('View Saved BRDs'),
                onPressed: () {
                  // Navigate to saved BRDs screen (to be implemented)
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
