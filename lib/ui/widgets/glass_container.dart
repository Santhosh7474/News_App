import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A premium Liquid Glass container that perfectly replicates the iOS 26 glass effect.
/// Automatically adapts between dark and light modes for max realism.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final Color? color;
  final bool elevated; // adds a deeper shadow for more depth

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 20.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.color,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = color ??
        (isDark
            ? AppColors.glassmorphismBackground
            : AppColors.glassLightBackground);

    final borderColor = isDark
        ? AppColors.glassmorphismBorder
        : AppColors.glassLightBorder;

    final List<BoxShadow> shadows = elevated
        ? [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.6),
              blurRadius: 1,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ]
        : [];

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: borderColor,
                    width: 1.0,
                  ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.04),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.45),
                      ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Full-screen liquid glass background scaffold — use this on every screen
/// to get the floating glass blobs + gradient that iOS 18 uses.
class LiquidGlassScaffold extends StatelessWidget {
  final Widget body;
  final bool extendBodyBehindAppBar;

  const LiquidGlassScaffold({
    super.key,
    required this.body,
    this.extendBodyBehindAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradColors =
        isDark ? AppColors.getDarkBgGradient() : AppColors.getLightBgGradient();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Base gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Blob 1 — top right
          Positioned(
            top: -120,
            right: -80,
            child: _GlassOrb(
              size: 340,
              color: isDark
                  ? const Color(0xFF3A2060).withValues(alpha: 0.5)
                  : const Color(0xFFAACCFF).withValues(alpha: 0.5),
            ),
          ),
          // Blob 2 — bottom left
          Positioned(
            bottom: -100,
            left: -60,
            child: _GlassOrb(
              size: 280,
              color: isDark
                  ? const Color(0xFF0A3A5C).withValues(alpha: 0.4)
                  : const Color(0xFFCCEEFF).withValues(alpha: 0.6),
            ),
          ),
          // Blob 3 — center subtle
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.5 - 100,
            child: _GlassOrb(
              size: 200,
              color: isDark
                  ? const Color(0xFF1A1A40).withValues(alpha: 0.3)
                  : const Color(0xFFEEDDFF).withValues(alpha: 0.4),
            ),
          ),
          // Main content
          body,
        ],
      ),
    );
  }
}

class _GlassOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlassOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
