import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasStartedTransition = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundDark, // Matches the native splash screen
      body: Container(
        alignment: Alignment(16, 3),
        child: Lottie.asset(
          'assets/splash_screen.json',
          fit: BoxFit.contain,
          repeat: false, // Don't loop
          onLoaded: (composition) {
            // Wait for the exact duration of the lottie animation before redirecting
            Timer(composition.duration, () {
              if (mounted && !_hasStartedTransition) {
                _hasStartedTransition = true;
                ref.read(splashFinishedProvider.notifier).setFinished();
              }
            });
          },
        ),
      ),
    );
  }
}
