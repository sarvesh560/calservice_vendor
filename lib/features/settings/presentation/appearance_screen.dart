import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/settings_row.dart';
import '../../settings/domain/appearance_preferences.dart';
import 'providers/appearance_providers.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(currentAppearanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumSecondaryAppBar(title: context.tr('appearance')),
      body: ListView(
        children: [
          SectionHeader(title: context.tr('theme_mode').toUpperCase()),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _ThemeOptionRow(
                  title: context.tr('system_theme'),
                  isSelected: prefs.theme == AppThemeMode.system,
                  onTap: () => ref.read(appearanceControllerProvider.notifier).save(prefs.copyWith(theme: AppThemeMode.system)),
                ),
                _ThemeOptionRow(
                  title: context.tr('light_theme'),
                  isSelected: prefs.theme == AppThemeMode.light,
                  onTap: () => ref.read(appearanceControllerProvider.notifier).save(prefs.copyWith(theme: AppThemeMode.light)),
                ),
                _ThemeOptionRow(
                  title: context.tr('dark_theme'),
                  isSelected: prefs.theme == AppThemeMode.dark,
                  isLast: true,
                  onTap: () => ref.read(appearanceControllerProvider.notifier).save(prefs.copyWith(theme: AppThemeMode.dark)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isLast = false,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.title.copyWith(fontSize: 15, color: AppColors.textPrimary))),
                if (isSelected) Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ],
            ),
          ),
          if (!isLast) Divider(color: AppColors.divider, height: 1, indent: AppSpacing.lg),
        ],
      ),
    );
  }
}
