import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dashboard.dart';
import 'expenses.dart';
import 'goals.dart';
import 'insights.dart';
import 'profile.dart';
import 'app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Configure API Server Host ───────────────────────────────────────
  // Physical Android device (USB): Use adb reverse for localhost forwarding
  // Run: adb reverse tcp:8000 tcp:8000
  // Then use localhost:8000 here - device will tunnel through USB
  
  // For Android Emulator on same machine
  // ApiService.setApiHost('localhost:8000');
  
  // For physical Android device (USB with adb reverse) - DEFAULT
  ApiService.setApiHost('localhost:8000');
  
  // For Genymotion emulator
  // ApiService.setApiHost('10.0.3.2:8000');
  
  // For BlueStack emulator
  // ApiService.setApiHost('10.0.3.2:8000');
  
  debugPrint('✓ API Host: ${ApiService.getApiHost()}');
  debugPrint('✓ API Base URL: ${ApiService.baseUrl}');
  debugPrint('✓ On physical Android device, run: adb reverse tcp:8000 tcp:8000');
  // ────────────────────────────────────────────────────────────────────

  await Supabase.initialize(
    url: 'https://ugppmqetpqswhgdbmikw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVncHBtcWV0cHFzd2hnZGJtaWt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxOTQwMDQsImV4cCI6MjA4Nzc3MDAwNH0.01zTYotFx8P6gexUH3aU_ZKja3ZLJGxgLtwbDr_GXu8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp.router(
        title: 'Morpheus Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: DashboardScreen.accentGreen),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        routerConfig: appRouter,
      ),
    );
  }
}

/// Wrapper to handle authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // User is authenticated
        if (authService.isAuthenticated) {
          return MaterialApp.router(
            title: 'Morpheus Dashboard',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: DashboardScreen.accentGreen,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            routerConfig: appRouter,
          );
        }

        // Show login or signup
        return MaterialApp(
          title: 'Morpheus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: DashboardScreen.accentGreen,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: _showLogin
              ? LoginScreen(
                  onSignUp: () {
                    setState(() => _showLogin = false);
                  },
                )
              : SignupScreen(
                  onLogin: () {
                    setState(() => _showLogin = true);
                  },
                ),
        );
      },
    );
  }
}
