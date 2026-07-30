import 'package:flutter/material.dart';

class AppColors {
  // Light Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Clean Light Slate / Off-White
  static const Color surface = Color(0xFFFFFFFF);    // Pure White Card/Surface
  static const Color surfaceLight = Color(0xFFF1F5F9); // Light Slate Accent
  static const Color cardHeader = Color(0xFFF8FAFC);
  static const Color divider = Color(0xFFE2E8F0);    // Light Border Slate

  // Dark Background & Surfaces
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceLight = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);

  // Brand Accents
  static const Color primary = Color(0xFF4F46E5);     // Indigo Primary
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF0891B2);   // Cyan Engineering Accent

  // Currency Color Indicators
  static const Color egp = Color(0xFF059669); // Emerald Green
  static const Color eur = Color(0xFF2563EB); // Electric Blue
  static const Color usd = Color(0xFFD97706); // Gold Amber

  // Category Colors
  static const Color officeOverhead = Color(0xFF7C3AED); // Purple
  static const Color hrPayroll = Color(0xFFDB2777);      // Pink
  static const Color travelLogistics = Color(0xFF0D9488); // Teal
  static const Color commercialAdmin = Color(0xFFEA580C); // Orange

  // Status & Neutral (Light Mode Defaults)
  static const Color textPrimary = Color(0xFF0F172A);   // Deep Slate Text
  static const Color textSecondary = Color(0xFF64748B); // Slate Medium Text
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF0F172A);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFCA8A04);
  static const Color error = Color(0xFFDC2626);

  // Dark Neutral Text
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Table & Row Accents
  static const Color tableHeaderBg = Color(0xFFF1F5F9);
  static const Color tableRowHover = Color(0xFFF8FAFC);
  static const Color tableRowAlt = Color(0xFFFAFAFA);

  // Context-Aware Dynamic Resolvers
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color getBackground(BuildContext context) => isDark(context) ? darkBackground : background;
  static Color getSurface(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color getSurfaceLight(BuildContext context) => isDark(context) ? darkSurfaceLight : surfaceLight;
  static Color getDivider(BuildContext context) => isDark(context) ? darkDivider : divider;
  static Color getTextPrimary(BuildContext context) => isDark(context) ? darkTextPrimary : textPrimary;
  static Color getTextSecondary(BuildContext context) => isDark(context) ? darkTextSecondary : textSecondary;
  static Color getTableHeaderBg(BuildContext context) => isDark(context) ? darkBackground : tableHeaderBg;
  static Color getTableRowHover(BuildContext context) => isDark(context) ? darkSurface : tableRowHover;
}
