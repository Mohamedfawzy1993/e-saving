import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/groups/groups_list_screen.dart';
import 'presentation/screens/groups/group_details_screen.dart';
import 'presentation/screens/groups/create_group_screen.dart';
import 'presentation/screens/groups/join_group_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';

class MoneySavingApp extends StatelessWidget {
  const MoneySavingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Saving Groups',
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return const SplashScreen();
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/groups': (context) => const GroupsListScreen(),
        '/group-details': (context) => const GroupDetailsScreen(),
        '/create-group': (context) => const CreateGroupScreen(),
        '/join-group': (context) => const JoinGroupScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}