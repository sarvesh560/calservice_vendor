import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/animated_pressable.dart';
import '../../models/promotion_model.dart';

/// Single rich promotional banner with staggered entrance and continuous subtle artwork float.
class PromotionBanner extends StatefulWidget {
  const PromotionBanner({
    super.key,
    required this.promotion,
    this.isActive = true,
  });

  final PromotionModel promotion;
  final bool isActive;

  @override
  State<PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<PromotionBanner> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;

  late final Animation<double> _bgFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<Offset> _artSlide;
  late final Animation<double> _ctaScale;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _bgFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _logoScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));

    _textFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );

    _artSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
    ));

    _ctaScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    );

    _floatY = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _entranceController.forward();
    }
  }

  @override
  void didUpdateWidget(PromotionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _entranceController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.promotion.externalUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Graceful fallback if url_launcher is unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promotion;

    return FadeTransition(
      opacity: _bgFade,
      child: Container(
        height: 195,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandMidnightDark,
              const Color(0xFF0F365C),
              AppColors.brandMidnight,
            ],
          ),
          border: Border.all(
            color: AppColors.brandChampagne.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandMidnightDark.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Ambient soft decorative accent circle
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.brandChampagne.withValues(alpha: 0.15),
                        AppColors.brandChampagne.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // Left Text Column
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge & Partner Name
                          ScaleTransition(
                            scale: _logoScale,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandChampagne.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    border: Border.all(
                                      color: AppColors.brandChampagne.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    promo.badgeText,
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.brandChampagne,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '•  ${promo.partnerName}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.brandSlate,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Title & Subtitle Slide Transition
                          SlideTransition(
                            position: _textSlide,
                            child: FadeTransition(
                              opacity: _textFade,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promo.title,
                                    style: AppTypography.display.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brandMist,
                                      height: 1.15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    promo.subtitle,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 12,
                                      color: AppColors.brandSlate,
                                      height: 1.35,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // CTA Button
                          ScaleTransition(
                            scale: _ctaScale,
                            child: AnimatedPressable(
                              onPressed: _launchUrl,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.brandChampagne,
                                  borderRadius: BorderRadius.circular(AppRadius.control),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brandChampagne.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      promo.ctaText,
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.brandMidnightDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.brandMidnightDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Right Hero Artwork with Continuous Float
                    Expanded(
                      flex: 2,
                      child: SlideTransition(
                        position: _artSlide,
                        child: AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatY.value),
                              child: child,
                            );
                          },
                          child: Center(
                            child: Container(
                              height: 125,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.brandChampagne.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  promo.imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.brandMidnightDark,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 42,
                                      color: AppColors.brandChampagne,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
