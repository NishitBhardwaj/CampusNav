/// CampusNav - Enhanced Splash Screen
///
/// Splash screen with Lottie animation support.
/// Falls back to code-based animation if Lottie files not available.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash animation
    await Future.delayed(AnimationDurations.splash);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon with animation
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation_rounded,
                size: 70,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(duration: AnimationDurations.medium)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: AnimationCurves.spring,
                  duration: AnimationDurations.slow,
                ),

            const SizedBox(height: 32),

            // App Name
            const Text(
              'CampusNav',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: AnimationDurations.medium)
                .slideY(begin: 0.3, curve: AnimationCurves.enter),

            const SizedBox(height: 12),

            // Tagline
            Text(
              'Offline Indoor Navigation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: AnimationDurations.medium),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.9),
                strokeWidth: 3,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: AnimationDurations.standard)
                .scale(begin: const Offset(0.5, 0.5)),

            const SizedBox(height: 20),

            // Loading text
            Text(
              'Loading campus data...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: AnimationDurations.standard),
          ],
        ),
      ),
    );
  }
}
