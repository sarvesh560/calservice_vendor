import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/localization/language_controller.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../../shared/widgets/premium_buttons.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    (
      image: 'assets/images/onboarding/img.png',
      title: 'Join CalService Network',
      description: 'Connect with thousands of customers needing verified expert service technicians in your area.',
    ),
    (
      image: 'assets/images/onboarding/img_1.png',
      title: 'Manage Jobs & Dispatch',
      description: 'Receive real-time job offers, accept assignments, update your status, and complete work effortlessly.',
    ),
    (
      image: 'assets/images/onboarding/img_2.png',
      title: 'Instant Earnings & Payouts',
      description: 'Track your daily earnings, manage your bank accounts, and request instant wallet withdrawals anytime.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    context.go(AppRoutes.createAccount);
  }

  void _showLanguageSelector(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.brandMidnight),
                ),
                const SizedBox(height: AppSpacing.md),
                _LanguageTile(
                  code: 'en',
                  label: 'English',
                  isSelected: currentLang == 'en',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('en');
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageTile(
                  code: 'ta',
                  label: 'தமிழ் (Tamil)',
                  isSelected: currentLang == 'ta',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('ta');
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageTile(
                  code: 'hi',
                  label: 'हिन्दी (Hindi)',
                  isSelected: currentLang == 'hi',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('hi');
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageControllerProvider);
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.brandMidnightDark,
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingHeader(
              currentLang: currentLang,
              isLastPage: isLastPage,
              onOpenLanguage: () => _showLanguageSelector(context, currentLang),
              onSkip: _onFinish,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    slide: _slides[index],
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),
            _OnboardingFooter(
              slideCount: _slides.length,
              currentPage: _currentPage,
              isLastPage: isLastPage,
              onFinish: _onFinish,
              onSkip: _onFinish,
              onNext: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.currentLang,
    required this.isLastPage,
    required this.onOpenLanguage,
    required this.onSkip,
  });

  final String currentLang;
  final bool isLastPage;
  final VoidCallback onOpenLanguage;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final langLabel = switch (currentLang) {
      'ta' => 'தமிழ்',
      'hi' => 'हिन्दी',
      _ => 'English',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedPressable(
            onPressed: onOpenLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: AppColors.brandChampagne.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, size: 16, color: AppColors.brandChampagne),
                  const SizedBox(width: 6),
                  Text(
                    langLabel,
                    style: AppTypography.label.copyWith(color: AppColors.brandMist),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.brandMist),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.slide,
    required this.isActive,
  });

  final ({String description, String image, String title}) slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Eyebrow
              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: isActive ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.brandChampagne.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'CALSERVICE VENDOR',
                    style: AppTypography.label.copyWith(
                      color: AppColors.brandChampagne,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Image container with entrance motion
              Flexible(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  scale: isActive ? 1.0 : 0.9,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 380),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sheet),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppElevation.elevated,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Image.asset(
                          slide.image,
                          key: ValueKey(slide.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.brandMist,
                              child: const Center(
                                child: Icon(
                                  Icons.handyman_rounded,
                                  size: 72,
                                  color: AppColors.brandChampagne,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl * 1.5),
              // Animated Text Details
              AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuad,
                offset: isActive ? Offset.zero : const Offset(0, 0.1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: isActive ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      Text(
                        slide.title,
                        style: AppTypography.display.copyWith(
                          color: AppColors.brandMist,
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        slide.description,
                        style: AppTypography.body.copyWith(
                          color: AppColors.brandSlate,
                          height: 1.5,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.slideCount,
    required this.currentPage,
    required this.isLastPage,
    required this.onFinish,
    required this.onNext,
    required this.onSkip,
  });

  final int slideCount;
  final int currentPage;
  final bool isLastPage;
  final VoidCallback onFinish;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '0${currentPage + 1}',
                style: AppTypography.label.copyWith(
                  color: AppColors.brandChampagne,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ...List.generate(
                slideCount,
                (index) {
                  final isActive = currentPage == index;
                  final isPast = index <= currentPage;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 2,
                    width: isActive ? 24 : 12,
                    decoration: BoxDecoration(
                      color: isPast
                          ? AppColors.brandChampagne
                          : AppColors.brandSlate.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          PremiumButton(
            label: isLastPage ? 'Get Started' : 'Next',
            onPressed: isLastPage ? onFinish : onNext,
          ),
          if (!isLastPage)
            AnimatedPressable(
              onPressed: onSkip,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Skip for now',
                  style: AppTypography.label.copyWith(
                    color: AppColors.brandSlate,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: AppSpacing.sm + 18),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        label,
        style: AppTypography.title.copyWith(
          color: isSelected ? AppColors.brandChampagne : AppColors.brandMidnight,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.brandChampagne)
          : null,
    );
  }
}
