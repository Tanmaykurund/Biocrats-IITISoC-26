import 'package:flutter/material.dart';

/// ============================================================
///                         App Theme
/// ============================================================
/// Central place for all colors, text styles, and design

class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ── Brand Colors ──────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1D1F33);
  static const Color surfaceLight = Color(0xFF2D2F45);
  static const Color accent = Color(0xFF00E5FF); // Cyan accent

  // ── Vital-Specific Colors ────────────────────────────────────
  static const Color heartRateColor = Color(0xFFFF6B6B);   // Warm coral
  static const Color spo2Color = Color(0xFF4FC3F7);        // Ocean blue
  static const Color temperatureColor = Color(0xFFFFD54F); // Amber gold

  // ── Status Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF66BB6A);  // Green — normal
  static const Color warning = Color(0xFFFFA726);  // Orange — borderline
  static const Color danger = Color(0xFFEF5350);   // Red — abnormal
  static const Color info = Color(0xFF42A5F5);

  // ── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);

  // ── Gradients ────────────────────────────────────────────────
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D1F33),
      Color(0xFF151729),
    ],
  );

  static const LinearGradient heartRateGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
  );

  static const LinearGradient spo2Gradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
  );

  static const LinearGradient temperatureGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
  );

  // ── Border Radius ────────────────────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // ── Spacing ──────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ── Animation Durations ──────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ── Card Decoration ──────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(radiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Builds the full dark [ThemeData] for the app.
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: surface,
          onPrimary: background,
          onSecondary: background,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMuted,
            letterSpacing: 0.5,
          ),
        ),
      );
}
