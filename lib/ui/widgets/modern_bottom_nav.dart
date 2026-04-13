import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'glass_container.dart';

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

    final alignmentX = (2 * currentIndex / (icons.length - 1)) - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.accent : AppColors.accentLight;

    return SafeArea(
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(48, 0, 48, 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Base Premium Glass Container
            Positioned.fill(
              child: GlassContainer(
                borderRadius: 32,
                child: const SizedBox.expand(),
              ),
            ),

            // Sliding Glowing Indicator Layer
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                alignment: Alignment(alignmentX, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / icons.length,
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: activeColor.withValues(alpha: 0.12),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Physical Touch Targets and Icon Scaling Layer
            Positioned.fill(
              child: Row(
                children: List.generate(icons.length, (index) {
                  return Expanded(
                    child: _NavItem(
                      icon: icons[index],
                      activeIcon: activeIcons[index],
                      isSelected: index == currentIndex,
                      activeColor: activeColor,
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
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, isSelected ? -4.0 : 0.0, 0.0, 1.0)
            ..scaleByDouble(isSelected ? 1.3 : 0.9, isSelected ? 1.3 : 0.9, 1.0, 1.0),
          transformAlignment: FractionalOffset.center,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInCubic,
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 26,
              color: isSelected ? activeColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
