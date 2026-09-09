import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import 'auth_controller.dart';

/// Native Flutter Create Account screen matching [ServicesScreen] design architecture.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final mobileNumber = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() => _errorMessage = context.tr('passwords_do_not_match'));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signup(
            firstName: firstName,
            lastName: lastName.isNotEmpty ? lastName : null,
            mobileNumber: mobileNumber,
            email: email,
            password: password,
          );
    } on DioException catch (e) {
      debugPrint('[WORKFORCE SIGNUP ERROR] ${e.response?.statusCode}: ${e.response?.data}');
      if (mounted) {
        setState(
          () => _errorMessage = describeDioError(
            e,
            fallback: context.tr('signup_failed'),
          ),
        );
      }
    } catch (e) {
      debugPrint('[WORKFORCE SIGNUP UNEXPECTED ERROR] $e');
      if (mounted) {
        setState(
          () => _errorMessage = context.tr('signup_failed'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumSecondaryAppBar(
        title: context.tr('create_account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 1. Page Introduction ─
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.75),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandMidnightDark.withValues(alpha: 0.035),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('create_technician'),
                            style: AppTypography.display.copyWith(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.12,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            context.tr('create_account_subtitle'),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('vendor_network_tag'),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Error Banner ──────────────────────────────────────────
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.error.tint,
                          border: Border.all(color: AppColors.error.tintBorder),
                          borderRadius: BorderRadius.circular(AppRadius.control),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error.base),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error.base,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _errorMessage = null),
                              child: Icon(Icons.close_rounded, size: 16, color: AppColors.error.base),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Form Section 1: Account Details ───────────────────────
                    _FormCardSection(
                      title: context.tr('personal_details'),
                      icon: Icons.person_outline_rounded,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          decoration: _inputDecoration(context.tr('first_name'), Icons.badge_outlined),
                          validator: (v) => v == null || v.trim().isEmpty ? context.tr('first_name_required') : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _lastNameController,
                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          decoration: _inputDecoration(context.tr('last_name'), Icons.badge_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Form Section 2: Contact Details ───────────────────────
                    _FormCardSection(
                      title: context.tr('contact_details'),
                      icon: Icons.contact_mail_outlined,
                      children: [
                        TextFormField(
                          controller: _mobileController,
                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(context.tr('mobile_number'), Icons.phone_outlined),
                          validator: (v) => v == null || v.trim().isEmpty ? context.tr('mobile_number_required') : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _emailController,
                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(context.tr('email_address'), Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return context.tr('email_address_required');
                            if (!v.contains('@')) return context.tr('valid_email_required');
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Form Section 3: Security Credentials ──────────────────
                    _FormCardSection(
                      title: context.tr('account_security'),
                      icon: Icons.lock_outline_rounded,
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            context.tr('password'),
                            Icons.key_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return context.tr('password_required');
                            if (v.length < 6) return context.tr('password_min_length');
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            context.tr('confirm_password'),
                            Icons.key_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty ? context.tr('confirm_password_required') : null,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Primary Action Button ─────────────────────────────────
                    AnimatedPressable(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.control),
                          border: Border.all(color: AppColors.primary),
                        ),
                        alignment: Alignment.center,
                        child: _isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Text(
                                context.tr('create_account_continue'),
                                style: AppTypography.label.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Sign In Footer ─────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('already_have_account'),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            context.tr('sign_in'),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData prefixIcon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceMuted.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.error.base),
      ),
    );
  }
}

class _FormCardSection extends StatelessWidget {
  const _FormCardSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMidnightDark.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}
