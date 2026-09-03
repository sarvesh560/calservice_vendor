import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/animated_pressable.dart';
import '../../data/static_promotions.dart';
import '../../models/promotion_model.dart';

/// Secondary persistent partner promotion pill attached to the right screen edge.
/// Smoothly expands into a focused campaign card panel on tap.
class FloatingPartnerPromotion extends StatefulWidget {
  const FloatingPartnerPromotion({
    super.key,
    this.promotions = staticPromotions,
  });

  final List<PromotionModel> promotions;

  @override
  State<FloatingPartnerPromotion> createState() => _FloatingPartnerPromotionState();
}

class _FloatingPartnerPromotionState extends State<FloatingPartnerPromotion> with TickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _rotationTimer;
  bool _isExpanded = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseX;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseX = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startPartnerRotation();
  }

  void _startPartnerRotation() {
    _rotationTimer?.cancel();
    if (widget.promotions.length <= 1) return;

    _rotationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || _isExpanded) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.promotions.length;
      });
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentPromo = widget.promotions[_currentIndex];

    return Stack(
      children: [
        // ── 1. Dimmed Backdrop when Expanded ──────────────────────────────
        if (_isExpanded)
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

        // ── 2. Floating Edge Pill & Expanded Panel ─────────────────────────
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
            child: _isExpanded
                ? _ExpandedPromotionCard(
                    key: const ValueKey('expanded_card'),
                    promotion: currentPromo,
                    onClose: _toggleExpand,
                    onCta: () => _launchUrl(currentPromo.externalUrl),
                  )
                : AnimatedBuilder(
                    key: const ValueKey('collapsed_pill'),
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_pulseX.value, 0),
                        child: child,
                      );
                    },
                    child: _CollapsedEdgePill(
                      promotion: currentPromo,
                      onTap: _toggleExpand,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CollapsedEdgePill extends StatelessWidget {
  const _CollapsedEdgePill({
    required this.promotion,
    required this.onTap,
  });

  final PromotionModel promotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        width: 68,
        height: 98,
        decoration: BoxDecoration(
          color: AppColors.brandMidnightDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          border: Border(
            top: BorderSide(color: AppColors.brandChampagne.withValues(alpha: 0.5)),
            left: BorderSide(color: AppColors.brandChampagne.withValues(alpha: 0.5)),
            bottom: BorderSide(color: AppColors.brandChampagne.withValues(alpha: 0.5)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(-2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 6, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.brandChampagne.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'PROMO',
                style: AppTypography.label.copyWith(
                  color: AppColors.brandChampagne,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandChampagne.withValues(alpha: 0.5)),
              ),
              child: ClipOval(
                child: Image.asset(
                  promotion.logoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.brandMidnight,
                    child: const Icon(Icons.star_rounded, size: 18, color: AppColors.brandChampagne),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                promotion.partnerName,
                key: ValueKey<String>(promotion.partnerName),
                style: AppTypography.label.copyWith(
                  color: AppColors.brandMist,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
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
        color: AppColors.brandMidnightDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandChampagne.withValues(alpha: 0.5)),
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
                        border: Border.all(color: AppColors.brandChampagne.withValues(alpha: 0.4)),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          promotion.logoAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.brandMidnight,
                            child: const Icon(Icons.star_rounded, size: 14, color: AppColors.brandChampagne),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        promotion.partnerName,
                        style: AppTypography.title.copyWith(
                          color: AppColors.brandMist,
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
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.brandSlate),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
                  color: AppColors.brandMidnight,
                  alignment: Alignment.center,
                  child: const Icon(Icons.workspace_premium_rounded, size: 36, color: AppColors.brandChampagne),
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
              color: AppColors.brandMist,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            promotion.subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.brandSlate,
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
                color: AppColors.brandChampagne,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    promotion.ctaText,
                    style: AppTypography.label.copyWith(
                      color: AppColors.brandMidnightDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.brandMidnightDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
