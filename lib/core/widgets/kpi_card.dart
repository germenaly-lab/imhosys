import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'glass_container.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final LinearGradient? iconGradient;
  final Widget? trailingWidget;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    this.iconGradient,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Map accent colors to rich gradients if not provided
    final effectiveGradient = iconGradient ??
        LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      elevation: 4,
      glowColor: accentColor,
      borderColor: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GlassIconBadge(
                icon: icon,
                gradient: effectiveGradient,
                size: 42,
                iconSize: 20,
                glowColor: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AppColors.getTextPrimary(context),
              shadows: isDark
                  ? [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                      )
                    ]
                  : null,
            ),
          ),
          if (subtitle != null || trailingWidget != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (subtitle != null)
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextSecondary(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ?trailingWidget,
              ],
            ),
          ],
        ],
      ),
    );
  }
}
