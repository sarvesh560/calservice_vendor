import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Manrope', fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: TextStyle(fontFamily: 'Manrope', fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      displaySmall: TextStyle(fontFamily: 'Manrope', fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      headlineLarge: TextStyle(fontFamily: 'Manrope', fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      headlineMedium: TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      headlineSmall: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      titleLarge: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      titleMedium: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelLarge: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: TextStyle(fontFamily: 'Manrope', fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      bodyLarge: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: TextStyle(fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    );
  }

  static TextStyle get display => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      );

  static TextStyle get headline => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get numeric => const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontFeatures: [FontFeature.tabularFigures()],
      );
}
