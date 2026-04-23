import 'package:flutter/material.dart';

class AppTheme {
  static const seedColor = Color(0xFF6C63FF);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
