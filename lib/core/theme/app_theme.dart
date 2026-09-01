import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_typography.dart';
import '../../features/settings/domain/appearance_preferences.dart';

class SemanticColor {
  const SemanticColor({
    required this.base,
    required this.tint,
    required this.tintBorder,
    required this.onTint,
  });

  final Color base;
  final Color tint;
  final Color tintBorder;
  final Color onTint;
}

class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;
  static bool _highContrast = false;

  static void configure({required Brightness brightness, required bool highContrast}) {
    _brightness = brightness;
    _highContrast = highContrast;
  }

  static bool get _isDark => _brightness == Brightness.dark;

  // Brand colors
  static const Color brandMidnight = Color(0xFF17233C);
  static const Color brandMidnightDark = Color(0xFF10182B);
  static const Color brandChampagne = Color(0xFFC8A96B);
  static const Color brandChampagneDark = Color(0xFFA8894F);
  static const Color brandSlate = Color(0xFF6E7F9D);
  static const Color brandMist = Color(0xFFF5F6F8);
  
  static const Color primary = Color(0xFF17233C);
  static const Color primaryDark = Color(0xFF10182B);
  
  static const Color secondary = Color(0xFFC8A96B);
  static const Color secondaryDark = Color(0xFFA8894F);
  
  static const Color accent = Color(0xFF6E7F9D);
  static const Color accentSoft = Color(0xFFEAF0F7);
  
  static SemanticColor get success => _isDark ? const SemanticColor(
    base: Color(0xFF65B88E),
    tint: Color(0xFF18382B),
    tintBorder: Color(0xFF294A3D),
    onTint: Color(0xFFB3DDC7),
  ) : const SemanticColor(
    base: Color(0xFF2F7D5A),
    tint: Color(0xFFE8F4EE),
    tintBorder: Color(0xFFB5DECA),
    onTint: Color(0xFF1B4934),
  );

  static SemanticColor get error => _isDark ? const SemanticColor(
    base: Color(0xFFE17C7C),
    tint: Color(0xFF3A2024),
    tintBorder: Color(0xFF5A3036),
    onTint: Color(0xFFF2BABA),
  ) : const SemanticColor(
    base: Color(0xFFB84A4A),
    tint: Color(0xFFF9E9E9),
    tintBorder: Color(0xFFE5B5B5),
    onTint: Color(0xFF6B2B2B),
  );

  static SemanticColor get warning => _isDark ? const SemanticColor(
    base: Color(0xFFD6AA62),
    tint: Color(0xFF3A2D18),
    tintBorder: Color(0xFF5A4525),
    onTint: Color(0xFFEBD4B0),
  ) : const SemanticColor(
    base: Color(0xFFB9822B),
    tint: Color(0xFFFBF2DF),
    tintBorder: Color(0xFFE5CC9E),
    onTint: Color(0xFF6C4C19),
  );

  static SemanticColor get info => _isDark ? const SemanticColor(
    base: Color(0xFF88A9D1),
    tint: Color(0xFF1C2C43),
    tintBorder: Color(0xFF2C4362),
    onTint: Color(0xFFC4D4E8),
  ) : const SemanticColor(
    base: Color(0xFF52749E),
    tint: Color(0xFFEAF0F7),
    tintBorder: Color(0xFFB9CBE0),
    onTint: Color(0xFF30445C),
  );

  static Color get surfaceMuted => _isDark ? const Color(0xFF202B40) : const Color(0xFFECEFF3);
  
  static Color get background => _isDark ? const Color(0xFF0C1220) : const Color(0xFFF5F6F8);
  static Color get surface => _isDark ? const Color(0xFF121A2A) : const Color(0xFFFFFFFF);
  static Color get surfaceElevated => _isDark ? const Color(0xFF182236) : const Color(0xFFFCFCFD);

  static Color get border => _isDark ? const Color(0xFF29354A) : const Color(0xFFDCE1E8);
  static Color get borderStrong => _isDark ? const Color(0xFF3A4860) : const Color(0xFFC5CCD6);
  static Color get divider => _isDark ? const Color(0xFF253147) : const Color(0xFFE7EAF0);

  static Color get textPrimary => _isDark ? const Color(0xFFF2F5F9) : const Color(0xFF172033);
  static Color get textSecondary => _isDark ? const Color(0xFFAEB8C7) : const Color(0xFF5E6878);
  static Color get textMuted => _isDark ? const Color(0xFF7D889A) : const Color(0xFF8992A0);
  
  static Color get textOnPrimary => _isDark ? const Color(0xFF10182B) : const Color(0xFFFFFFFF);
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double massive = 48;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double control = 10;
  static const double card = 14;
  static const double lg = 18;
  static const double sheet = 24;
  static const double pill = 999;
}

