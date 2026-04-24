import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/screens/onboarding/onboarding_screen.dart';
import 'package:sunu_task/services/storage_service.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _showLogo = false;
  bool _showText = false;

  // === Cycle de vie =====
  @override
  void initState() {
    super.initState();
    _startAnimations();
    _initAppAndNavigate();
    //_startTimer();
  }

  @override
  void dispose() {
    // Important: annuler le timer pour eviter les fuites de memoire
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 100), () {
      //mounted vérifie toujours si le widget est toujours actif
      // dans l'arbre de widget
      if(mounted) {
        setState(() => _showLogo = true);
      }
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      if(mounted) {
        setState(() => _showText = true);
      }
    });
  }

  Future<void> _initAppAndNavigate() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 4)),
      context.read<AppProvider>().init(),
      context.read<AuthProvider>().init(),
    ]);

    if (!mounted) return;

    final appProvider = context.read<AppProvider>();
    final authProvider = context.read<AuthProvider>();

    Widget nextScreen;

    if (!appProvider.isOnboardingComplete) {
      nextScreen = const OnboardingScreen();
    } else if (!authProvider.isAuthenticated) {
      nextScreen = const LoginScreen();
    } else {
      final userId = authProvider.currentUser!.id;
      await context.read<ProjectProvider>().loadProjects(userId);
      await context.read<TaskProvider>().loadTasks();
      nextScreen = const HomeScreen();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim, secondaryAnim) => nextScreen,
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            _buildLogo(),
            SizedBox(height: 24,),
            // Nom App
            _buildAppName(),
            SizedBox(height: 8,),
            // Slogan
            _buildAppSlogan(),
            SizedBox(height: 48,),
            //Chargement
            _buildLoadingIndicator()
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedOpacity(
      opacity: _showLogo ? 1 : 0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
      child: AnimatedScale(
        scale: _showLogo ? 1 : 0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withAlpha(180),
                    blurRadius: 20,
                    offset: Offset(0, 10)
                )
              ]
          ),
          child: Icon(
            Icons.task_alt,
            size: 65,
            color: AppColors.white.withAlpha(200),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return AnimatedOpacity(
      opacity: _showText ? 1 : 0,
      duration: Duration(milliseconds: 500),
      child: Text(
        AppStrings.appName,
        style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildAppSlogan() {
    return AnimatedOpacity(
      opacity: _showText ? 1 : 0,
      duration: Duration(milliseconds: 500),
      child: Text(
        AppStrings.appSlogan,
        style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedOpacity(
      opacity: _showText ? 1 : 0,
      duration: Duration(milliseconds: 500),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 8.0,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}

// void _startTimer() {
//   _timer = Timer( Duration(seconds: 3), _navigateToNextScreen);
// }

// void _navigateToNextScreen() {
//   if(!mounted) return;
//   final bool onboardingComplete = StorageService.instance.isOnboardingComplete;
//
//   /*Navigator.pushReplacement(context,
//     MaterialPageRoute<void>(
//     builder: (context) => onboardingComplete
//         ? const HomeScreen()
//         : const OnboardingScreen(),
//   ),
//   );*/
//
//   // Navigation avec animation
//   final appProvider = context.read<AppProvider>();
//   final authProvider = context.read<AuthProvider>();
//   Navigator.pushReplacement(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) {
//         // 1. Si l'onboarding n'est pas fait -> Onboarding
//         if (!appProvider.isOnboardingComplete) {
//           return const OnboardingScreen();
//         }
//
//         // 2. Si onboarding fait MAIS pas connecté -> Login
//         if (!authProvider.isAuthenticated) {
//           return const LoginScreen();
//         }
//
//         // 3. Si tout est OK -> Home
//         return const HomeScreen();
//       },
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeTransition(opacity: animation, child: child);
//       },
//       transitionDuration: const Duration(milliseconds: 300),
//     ),
//   );
// }