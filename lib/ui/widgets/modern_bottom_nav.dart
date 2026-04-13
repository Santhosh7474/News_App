import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<IconData> icons;
  final List<IconData> activeIcons;
  final ValueChanged<int> onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.icons,
    required this.activeIcons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (icons.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = icons.length;

    // The indicator alignment: map index 0→-1.0, last→1.0
    final alignX = count == 1 ? 0.0 : (2.0 * currentIndex / (count - 1)) - 1.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 14),
        child: SizedBox(
          height: 66,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Frosted glass capsule (full width/height) ──────────────────
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.05),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.88),
                                  Colors.white.withValues(alpha: 0.55),
                                ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.75),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.40 : 0.12),
                            blurRadius: 32,
                            spreadRadius: -4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Animated sliding pill indicator (sits inside the capsule) ──
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      alignment: Alignment(alignX, 0),
                      child: FractionallySizedBox(
                        widthFactor: 1 / count,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.70),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.28)
                                      : Colors.white.withValues(alpha: 0.90),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    spreadRadius: isDark ? 2 : 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Touch targets + icons (on top of everything) ─────────────
              Positioned.fill(
                child: Row(
                  children: List.generate(count, (index) {
                    return Expanded(
                      child: _NavItem(
                        icon: icons[index],
                        activeIcon: activeIcons[index],
                        isSelected: index == currentIndex,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap(index);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, isSelected ? -3.0 : 0.0, 0.0, 1.0)
            ..scaleByDouble(
              isSelected ? 1.25 : 0.92,
              isSelected ? 1.25 : 0.92,
              1.0,
              1.0,
            ),
          transformAlignment: FractionalOffset.center,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.42,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInCubic,
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white60 : Colors.black38),
            ),
          ),
        ),
      ),
    );
  }
}
