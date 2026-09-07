import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_motion.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../jobs/domain/job.dart';
import '../../jobs/presentation/jobs_providers.dart';
import '../../jobs/presentation/widgets/active_job_card.dart';
import '../../jobs/presentation/widgets/job_list_tile.dart';
import '../../jobs/presentation/widgets/offer_card.dart';
import '../../profile/presentation/profile_providers.dart';
import 'widgets/greeting_header.dart';
import 'widgets/today_overview_card.dart';
import '../../promotions/presentation/widgets/animated_promotion_carousel.dart';
import '../../promotions/presentation/widgets/floating_partner_promotion.dart';



/// The completely redesigned Home Screen.
/// Follows the Obsidian + Copper + Porcelain presentation layer rule.
/// Recomposes the hierarchy into a clear vertical stack with subtle
/// stagger animations for a premium feel.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AppMotion.resolve(AppMotion.normal),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: AppMotion.curve,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: AppMotion.curve,
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeJobsAsync = ref.watch(activeJobsProvider);
    final completedJobsAsync = ref.watch(completedJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Dashboard Content
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeJobsProvider);
              ref.invalidate(completedJobsProvider);
              ref.invalidate(employeeProfileProvider);
              ref.invalidate(shiftStatusProvider);
              await ref.read(activeJobsProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 110,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GreetingHeader(),
                  const SizedBox(height: AppSpacing.md),
                  const AnimatedPromotionCarousel(),
                  const SizedBox(height: AppSpacing.md),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TodayOverviewCard(
                              activeCount: activeJobsAsync.valueOrNull?.length,
                              completedCount: completedJobsAsync.valueOrNull?.length,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const _QuickActionsSection(),
                            const SizedBox(height: AppSpacing.xl),
                            AsyncValueView<List<Job>>(
                              value: activeJobsAsync,
                              onRetry: () => ref.invalidate(activeJobsProvider),
                              builder: (context, activeJobs) => _HomeJobsSection(activeJobs: activeJobs),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Persistent Floating Partner Promotion Layer
          const FloatingPartnerPromotion(
            initialExpanded: true,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionTile(
          icon: Icons.work_outline_rounded,
          label: 'Jobs Queue',
          onTap: () => context.go('/jobs'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionTile(
          icon: Icons.handyman_outlined,
          label: 'My Services',
          onTap: () => context.push('/more/services'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionTile(
          icon: Icons.insights_rounded,
          label: 'Performance',
          onTap: () => context.push('/more/performance'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionTile(
          icon: Icons.more_horiz_rounded,
          label: 'More',
          onTap: () => context.push('/more/locations'),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedPressable(
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
            boxShadow: AppElevation.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeJobsSection extends ConsumerWidget {
  const _HomeJobsSection({required this.activeJobs});

  final List<Job> activeJobs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveJob = ref.watch(hasActiveJobProvider);
    final incomingOffer = ref.watch(incomingOfferProvider);
    final currentActiveJob = ref.watch(currentActiveJobProvider);
    final completedJobs = ref.watch(completedJobsProvider).valueOrNull ?? const <Job>[];

    final remaining = activeJobs
        .where((j) => j.id != incomingOffer?.id && j.id != currentActiveJob?.id)
        .toList();
    final usingCompletedFallback = remaining.isEmpty;
    final pool = usingCompletedFallback ? completedJobs : remaining;
    final sectionTitle = usingCompletedFallback ? "TODAY's WORK" : 'UPCOMING';

    final nothingToShow = incomingOffer == null && currentActiveJob == null && pool.isEmpty;
    
    if (nothingToShow) {
      return const EmptyState(
        icon: Icons.task_alt_rounded,
        title: "You're all caught up",
        message: 'New job offers will appear here as soon as they come in.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (incomingOffer != null) ...[
          OfferCard(job: incomingOffer),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (currentActiveJob != null) ...[
          ActiveJobCard(job: currentActiveJob),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (pool.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              AnimatedPressable(
                onPressed: () => context.go('/jobs'),
                child: Text(
                  'View all',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final job in pool.take(3)) JobListTile(job: job, hasActiveJob: hasActiveJob),
        ],
      ],
    );
  }
}
