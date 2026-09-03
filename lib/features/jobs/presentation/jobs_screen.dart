import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_motion.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/job.dart';
import 'jobs_providers.dart';
import 'widgets/active_assignment_banner.dart';
import 'widgets/active_job_card.dart';
import 'widgets/authorized_services_card.dart';
import 'widgets/job_list_tile.dart';
import 'widgets/offer_card.dart';
import 'widgets/worker_status_header.dart';

enum _JobQueueTab { active, completed, all }

/// Premium Jobs Queue Screen.
class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> with SingleTickerProviderStateMixin {
  _JobQueueTab _currentTab = _JobQueueTab.active;

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

  Future<void> _refreshAll() async {
    ref.invalidate(activeJobsProvider);
    ref.invalidate(completedJobsProvider);
    ref.invalidate(employeeProfileProvider);
    ref.invalidate(shiftStatusProvider);
    await Future.wait([
      ref.read(activeJobsProvider.future),
      ref.read(completedJobsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeJobsProvider);
    final completedAsync = ref.watch(completedJobsProvider);
    final hasActiveJob = ref.watch(hasActiveJobProvider);
    final currentActiveJob = ref.watch(currentActiveJobProvider);
    final incomingOffer = ref.watch(incomingOfferProvider);

    final activeJobs = activeAsync.valueOrNull ?? const <Job>[];
    final completedJobs = completedAsync.valueOrNull ?? const <Job>[];

    final allJobsMap = <int, Job>{};
    for (final j in activeJobs) {
      allJobsMap[j.id] = j;
    }
    for (final j in completedJobs) {
      allJobsMap[j.id] = j;
    }
    final allJobs = allJobsMap.values.toList();

    final displayedJobs = switch (_currentTab) {
      _JobQueueTab.active => activeJobs,
      _JobQueueTab.completed => completedJobs,
      _JobQueueTab.all => allJobs,
    };

    final isInitialLoading = (_currentTab == _JobQueueTab.completed
            ? completedAsync.isLoading
            : activeAsync.isLoading) &&
        displayedJobs.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _JobsHeader(onRefresh: _refreshAll),
                      const SizedBox(height: AppSpacing.lg),
                      
                      const WorkerStatusHeader(),
                      const SizedBox(height: AppSpacing.md),

                      if (hasActiveJob && currentActiveJob != null) ...[
                        ActiveAssignmentBanner(job: currentActiveJob),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      const AuthorizedServicesCard(),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'JOBS QUEUE',
                        style: AppTypography.label.copyWith(
                          color: AppColors.brandMidnightDark,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.brandMist,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.brandMidnightDark.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            _TabButton(
                              title: 'Active (${activeJobs.length})',
                              isSelected: _currentTab == _JobQueueTab.active,
                              onTap: () => setState(() => _currentTab = _JobQueueTab.active),
                            ),
                            _TabButton(
                              title: 'Completed (${completedJobs.length})',
                              isSelected: _currentTab == _JobQueueTab.completed,
                              onTap: () {
                                setState(() => _currentTab = _JobQueueTab.completed);
                                ref.read(completedJobsProvider.future);
                              },
                            ),
                            _TabButton(
                              title: 'All (${allJobs.length})',
                              isSelected: _currentTab == _JobQueueTab.all,
                              onTap: () {
                                setState(() => _currentTab = _JobQueueTab.all);
                                ref.read(completedJobsProvider.future);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl * 4),
                sliver: Builder(
                      builder: (context) {
                        if (isInitialLoading) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.xxl),
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.brandChampagne),
                              ),
                            ),
                          );
                        }
                        
                        if (displayedJobs.isEmpty) {
                          return SliverToBoxAdapter(
                            child: EmptyState(
                              icon: _currentTab == _JobQueueTab.active
                                  ? Icons.inbox_outlined
                                  : (_currentTab == _JobQueueTab.completed
                                      ? Icons.task_alt_outlined
                                      : Icons.work_off_outlined),
                              title: _currentTab == _JobQueueTab.active
                                  ? 'No active jobs'
                                  : (_currentTab == _JobQueueTab.completed
                                      ? 'No completed jobs yet'
                                      : 'No jobs found'),
                              message: _currentTab == _JobQueueTab.active
                                  ? 'New exclusive job offers and dispatches will appear here automatically.'
                                  : (_currentTab == _JobQueueTab.completed
                                      ? 'Jobs you finish and confirm payment for will appear here.'
                                      : 'No assigned service requests found.'),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (_currentTab == _JobQueueTab.active) {
                                if (index == 0 && incomingOffer != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: OfferCard(job: incomingOffer),
                                  );
                                }
                                
                                final listOffset = incomingOffer != null ? 1 : 0;
                                final jobIndex = index - listOffset;
                                if (jobIndex < 0 || jobIndex >= activeJobs.where((j) => j.id != incomingOffer?.id).length) {
                                  return null;
                                }
                                
                                final job = activeJobs.where((j) => j.id != incomingOffer?.id).elementAt(jobIndex);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: job.isAssignedToCurrentEmployee && (job.id == currentActiveJob?.id)
                                      ? ActiveJobCard(job: job)
                                      : JobListTile(job: job, hasActiveJob: hasActiveJob),
                                );
                              } else {
                                final job = displayedJobs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: JobListTile(job: job, hasActiveJob: hasActiveJob),
                                );
                              }
                            },
                            childCount: _currentTab == _JobQueueTab.active
                                ? (incomingOffer != null ? 1 : 0) + activeJobs.where((j) => j.id != incomingOffer?.id).length
                                : displayedJobs.length,
                          ),
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
            ),
          ),
    );
  }
}

class _JobsHeader extends StatelessWidget {
  const _JobsHeader({required this.onRefresh});
  
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Jobs Workspace',
          style: AppTypography.headline.copyWith(
            fontSize: 20,
            color: AppColors.brandMidnight,
          ),
        ),
        AnimatedPressable(
          onPressed: onRefresh,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandChampagne.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.brandChampagne),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedPressable(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandMidnight : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandMidnight.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.brandMist : AppColors.brandMidnightDark,
            ),
          ),
        ),
      ),
    );
  }
}
