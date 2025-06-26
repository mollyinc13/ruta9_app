import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Using google_fonts for modern typography
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.primaryDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.primaryYellow, // Or accentRed/accentYellow
        background: AppColors.primaryDark,
        surface: AppColors.surfaceDark, // For cards, dialogs
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onBackground: AppColors.textLight,
        onSurface: AppColors.textLight,
        error: AppColors.accentRed, // Usar un rojo de la paleta definida
        onError: AppColors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0, // Flat app bars
        titleTextStyle: GoogleFonts.lato( // Example font
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryRed),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.lato(fontSize: 57, fontWeight: FontWeight.bold, color: AppColors.textLight),
        displayMedium: GoogleFonts.lato(fontSize: 45, fontWeight: FontWeight.bold, color: AppColors.textLight),
        displaySmall: GoogleFonts.lato(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textLight),

        headlineLarge: GoogleFonts.lato(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textLight),
        headlineMedium: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textLight),
        headlineSmall: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textLight), // Category titles

        titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textLight),
        titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight), // Product name in card
        titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLight),

        bodyLarge: GoogleFonts.lato(fontSize: 16, color: AppColors.textLight), // Product description
        bodyMedium: GoogleFonts.lato(fontSize: 14, color: AppColors.textLight), // General text
        bodySmall: GoogleFonts.lato(fontSize: 12, color: AppColors.textMuted), // Muted text

        labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white), // Button text
        labelMedium: GoogleFonts.lato(fontSize: 12, color: AppColors.textLight),
        labelSmall: GoogleFonts.lato(fontSize: 10, color: AppColors.textMuted),
      ).apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),

      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        buttonColor: AppColors.primaryRed, // Default button color
        textTheme: ButtonTextTheme.primary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.white, // Text color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          textStyle: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
        hintStyle: GoogleFonts.lato(color: AppColors.textMuted),
        labelStyle: GoogleFonts.lato(color: AppColors.textLight),
      ),

      cardTheme: CardThemeData( // Corrected
        elevation: 2.0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      dialogTheme: DialogThemeData( // Corrected
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight),
        contentTextStyle: GoogleFonts.lato(fontSize: 16, color: AppColors.textLight),
      ),

      // Add other theme properties as needed (e.g., iconTheme, chipTheme)
    );
  }
}
