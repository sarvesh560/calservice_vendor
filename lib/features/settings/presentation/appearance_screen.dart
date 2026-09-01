import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/settings_row.dart';
import 'providers/appearance_providers.dart';
import '../../settings/domain/appearance_preferences.dart';


class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appearanceControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Appearance', style: AppTypography.titleLarge),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        children: [
          const SectionHeader(title: 'THEME'),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _ThemeOptionRow(
                  title: 'System Default',
                  isSelected: prefs.valueOrNull?.theme == AppThemeMode.system,
                  onTap: () => ref.read(appearanceControllerProvider.notifier).save(prefs.valueOrNull!.copyWith(theme: AppThemeMode.system)),
                ),
                _ThemeOptionRow(
                  title: 'Light',
                  isSelected: prefs.valueOrNull?.theme == AppThemeMode.light,
                  onTap: () => ref.read(appearanceControllerProvider.notifier).save(prefs.valueOrNull!.copyWith(theme: AppThemeMode.light)),
                ),
                _ThemeOptionRow(
                  title: 'Dark',
                  isSelected: prefs.valueOrNull?.theme == AppThemeMode.dark,
                  isLast: true,
                  onTap: () => ref.read(appearanceControllerProvider.notifier).save(prefs.valueOrNull!.copyWith(theme: AppThemeMode.dark)),
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
                Expanded(child: Text(title, style: AppTypography.title.copyWith(fontSize: 15))),
                if (isSelected) Icon(Icons.check_circle_rounded, color: AppColors.brandChampagne),
              ],
            ),
          ),
          if (!isLast) Divider(color: AppColors.divider, height: 1, indent: AppSpacing.lg),
        ],
      ),
    );
  }
}
