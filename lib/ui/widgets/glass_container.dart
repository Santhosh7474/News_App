import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 15.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.glassmorphismBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: AppColors.glassmorphismBorder,
                    width: 1.0,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
