import 'package:flutter/material.dart';

class AppColors {
  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF000000);
  static const Color surfaceDark     = Color(0xFF141414);
  static const Color selectionDark   = Color(0xFF333333);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color accent          = Color(0xFFFFFFFF);

  // ── Light Mode ─────────────────────────────────────────────────────────────
  static const Color backgroundLight   = Color(0xFFEEEEF0);
  static const Color surfaceLight      = Color(0xFFFFFFFF);
  static const Color selectionLight    = Color(0xFFE5E5EA);
  static const Color textPrimaryLight  = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color accentLight       = Color(0xFF1C1C1E);

  // ── Liquid Glass (Dark) ────────────────────────────────────────────────────
  static const Color glassmorphismBackground = Color(0x26FFFFFF); // 15% White
  static const Color glassmorphismBorder     = Color(0x40FFFFFF); // 25% White
  static const Color glassHighlight          = Color(0x14FFFFFF); // 8% White
  static const Color glassShadow             = Color(0x66000000); // 40% Black

  // ── Liquid Glass (Light) ───────────────────────────────────────────────────
  static const Color glassLightBackground = Color(0x99FFFFFF); // 60% White
  static const Color glassLightBorder     = Color(0x80FFFFFF); // 50% White
  static const Color glassLightHighlight  = Color(0x40FFFFFF); // 25% White

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFFF453A);

  // ── Dynamic Glass Gradients ────────────────────────────────────────────────
  static List<Color> getDarkBgGradient() => [
    const Color(0xFF0A0A12),
    const Color(0xFF0D0D1A),
    const Color(0xFF080810),
  ];

  static List<Color> getLightBgGradient() => [
    const Color(0xFFD4D4D8),
    const Color(0xFFEAEAEC),
    const Color(0xFFE0E0E4),
  ];
}

