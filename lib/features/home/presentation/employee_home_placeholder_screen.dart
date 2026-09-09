import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';


/// Intentional placeholder — the real employee dashboard (jobs, GPS,
/// notifications, etc.) is built in a later phase.
class EmployeeHomePlaceholderScreen extends ConsumerWidget {
  const EmployeeHomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.tr('logout'),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 56, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                context.tr('account'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.surfaceElevated,
                ),
                textAlign: TextAlign.center,
              ),
              if (user != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${context.tr("welcome")}, ${user.displayName}',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

