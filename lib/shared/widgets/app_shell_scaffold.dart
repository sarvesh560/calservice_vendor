import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/realtime/realtime_controller.dart';
import '../../features/jobs/presentation/jobs_providers.dart';
import '../../features/promotions/data/static_promotions.dart';
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
                  context.tr('new_service_request'),
                  style: AppTypography.title.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('new_service_request_desc'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: context.tr('view'),
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

/// Custom painter for rendering the integrated bottom navigation bar matching the reference design:
/// - Straight top header band in AppColors.primary (Teal) with NO top corner curves
/// - White surface attached to the screen bottom with a smooth concave scoop around the right-side promotion badge
class NotchedTealHeaderBarPainter extends CustomPainter {
  NotchedTealHeaderBarPainter({
    required this.headerColor,
    required this.surfaceColor,
    this.headerHeight = 24.0,
    this.notchCenterRightOffset = 48.0,
    this.notchRadius = 34.0,
    this.notchDepth = 42.0,
  });

  final Color headerColor;
  final Color surfaceColor;
  final double headerHeight;
  final double notchCenterRightOffset;
  final double notchRadius;
  final double notchDepth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final notchCenterX = w - notchCenterRightOffset;

    // 1. Draw solid Teal background spanning the entire bar with a 100% straight top edge
    const topCornerRadius = 15.0;

    final headerPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, topCornerRadius)
      ..quadraticBezierTo(
        0,
        0,
        topCornerRadius,
        0,
      )
      ..lineTo(w - topCornerRadius, 0)
      ..quadraticBezierTo(
        w,
        0,
        w,
        topCornerRadius,
      )
      ..lineTo(w, h)
      ..close();

    final headerPaint = Paint()
      ..color = headerColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(headerPath, headerPaint);

    // 2. Draw white navigation surface with a smooth concave scoop on the right side
    final notchStartX = notchCenterX - notchRadius - 12;
    final notchEndX = (notchCenterX + notchRadius + 12).clamp(0.0, w);

    final surfacePath = Path()
      ..moveTo(0, h)
      ..lineTo(0, headerHeight)
      ..lineTo(notchStartX, headerHeight);

    // Smooth concave bezier curve dipping down under the circular promotion area
    surfacePath.cubicTo(
      notchStartX + 10, headerHeight,
      notchCenterX - notchRadius * 0.75, headerHeight + notchDepth,
      notchCenterX, headerHeight + notchDepth,
    );
    surfacePath.cubicTo(
      notchCenterX + notchRadius * 0.75, headerHeight + notchDepth,
      notchEndX - 10, headerHeight,
      notchEndX, headerHeight,
    );

    surfacePath.lineTo(w, headerHeight);
    surfacePath.lineTo(w, h);
    surfacePath.close();

    final surfacePaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    // Add subtle shadow over the top edge of the white surface
    canvas.drawShadow(surfacePath, Colors.black.withValues(alpha: 0.15), 4.0, false);
    canvas.drawPath(surfacePath, surfacePaint);
  }

  @override
  bool shouldRepaint(covariant NotchedTealHeaderBarPainter oldDelegate) {
    return oldDelegate.headerColor != headerColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.headerHeight != headerHeight ||
        oldDelegate.notchCenterRightOffset != notchCenterRightOffset ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.notchDepth != notchDepth;
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isPromoExpanded = ref.watch(promotionExpansionProvider);
    final promoImage = staticPromotions.isNotEmpty
        ? staticPromotions.first.imageAsset
        : 'assets/promotions/proconnect.webp';

    const barHeight = 72.0;
    final totalHeight = barHeight + bottomPadding;
    const notchCenterRightOffset = 48.0;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Integrated Notched Teal & White Surface Painter attached to screen bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: CustomPaint(
              size: Size(MediaQuery.sizeOf(context).width, totalHeight),
              painter: NotchedTealHeaderBarPainter(
                headerColor: AppColors.primary,
                surfaceColor: Colors.white,
                headerHeight: 24.0,
                notchCenterRightOffset: notchCenterRightOffset,
                notchRadius: 34.0,
                notchDepth: 40.0,
              ),
            ),
          ),

          // 2. Three Equal-Width Navigation Items (Home, Jobs, Profile)
          Positioned(
            left: 0,
            right: 88,
            bottom: bottomPadding,
            height: barHeight - 24,
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: _StandardNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: context.tr('home'),
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _StandardNavItem(
                        icon: Icons.shopping_bag_outlined,
                        activeIcon: Icons.shopping_bag_rounded,
                        label: context.tr('jobs'),
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _StandardNavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: context.tr('profile'),
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 3. Compact Floating Promotion Button (seated inside the right-side concave scoop with visible Teal frame)
          Positioned(
            right: notchCenterRightOffset - 22,
            top: 10,
            child: _PromotionFloatingButton(
              imageAsset: promoImage,
              isExpanded: isPromoExpanded && currentIndex == 0,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandardNavItem extends StatelessWidget {
  const _StandardNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return AnimatedPressable(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: isSelected ? 1.0 : 0.0,
            ),
            duration: AppMotion.resolve(const Duration(milliseconds: 300)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              final offsetY = -3.0 * value;
              final scale = 1.0 + (0.1 * value);

              return Transform.translate(
                offset: Offset(0, offsetY),
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedSwitcher(
                    duration: AppMotion.resolve(AppMotion.fast),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      size: 24,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PromotionFloatingButton extends StatelessWidget {
  const _PromotionFloatingButton({
    required this.imageAsset,
    required this.isExpanded,
    required this.onTap,
  });

  final String imageAsset;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: onTap,
      scale: 0.92,
      child: AnimatedContainer(
        duration: AppMotion.resolve(AppMotion.normal),
        curve: AppMotion.curve,
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: isExpanded
                ? AppColors.primary
                : Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

