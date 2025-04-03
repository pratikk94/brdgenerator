import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/brd_generator_screen.dart';
import 'screens/brd_detail_screen.dart';
import 'screens/brd_approval_screen.dart';
import 'services/auth_service.dart';
import 'services/brd_service.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'screens/brd_list_screen.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/brd_ai_generation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      await FirebaseAppCheck.instance.activate(
        // Use debug provider for development, replace with proper providers for production
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        Provider(
          create: (_) => BRDService(),
        ),
      ],
      child: MaterialApp(
        title: 'DestinPQ BRD Generator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 1,
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.indigo,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(
                authenticatedRoute: BRDListScreen(),
                unauthenticatedRoute: LoginScreen(),
              ),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const BRDListScreen(),
          '/brd_generator': (context) => const BRDGeneratorScreen(),
          '/brd_detail': (context) => const BRDDetailScreen(),
          '/brd_approvals': (context) => const BRDApprovalScreen(),
          '/brd_ai_generator': (context) => const BRDAIGenerationScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedRoute;
  final Widget unauthenticatedRoute;

  const AuthWrapper({
    Key? key,
    required this.authenticatedRoute,
    required this.unauthenticatedRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (!authService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return authService.isLoggedIn ? authenticatedRoute : unauthenticatedRoute;
      },
    );
  }
}
