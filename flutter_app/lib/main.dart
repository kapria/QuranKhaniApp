import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/khani_list_screen.dart';
import 'screens/para_selection_screen.dart';
import 'screens/khani_details_screen.dart';
import 'screens/live_dua_home_screen.dart';
import 'screens/start_live_dua_screen.dart';
import 'screens/join_live_dua_screen.dart';
import 'screens/live_dua_session_screen.dart';
import 'screens/notifications_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/khani_provider.dart';

void main() {
  runApp(const QuranKhaniApp());
}

class QuranKhaniApp extends StatelessWidget {
  const QuranKhaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KhaniProvider()),
      ],
      child: MaterialApp(
        title: 'Quran Khani',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[50],
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/khanis': (context) => const KhaniListScreen(),
          '/para-selection': (context) => const ParaSelectionScreen(),
          '/khani-details': (context) => const KhaniDetailsScreen(),
          '/live-dua': (context) => const LiveDuaHomeScreen(),
          '/start-live-dua': (context) => const StartLiveDuaScreen(),
          '/join-live-dua': (context) => const JoinLiveDuaScreen(),
          '/live-dua-session': (context) => const LiveDuaSessionScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return FutureBuilder(
      future: authProvider.checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
