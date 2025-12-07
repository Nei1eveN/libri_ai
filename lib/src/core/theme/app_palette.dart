import 'package:flutter/material.dart';

abstract class AppPalette {
  // Primary Brand Colors (Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFFE0E7FF);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Grey
  static const Color textSecondary = Color(0xFF6B7280); // Medium Grey
  static const Color textLight = Color(0xFF9CA3AF); // Light Grey

  // Functional Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Gradients (For the AI Vibe Tile)
  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
