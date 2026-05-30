import 'package:flutter/material.dart';

class AppColors {
  // Primarios
  static const Color primary = Color(0xFFFF6B6B);       // Coral vibrante
  static const Color primaryDark = Color(0xFFE53935);   // Rojo profundo
  static const Color secondary = Color(0xFFFF8E53);     // Naranja cálido

  // Fondos
  static const Color background = Color(0xFFF8F9FA);    // Blanco grisáceo
  static const Color surface = Color(0xFFFFFFFF);       // Blanco puro
  static const Color cardBg = Color(0xFFFFFFFF);

  // Textos
  static const Color textDark = Color(0xFF1A1A2E);      // Casi negro
  static const Color textMedium = Color(0xFF6C757D);    // Gris medio
  static const Color textLight = Color(0xFFFFFFFF);     // Blanco

  // Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Extras
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);
  static const Color favorite = Color(0xFFFF6B6B);

  // Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente oscuro para cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