class AppElevation {
  AppElevation._();
  static const List<BoxShadow> none = [];
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

class InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const InstantPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

Color colorForAccent(AccentColorOption accent) {
  return AppColors.brandMidnight;
}

class AppTheme {
  AppTheme._();

  static ThemeData build({
    required Brightness brightness,
    required AccentColorOption accent,
    required LayoutDensityOption density,
    required bool highContrast,
    required bool reducedMotion,
  }) {
    final seed = colorForAccent(accent);
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final pageTransitionsTheme = reducedMotion
        ? const PageTransitionsTheme(builders: {TargetPlatform.android: InstantPageTransitionsBuilder(), TargetPlatform.iOS: InstantPageTransitionsBuilder()})
        : const PageTransitionsTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      visualDensity: density == LayoutDensityOption.compact ? VisualDensity.compact : VisualDensity.standard,
      scaffoldBackgroundColor: AppColors.background,
      pageTransitionsTheme: pageTransitionsTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark ? const Color(0xFF121A2A) : const Color(0xFF17233C),
        foregroundColor: const Color(0xFFF5F6F8),
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: AppColors.border, width: highContrast ? 1.4 : 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: highContrast ? 1.2 : 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.dark ? const Color(0xFF0C1220) : const Color(0xFFFFFFFF),
        indicatorColor: brightness == Brightness.dark ? const Color(0xFF202B40) : const Color(0xFFF7F0E2),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected 
                ? (brightness == Brightness.dark ? const Color(0xFFD4B779) : const Color(0xFF17233C)) 
                : (brightness == Brightness.dark ? const Color(0xFF7D889A) : const Color(0xFF8992A0)),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected 
                ? (brightness == Brightness.dark ? const Color(0xFFD4B779) : const Color(0xFFC8A96B)) 
                : (brightness == Brightness.dark ? const Color(0xFF7D889A) : const Color(0xFF8992A0))
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brightness == Brightness.dark ? const Color(0xFFD4B779) : const Color(0xFF17233C),
          foregroundColor: brightness == Brightness.dark ? const Color(0xFF10182B) : const Color(0xFFFFFFFF),
          disabledBackgroundColor: brightness == Brightness.dark ? const Color(0xFF29354A) : const Color(0xFFDCE1E8),
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brightness == Brightness.dark ? const Color(0xFFD4B779) : const Color(0xFF17233C),
          side: BorderSide(color: brightness == Brightness.dark ? const Color(0xFF3A4860) : const Color(0xFFC5CCD6)),
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      textTheme: AppTypography.textTheme.copyWith(
        displaySmall: AppTypography.display.copyWith(color: AppColors.textPrimary),
        headlineLarge: AppTypography.headline.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTypography.title.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTypography.body.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.body.copyWith(color: AppColors.textSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        labelSmall: AppTypography.label.copyWith(color: AppColors.textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF182236) : const Color(0xFFFCFCFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: brightness == Brightness.dark ? const Color(0xFFD4B779) : const Color(0xFF17233C), width: 1.5),
        ),
      ),
    );
  }
}
