import 'package:flutter/material.dart';

class AppColors {
  // Deep Futuristic Dark Slate Palette
  static const Color darkBackground = Color(0xFF090D16);    // Deep Void Slate
  static const Color darkSurface = Color(0xFF111827);       // Dark Slate Surface
  static const Color darkSurfaceLight = Color(0xFF1F2937);  // Elevated Surface
  static const Color darkDivider = Color(0xFF1F293D);       // Subtle Divider Line

  // Light Background & Surfaces
  static const Color background = Color(0xFFF6F8FC);        // Crisp Slate Light
  static const Color surface = Color(0xFFFFFFFF);           // Pure White
  static const Color surfaceLight = Color(0xFFEDF2F7);      // Light Accent
  static const Color cardHeader = Color(0xFFF8FAFC);
  static const Color divider = Color(0xFFE2E8F0);           // Light Border

  // Neon & Brand Vibrant Accents
  static const Color primary = Color(0xFF6366F1);        // Neon Indigo
  static const Color primaryLight = Color(0xFF818CF8);   // Vibrant Indigo Light
  static const Color secondary = Color(0xFF06B6D4);      // Electric Cyan
  static const Color secondaryLight = Color(0xFF38BDF8); // Cyan Light

  static const Color neonEmerald = Color(0xFF10B981);    // Vivid Emerald
  static const Color neonPurple = Color(0xFF8B5CF6);     // Vivid Purple
  static const Color neonRose = Color(0xFFF43F5E);       // Vivid Rose
  static const Color neonAmber = Color(0xFFF59E0B);      // Vivid Amber

  // Currency Color Indicators
  static const Color egp = Color(0xFF10B981); // Emerald Green
  static const Color eur = Color(0xFF3B82F6); // Electric Blue
  static const Color usd = Color(0xFFF59E0B); // Gold Amber

  // Category Colors
  static const Color officeOverhead = Color(0xFF8B5CF6); // Purple
  static const Color hrPayroll = Color(0xFFEC4899);      // Pink
  static const Color travelLogistics = Color(0xFF14B8A6); // Teal
  static const Color commercialAdmin = Color(0xFFF97316); // Orange

  // Status & Neutral
  static const Color textPrimary = Color(0xFF0F172A);   // Deep Slate Text
  static const Color textSecondary = Color(0xFF64748B); // Slate Medium Text
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Dark Neutral Text
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Table & Row Accents
  static const Color tableHeaderBg = Color(0xFF0F172A);
  static const Color tableRowHover = Color(0xFF1E293B);
  static const Color tableRowAlt = Color(0xFF111827);

  // Glassmorphism Fills & Borders
  static const Color glassFillDark = Color(0x1F1E293B);
  static const Color glassFillLight = Color(0xCCFFFFFF);
  static const Color glassBorderDark = Color(0x2B818CF8);
  static const Color glassBorderLight = Color(0x40CBD5E1);

  // Vibrant Gradient Presets for 3D Glass Icons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Context-Aware Dynamic Resolvers
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color getBackground(BuildContext context) => isDark(context) ? darkBackground : background;
  static Color getSurface(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color getSurfaceLight(BuildContext context) => isDark(context) ? darkSurfaceLight : surfaceLight;
  static Color getDivider(BuildContext context) => isDark(context) ? darkDivider : divider;
  static Color getTextPrimary(BuildContext context) => isDark(context) ? darkTextPrimary : textPrimary;
  static Color getTextSecondary(BuildContext context) => isDark(context) ? darkTextSecondary : textSecondary;
  static Color getTableHeaderBg(BuildContext context) => isDark(context) ? darkBackground : tableHeaderBg;
  static Color getTableRowHover(BuildContext context) => isDark(context) ? darkSurfaceLight : tableRowHover;
}
