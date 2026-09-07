import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/realtime/realtime_controller.dart';
import '../../features/jobs/presentation/jobs_providers.dart';
import '../../features/promotions/presentation/providers/promotion_providers.dart';
import 'animated_pressable.dart';

class AppShellScaffold extends ConsumerStatefulWidget {
  const AppShellScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShellScaffold> createState() => _AppShellScaffoldState();
}

class _AppShellScaffoldState extends ConsumerState<AppShellScaffold> {
  void _onTap(int index) {
    if (index == 3) {
      if (widget.navigationShell.currentIndex != 0) {
        widget.navigationShell.goBranch(0);
      }
      ref.read(promotionExpansionProvider.notifier).expand();
    } else {
      if (index == 0) {
        ref.read(promotionExpansionProvider.notifier).expand();
      }
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(realtimeControllerProvider, (previous, next) {
      if (next.isOfferCreated && next.jobId != null) {
        final jobId = next.jobId;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 6),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Service Request',
                  style: AppTypography.title.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have a new service request available.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: AppColors.primary,
              onPressed: () {
                if (jobId != null && jobId > 0) {
                  context.push('/jobs/$jobId');
                } else {
                  context.push('/jobs');
                }
              },
            ),
          ),
        );
        ref.read(realtimeControllerProvider.notifier).clearEvent();
        
        // Refresh active jobs when an offer is created
        ref.invalidate(activeJobsProvider);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: _PremiumBottomNavigation(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _PremiumBottomNavigation extends ConsumerWidget {
  const _PremiumBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isPromoExpanded = ref.watch(promotionExpansionProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.8))),
        boxShadow: AppElevation.subtle,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: context.tr('home'),
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.work_outline_rounded,
            activeIcon: Icons.work_rounded,
            label: context.tr('jobs'),
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: context.tr('profile'),
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
            label: context.tr('promo'),
            isSelected: isPromoExpanded && currentIndex == 0,
            isPromoItem: true,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isPromoItem = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isPromoItem;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.primary
        : (isPromoItem ? AppColors.primary.withValues(alpha: 0.85) : AppColors.textSecondary);
    
    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        height: 56,
        width: 68,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: isPromoItem ? const EdgeInsets.all(3) : EdgeInsets.zero,
              decoration: isPromoItem
                  ? BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: 24,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isSelected || isPromoItem ? FontWeight.w800 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
