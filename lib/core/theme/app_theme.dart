import 'package:flutter/material.dart';
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
  static bool get highContrast => _highContrast;

  // Static Deep Teal + Warm Ivory + Sage Palette Constants
  static const Color obsidianBackground = Color(0xFF101918);
  static const Color obsidianSurface = Color(0xFF182321);
  static const Color obsidianElevated = Color(0xFF21302D);
  static const Color obsidianBorder = Color(0xFF30403D);

  static const Color champagneGold = Color(0xFF0F6B68);
  static const Color champagneGoldDark = Color(0xFF084C4A);
  static const Color lightGold = Color(0xFF3C918C);

  // Dynamic brand color aliases mapped to Deep Teal & Warm Ivory Palette
  static Color get burgundy => background;
  static Color get burgundyDark => surface;
  static Color get warmTaupe => primary;
  static Color get lightTaupe => secondary;
  static Color get softIvory => surfaceElevated;
  static Color get porcelain => surface;
  static Color get espresso => textPrimary;
  static Color get mochaGray => textSecondary;
  static Color get warmStone => border;
  static Color get mutedTerracotta => const Color(0xFFB85C55);

  static Color get brandMidnight => background;
  static Color get brandMidnightDark => surface;
  static Color get brandChampagne => primary;
  static Color get brandChampagneDark => primaryDark;
  static Color get brandSlate => textSecondary;
  static Color get brandMist => surfaceElevated;

  // Dynamic Primary & Accent Getters based on Brightness
  static Color get primary => const Color(0xFF0F6B68);
  static Color get primaryDark => const Color(0xFF084C4A);
  static Color get secondary => const Color(0xFF3C918C);
  static Color get secondaryDark => const Color(0xFF0F6B68);
  static Color get accent => const Color(0xFF3C918C);
  static Color get accentSoft => _isDark ? const Color(0xFF78BDB8) : const Color(0xFFA8D5D1);

  // Dynamic Semantic Color Getters (Light vs Dark)
  static SemanticColor get success => _isDark ? const SemanticColor(
    base: Color(0xFF71866A),
    tint: Color(0xFF182216),
    tintBorder: Color(0xFF2E3D2A),
    onTint: Color(0xFFDCF0D6),
  ) : const SemanticColor(
    base: Color(0xFF71866A),
    tint: Color(0xFFF1F5EF),
    tintBorder: Color(0xFFC4D5BF),
    onTint: Color(0xFF1F2B1A),
  );

  static SemanticColor get error => _isDark ? const SemanticColor(
    base: Color(0xFFB85C55),
    tint: Color(0xFF281716),
    tintBorder: Color(0xFF492A27),
    onTint: Color(0xFFF8E9E8),
  ) : const SemanticColor(
    base: Color(0xFFB85C55),
    tint: Color(0xFFFAEEEA),
    tintBorder: Color(0xFFE5C0BD),
    onTint: Color(0xFF451C1A),
  );

  static SemanticColor get warning => _isDark ? const SemanticColor(
    base: Color(0xFFB68A45),
    tint: Color(0xFF271F13),
    tintBorder: Color(0xFF493A24),
    onTint: Color(0xFFF8EFDE),
  ) : const SemanticColor(
    base: Color(0xFFB68A45),
    tint: Color(0xFFFBF6ED),
    tintBorder: Color(0xFFE4D5B8),
    onTint: Color(0xFF3B2A0F),
  );

  static SemanticColor get info => _isDark ? const SemanticColor(
    base: Color(0xFF0F6B68),
    tint: Color(0xFF132423),
    tintBorder: Color(0xFF234442),
    onTint: Color(0xFFE0F4F2),
  ) : const SemanticColor(
    base: Color(0xFF0F6B68),
    tint: Color(0xFFEEF7F6),
    tintBorder: Color(0xFFBBE3E0),
    onTint: Color(0xFF083D3B),
  );

  static Color get surfaceMuted => _isDark ? const Color(0xFF21302D) : const Color(0xFFEEF2EF);

  static Color get scaffoldBackground => _isDark ? const Color(0xFF101918) : const Color(0xFFFFFFFF);
  static Color get background => scaffoldBackground;
  static Color get surface => _isDark ? const Color(0xFF182321) : const Color(0xFFF7F8F6);
  static Color get surfaceElevated => _isDark ? const Color(0xFF21302D) : const Color(0xFFEEF2EF);

  static Color get border => _isDark ? const Color(0xFF30403D) : const Color(0xFFD9E0DC);
  static Color get borderStrong => const Color(0xFF0F6B68);
  static Color get divider => _isDark ? const Color(0xFF30403D) : const Color(0xFFD9E0DC);

  static Color get textPrimary => _isDark ? const Color(0xFFF4F2EC) : const Color(0xFF202522);
  static Color get textSecondary => _isDark ? const Color(0xFFA9B2AE) : const Color(0xFF68716C);
  static Color get textMuted => _isDark ? const Color(0xFF71827E) : const Color(0xFF8A847C);

  static Color get textOnPrimary => const Color(0xFFFFFFFF);
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
  return AppColors.primary;
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
    final isDark = brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0F6B68);
    final surfaceColor = isDark ? const Color(0xFF182321) : const Color(0xFFF7F8F6);
    final backgroundColor = isDark ? const Color(0xFF101918) : const Color(0xFFFFFFFF);
    final onPrimaryColor = const Color(0xFFFFFFFF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      surface: surfaceColor,
      onPrimary: onPrimaryColor,
    );

    final pageTransitionsTheme = reducedMotion
        ? const PageTransitionsTheme(builders: {TargetPlatform.android: InstantPageTransitionsBuilder(), TargetPlatform.iOS: InstantPageTransitionsBuilder()})
        : const PageTransitionsTheme();

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      brightness: brightness,
      colorScheme: colorScheme,
      visualDensity: density == LayoutDensityOption.compact ? VisualDensity.compact : VisualDensity.standard,
      scaffoldBackgroundColor: backgroundColor,
      pageTransitionsTheme: pageTransitionsTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: AppColors.textPrimary,
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
        backgroundColor: isDark ? const Color(0xFF182321) : const Color(0xFFFFFDF8),
        indicatorColor: isDark ? const Color(0xFF21302D) : const Color(0xFFFAF7F0),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primaryColor : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primaryColor : AppColors.textSecondary,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          disabledBackgroundColor: isDark ? const Color(0xFF21302D) : const Color(0xFFD8D1C7),
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF20231F) : const Color(0xFF20211F),
        contentTextStyle: TextStyle(color: isDark ? const Color(0xFFF5F2EA) : const Color(0xFFFFFFFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        behavior: SnackBarBehavior.floating,
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
        fillColor: AppColors.surface,
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
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
