import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/animated_pressable.dart';
import '../../data/static_promotions.dart';
import '../../models/promotion_model.dart';
import '../providers/promotion_providers.dart';

/// Secondary persistent partner promotion pill attached to the right screen edge.
/// Smoothly expands into a focused campaign card panel on tap.
class FloatingPartnerPromotion extends ConsumerStatefulWidget {
  const FloatingPartnerPromotion({
    super.key,
    this.promotions = staticPromotions,
    this.onClose,
    this.initialExpanded = true,
  });

  final List<PromotionModel> promotions;
  final VoidCallback? onClose;
  final bool initialExpanded;

  @override
  ConsumerState<FloatingPartnerPromotion> createState() => _FloatingPartnerPromotionState();
}

class _FloatingPartnerPromotionState extends ConsumerState<FloatingPartnerPromotion> {
  int _currentIndex = 0;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _startPartnerRotation();
  }

  void _startPartnerRotation() {
    _rotationTimer?.cancel();
    if (widget.promotions.length <= 1) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    _rotationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final isExpanded = ref.read(promotionExpansionProvider);
      if (isExpanded) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.promotions.length;
      });
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchUrl([String? url]) async {
    final uri = Uri.parse('https://customer.caldimservices.online/');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open offers')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open offers')),
        );
      }
    }
  }

  void _toggleExpand() {
    ref.read(promotionExpansionProvider.notifier).toggle();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final isExpanded = ref.watch(promotionExpansionProvider);
    final currentPromo = widget.promotions[_currentIndex];

    return Stack(
      children: [
        // ── 1. Dimmed Backdrop when Expanded ──────────────────────────────
        if (isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpand,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),

        // ── 2. Expanded Panel Overlay ──────────────────────────────────────
        Positioned(
          right: 0,
          bottom: MediaQuery.paddingOf(context).bottom + 120,
          child: AnimatedSwitcher(
            duration: AppMotion.resolve(AppMotion.normal),
            switchInCurve: AppMotion.curve,
            switchOutCurve: AppMotion.curve,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0.4, 0.0),
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(
                position: slide,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isExpanded
                ? _ExpandedPromotionCard(
                    key: const ValueKey('expanded_card'),
                    promotion: currentPromo,
                    onClose: () {
                      ref.read(promotionExpansionProvider.notifier).collapse();
                      widget.onClose?.call();
                    },
                    onCta: () => _launchUrl(currentPromo.externalUrl),
                  )
                : const SizedBox.shrink(key: ValueKey('collapsed_empty')),
          ),
        ),
      ],
    );
  }
}

class _ExpandedPromotionCard extends StatelessWidget {
  const _ExpandedPromotionCard({
    super.key,
    required this.promotion,
    required this.onClose,
    required this.onCta,
  });

  final PromotionModel promotion;
  final VoidCallback onClose;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          promotion.logoAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surface,
                            child: Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        promotion.partnerName,
                        style: AppTypography.title.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPressable(
                onPressed: onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Artwork Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.asset(
                promotion.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: Icon(Icons.workspace_premium_rounded, size: 36, color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title & Description
          Text(
            promotion.title,
            style: AppTypography.display.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            promotion.subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // CTA Button
          AnimatedPressable(
            onPressed: onCta,
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    promotion.ctaText,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textOnPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textOnPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
