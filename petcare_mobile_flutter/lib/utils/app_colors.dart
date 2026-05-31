import 'package:flutter/material.dart';

class AppColors {
  // ── Primarios (invariantes) ────────────────────────────────────
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryDark = Color(0xFFE53935);
  static const Color secondary = Color(0xFFFF8E53);
  static const Color favorite = Color(0xFFFF6B6B);

  // ── Estados (invariantes) ──────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ── Gradientes (invariantes) ───────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Tema CLARO ────────────────────────────────────────────────
  static const Color background   = Color(0xFFF8F9FA);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color textDark     = Color(0xFF1A1A2E);
  static const Color textMedium   = Color(0xFF6C757D);
  static const Color textLight    = Color(0xFFFFFFFF);
  static const Color divider      = Color(0xFFEEEEEE);
  static const Color shadow       = Color(0x1A000000);

  // ── Tema OSCURO ───────────────────────────────────────────────
  static const Color darkBackground  = Color(0xFF0F0F1A);
  static const Color darkSurface     = Color(0xFF1A1A2E);
  static const Color darkCard        = Color(0xFF1E1E30);
  static const Color darkTextDark    = Color(0xFFF0F0F0);
  static const Color darkTextMedium  = Color(0xFF9E9E9E);
  static const Color darkDivider     = Color(0xFF2C2C3E);
  static const Color darkShadow      = Color(0x33000000);

  /// Devuelve el color de fondo según el tema actual
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : background;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCard
          : cardBg;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextDark
          : textDark;

  static Color textSub(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextMedium
          : textMedium;

  static Color div(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkDivider
          : divider;
}
