import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services & Providers
import 'core/constants/app_colors.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';

// Écrans
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  /// S'assurer que les services Flutter sont prets
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialiser le stockage local avant de lancer l'app
  await StorageService.instance.init();
  //final prefs = await SharedPreferences.getInstance();
  //await prefs.remove('all_users');
  //await prefs.remove('current_user');

  runApp(
    /// Injection de dependances
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const SunuTask(),
    ),
  );

}

class SunuTask extends StatelessWidget {
  const SunuTask({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunuTask',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}