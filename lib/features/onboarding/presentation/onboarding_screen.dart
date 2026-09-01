import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/premium_buttons.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.brandMidnightDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.handyman_rounded, size: 80, color: AppColors.brandChampagne),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Join the Network',
                style: AppTypography.display.copyWith(color: AppColors.brandMist),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Receive service requests, manage your jobs, and track your earnings in one place.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PremiumButton(
                label: 'Get Started',
                onPressed: () {
                  ref.read(onboardingControllerProvider.notifier).completeOnboarding();
                  context.go(AppRoutes.createAccount);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
