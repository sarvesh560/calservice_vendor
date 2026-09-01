import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/settings_row.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.titleLarge),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        children: [
          const SectionHeader(title: 'JOB UPDATES'),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _SwitchRow(title: 'New Job Offers', value: true, onChanged: (v) {}),
                _SwitchRow(title: 'Job Status Changes', value: true, onChanged: (v) {}),
                _SwitchRow(title: 'Schedule Updates', value: true, isLast: true, onChanged: (v) {}),
              ],
            ),
          ),
          
          const SectionHeader(title: 'FINANCE'),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _SwitchRow(title: 'Payments Received', value: true, onChanged: (v) {}),
                _SwitchRow(title: 'Withdrawal Status', value: true, isLast: true, onChanged: (v) {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(child: Text(title, style: AppTypography.title.copyWith(fontSize: 15))),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.brandChampagne,
                activeTrackColor: AppColors.brandChampagne.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.divider, height: 1, indent: AppSpacing.lg),
      ],
    );
  }
}
