import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: const Color(0xFFBB86FC),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBB86FC),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: Colors.white70,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Colors.white60,
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    primaryColor: const Color(0xFF6200EE),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFB00020),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Colors.black54,
      ),
    ),
    useMaterial3: true,
  );
}
