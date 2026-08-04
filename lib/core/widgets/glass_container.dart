import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Frosted Glassmorphism Container Widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? borderColor;
  final Color? fillContainerColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.borderRadius,
    this.border,
    this.borderColor,
    this.fillContainerColor,
    this.gradient,
    this.padding,
    this.margin,
    this.elevation = 0,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final defaultRadius = borderRadius ?? BorderRadius.circular(16);
    final effectiveBorderColor = borderColor ??
        (isDark
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.primary.withValues(alpha: 0.15));

    final defaultGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B).withValues(alpha: 0.55),
                  const Color(0xFF0F172A).withValues(alpha: 0.35),
                ]
              : [
                  Colors.white.withValues(alpha: 0.85),
                  Colors.white.withValues(alpha: 0.50),
                ],
        );

    final boxDecoration = BoxDecoration(
      color: fillContainerColor,
      gradient: fillContainerColor == null ? defaultGradient : null,
      borderRadius: defaultRadius,
      border: border ?? Border.all(color: effectiveBorderColor, width: 1.2),
      boxShadow: [
        if (glowColor != null)
          BoxShadow(
            color: glowColor!.withValues(alpha: isDark ? 0.30 : 0.18),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        if (elevation > 0)
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation * 2),
          ),
      ],
    );

    Widget content = ClipRRect(
      borderRadius: defaultRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: boxDecoration,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: defaultRadius,
        child: InkWell(
          borderRadius: defaultRadius,
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.15),
          highlightColor: AppColors.primary.withValues(alpha: 0.08),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// 3D Glass Icon Badge with Vibrant Multi-Color Glow & Sheen
class GlassIconBadge extends StatelessWidget {
  final IconData icon;
  final LinearGradient? gradient;
  final Color? color;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color? glowColor;

  const GlassIconBadge({
    super.key,
    required this.icon,
    this.gradient,
    this.color,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.iconColor = Colors.white,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        (color != null
            ? LinearGradient(
                colors: [color!, color!.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.primaryGradient);

    final effectiveGlow = glowColor ?? color ?? effectiveGradient.colors.first;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: effectiveGradient,
        boxShadow: [
          BoxShadow(
            color: effectiveGlow.withValues(alpha: 0.40),
            blurRadius: 14,
            spreadRadius: -1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.32),
        child: Stack(
          children: [
            // Glass Reflection Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size * 0.45,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Icon Center
            Center(
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
