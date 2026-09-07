import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static bool _configured = false;

  static void _ensureConfigured() {
    if (!_configured) {
      GoogleFonts.config.allowRuntimeFetching = false;
      _configured = true;
    }
  }

  static TextTheme get textTheme {
    _ensureConfigured();
    return GoogleFonts.manropeTextTheme();
  }

  static TextStyle get display => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      );

  static TextStyle get headline => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get numeric => GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
