import 'package:flutter/material.dart';

// Based on https://ruta9.cl and common dark theme with red/yellow accents
// These are example colors, actual values might be refined by inspecting the website
class AppColors {
  static const Color primaryDark = Color(0xFF1A1A1A); // Very dark grey, near black
  static const Color backgroundDark = Color(0xFF2C2C2C); // Dark grey for surfaces
  static const Color surfaceDark = Color(0xFF3C3C3C); // Slightly lighter grey for cards/modals

  static const Color primaryRed = Color(0xFFE53935); // Vibrant Red (example)
  static const Color accentRed = Color(0xFFFF5252); // Lighter Red for accents

  static const Color primaryYellow = Color(0xFFFFCA28); // Vibrant Yellow (example)
  static const Color accentYellow = Color(0xFFFFE082); // Lighter Yellow for accents

  static const Color textLight = Color(0xFFF5F5F5); // Light grey / Off-white for text
  static const Color textDark = Color(0xFF333333); // Dark grey for text on light backgrounds (if any)
  static const Color textMuted = Color(0xFFBDBDBD); // Muted text color

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Semantic colors (can be refined)
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
}
