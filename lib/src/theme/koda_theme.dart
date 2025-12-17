import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gf;

class KodaColors {
  // Backgrounds
  static const Color lightBackground = Color(0xFFF8F5F2);
  static const Color darkBackground = Color(0xFF121212);

  // Text/Ink
  static const Color lightInk = Color(0xFF121212);
  static const Color darkInk = Color(0xFFFFFFFF);

  // Tools
  static const Color tuner = Color(0xFF4D5BCE);
  static const Color rhythm = Color(0xFFFF6B6B);
  static const Color tone = Color(0xFF00D2A1);
}

class KodaTheme {
  static TextTheme _buildTextTheme(Color inkColor) {
    return TextTheme(
      displayLarge: gf.GoogleFonts.sora(
        color: inkColor,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: gf.GoogleFonts.sora(
        color: inkColor,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: gf.GoogleFonts.manrope(
        color: inkColor,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: gf.GoogleFonts.manrope(
        color: inkColor,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: gf.GoogleFonts.jetBrainsMono(
        color: inkColor,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: KodaColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: KodaColors.lightBackground,
        onSurface: KodaColors.lightInk,
        primary: KodaColors.tuner, // Defaulting primary to Tuner color
      ),
      textTheme: _buildTextTheme(KodaColors.lightInk),
      appBarTheme: AppBarTheme(
        backgroundColor: KodaColors.lightBackground,
        foregroundColor: KodaColors.lightInk,
        elevation: 0,
        titleTextStyle: gf.GoogleFonts.sora(
          color: KodaColors.lightInk,
          fontWeight: FontWeight.w800,
          fontSize: 24,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: KodaColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: KodaColors.darkBackground,
        onSurface: KodaColors.darkInk,
        primary: KodaColors.tuner,
      ),
      textTheme: _buildTextTheme(KodaColors.darkInk),
      appBarTheme: AppBarTheme(
        backgroundColor: KodaColors.darkBackground,
        foregroundColor: KodaColors.darkInk,
        elevation: 0,
        titleTextStyle: gf.GoogleFonts.sora(
          color: KodaColors.darkInk,
          fontWeight: FontWeight.w800,
          fontSize: 24,
        ),
      ),
    );
  }
}
