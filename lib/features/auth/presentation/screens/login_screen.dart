import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../ui/widgets/glass_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      final user = await auth.signInWithGoogle();
      if (user != null && mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen gradient bg
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF1a1a2e), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Subtle orb decoration
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    // App logo / icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        CupertinoIcons.news,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Stay\nInformed.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 52,
                            letterSpacing: -2,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premium news from around the world,\ncurated just for you.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryDark,
                            height: 1.5,
                          ),
                    ),
                    const Spacer(flex: 3),
                    // Google Sign-In Button
                    GestureDetector(
                      onTap: _isLoading ? null : _signInWithGoogle,
                      child: GlassContainer(
                        height: 64,
                        width: double.infinity,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Google "G" icon rendered via text (avoids asset dependency)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
