import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/settings_row.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../profile/presentation/profile_providers.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(employeeProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Services', style: AppTypography.titleLarge),
        backgroundColor: AppColors.surface,
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: ')),
        data: (profile) {
          final services = profile.approvedServices;
          if (services.isEmpty) return const Center(child: Text('No services authorized yet.'));
          return Container(
            color: AppColors.surface,
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return SettingsRow(
                  icon: Icons.handyman_outlined,
                  title: s.name,
                  subtitle: 'Authorized',
                  trailing: const StatusBadge(status: 'APPROVED'),
                  isLast: index == services.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
