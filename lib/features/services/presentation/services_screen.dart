import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/success_animation.dart';
import '../../profile/domain/employee_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/service_catalog.dart';
import 'services_providers.dart';

import '../../../core/localization/app_localizations.dart';

class ServicesScreen extends ConsumerStatefulWidget {

  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  static const double _cardRadius = 20;
  static const double _smallRadius = 12;

  dynamic _requestingServiceId;

  late final TextEditingController _searchController;

  String _searchQuery = '';
  bool _approvedExpanded = false;
  bool _pendingExpanded = false;
  bool _discoverExpanded = false;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    final value = _searchController.text.trim().toLowerCase();

    if (value == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = value;
    });
  }

  Future<void> _handleRequestService(
      dynamic serviceId,
      String name,
      ) async {
    if (_requestingServiceId != null) {
      return;
    }

    setState(() {
      _requestingServiceId = serviceId;
    });

    final success = await ref
        .read(servicesControllerProvider.notifier)
        .requestService(
      serviceId: serviceId,
      name: name,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _requestingServiceId = null;
    });

    if (success) {
      await SuccessAnimation.showSuccessDialog(
        context,
        title: 'Service Requested',
        message: "Request for '$name' submitted for administrative review.",
        actionLabel: 'Done',
      );
    } else {
      final error = ref.read(servicesControllerProvider).error;

      final errorMessage = error != null
          ? error.toString().replaceAll('Exception: ', '')
          : 'Failed to submit service request.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          backgroundColor: AppColors.error.base,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_smallRadius),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  errorMessage,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(employeeProfileProvider);
    ref.invalidate(serviceCatalogProvider);

    await Future.wait([
      ref.read(employeeProfileProvider.future),
      ref.read(serviceCatalogProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(employeeProfileProvider);
    final catalogAsync = ref.watch(serviceCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumSecondaryAppBar(
        title: context.tr('authorized_services'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _refresh,
        child: profileAsync.when(
          loading: () => const _ServicesLoadingState(),
          error: (error, _) => _ServicesErrorState(
            error: error,
            onRetry: () {
              ref.invalidate(employeeProfileProvider);
              ref.invalidate(serviceCatalogProvider);
            },
          ),
          data: (profile) {
            return _buildContent(
              context,
              profile,
              catalogAsync,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      EmployeeProfile profile,
      AsyncValue<List<CatalogCategory>> catalogAsync,
      ) {
    final approvedList = <_ServiceDisplayItem>[];
    final approvedIds = <String>{};

    for (final service in profile.approvedServices) {
      final id = service.id.toString();

      if (approvedIds.add(id)) {
        approvedList.add(
          _ServiceDisplayItem(
            id: service.id,
            name: service.name,
            categoryName: 'Authorized & Active',
            status: 'approved',
          ),
        );
      }
    }

    for (final service in profile.allRequestedServices) {
      final id = service.id.toString();

      if (service.status.toLowerCase() == 'approved' &&
          approvedIds.add(id)) {
        approvedList.add(
          _ServiceDisplayItem(
            id: service.id,
            name: service.name,
            categoryName:
            service.categoryName ?? 'Authorized & Active',
            status: 'approved',
          ),
        );
      }
    }

    final pendingList = <_ServiceDisplayItem>[];
    final rejectedList = <_ServiceDisplayItem>[];
    final requestedIds = <String>{...approvedIds};

    for (final service in profile.allRequestedServices) {
      final id = service.id.toString();
      final status = service.status.toLowerCase();

      requestedIds.add(id);

      if (status == 'pending') {
        pendingList.add(
          _ServiceDisplayItem(
            id: service.id,
            name: service.name,
            categoryName:
            service.categoryName ?? 'Pending Review',
            status: 'pending',
          ),
        );
      } else if (status == 'rejected') {
        rejectedList.add(
          _ServiceDisplayItem(
            id: service.id,
            name: service.name,
            categoryName:
            service.categoryName ?? 'Request Rejected',
            status: 'rejected',
            rejectionReason: service.rejectionReason,
          ),
        );
      }
    }

    final catalog =
        catalogAsync.valueOrNull ?? const <CatalogCategory>[];

    final availableCatalogList = <_ServiceDisplayItem>[];

    for (final category in catalog) {
      for (final service in category.services) {
        final id = service.id.toString();

        if (!requestedIds.contains(id)) {
          availableCatalogList.add(
            _ServiceDisplayItem(
              id: service.id,
              name: service.name,
              categoryName:
              service.categoryName ?? category.name,
              status: 'available',
              description: service.description,
            ),
          );
        }
      }
    }

    final filteredAvailable =
    _filterAvailableServices(availableCatalogList);

    final groupedAvailable =
    _groupByCategory(filteredAvailable);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _AnimatedEntry(
              index: 0,
              child: _buildPageIntro(
                activeCount: approvedList.length,
                availableCount: availableCatalogList.length,
              ),
            ),
          ),
        ),

        // ------------------------------------------------------------
        // APPROVED SERVICES
        // ------------------------------------------------------------

        if (approvedList.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedEntry(
                index: 1,
                child: _ExpandableApprovedSection(
                  expanded: _approvedExpanded,
                  services: approvedList,
                  onToggle: () {
                    setState(() {
                      _approvedExpanded = !_approvedExpanded;
                    });
                  },
                ),
              ),
            ),
          ),
        ],

        // ------------------------------------------------------------
        // EMPTY APPROVED STATE
        // ------------------------------------------------------------

        if (approvedList.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedEntry(
                index: 1,
                child: const _NoApprovedServicesCard(),
              ),
            ),
          ),

        // ------------------------------------------------------------
        // PENDING
        // ------------------------------------------------------------

        if (pendingList.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedEntry(
                index: 2,
                child: _ExpandablePendingSection(
                  expanded: _pendingExpanded,
                  services: pendingList,
                  onToggle: () {
                    setState(() {
                      _pendingExpanded = !_pendingExpanded;
                    });
                  },
                ),
              ),
            ),
          ),
        ],

        // ------------------------------------------------------------
        // REJECTED
        // ------------------------------------------------------------

        if (rejectedList.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedEntry(
                index: 3,
                child: _SectionHeader(
                  title: 'Needs attention',
                  subtitle:
                  'Review rejected requests and re-apply.',
                  trailing: _CountBadge(
                    count: rejectedList.length,
                    label: 'Rejected',
                    semantic: _BadgeSemantic.error,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverList.builder(
              itemCount: rejectedList.length,
              itemBuilder: (context, index) {
                final item = rejectedList[index];

                return _AnimatedEntry(
                  index: index,
                  child: _RejectedServiceCard(
                    item: item,
                    isRequesting:
                    _requestingServiceId == item.id,
                    onReapply: () {
                      _handleRequestService(
                        item.id,
                        item.name,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],

        // ------------------------------------------------------------
        // DISCOVER
        // ------------------------------------------------------------

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _AnimatedEntry(
              index: 4,
              child: _DiscoverHeader(
                availableCount: availableCatalogList.length,
                expanded: _discoverExpanded,
                onToggle: () {
                  setState(() {
                    _discoverExpanded = !_discoverExpanded;
                  });
                },
              ),
            ),
          ),
        ),

        if (_discoverExpanded) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _ServiceSearchField(
                controller: _searchController,
                hasServices: availableCatalogList.isNotEmpty,
                hasQuery: _searchQuery.isNotEmpty,
                onClear: () {
                  _searchController.clear();
                },
              ),
            ),
          ),

          if (catalogAsync.isLoading && catalogAsync.valueOrNull == null)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _CatalogLoadingCard(),
              ),
            )
          else if (catalogAsync.hasError && catalogAsync.valueOrNull == null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _CatalogErrorCard(
                  onRetry: () {
                    ref.invalidate(serviceCatalogProvider);
                  },
                ),
              ),
            )
          else if (availableCatalogList.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _EmptyServiceCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'All services are covered',
                  message: 'There are currently no additional services available for authorization.',
                ),
              ),
            )
          else if (filteredAvailable.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _EmptyServiceCard(
                  icon: Icons.search_off_rounded,
                  title: 'No matching services',
                  message: 'Try another service name or category.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                110,
              ),
              sliver: SliverList.builder(
                itemCount: groupedAvailable.length,
                itemBuilder: (context, index) {
                  final group = groupedAvailable[index];

                  return _AnimatedEntry(
                    index: index,
                    child: _AvailableCategory(
                      categoryName: group.categoryName,
                      services: group.services,
                      requestingServiceId: _requestingServiceId,
                      onRequest: _handleRequestService,
                      onDetails: _showServiceDetails,
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPageIntro({
    required int activeCount,
    required int availableCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMidnightDark
                .withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your services',
                  style: AppTypography.display.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'View your approved services and request access to new services.',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MiniInfo(
                      icon: Icons.verified_rounded,
                      value: '$activeCount',
                      label: 'Active',
                    ),
                    const SizedBox(width: 10),
                    _MiniInfo(
                      icon: Icons.grid_view_rounded,
                      value: '$availableCount',
                      label: 'Available',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.handyman_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  List<_ServiceDisplayItem> _filterAvailableServices(
      List<_ServiceDisplayItem> services,
      ) {
    if (_searchQuery.isEmpty) {
      return services;
    }

    return services.where((service) {
      final name = service.name.toLowerCase();
      final category =
      service.categoryName.toLowerCase();
      final description =
          service.description?.toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          category.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();
  }

  List<_ServiceCategoryGroup> _groupByCategory(
      List<_ServiceDisplayItem> services,
      ) {
    final grouped =
    <String, List<_ServiceDisplayItem>>{};

    for (final service in services) {
      final key = service.categoryName.trim().isEmpty
          ? 'Other services'
          : service.categoryName.trim();

      grouped.putIfAbsent(key, () => []).add(service);
    }

    final result = grouped.entries
        .map(
          (entry) => _ServiceCategoryGroup(
        categoryName: entry.key,
        services: entry.value,
      ),
    )
        .toList();

    result.sort(
          (a, b) => a.categoryName
          .toLowerCase()
          .compareTo(
        b.categoryName.toLowerCase(),
      ),
    );

    return result;
  }

  void _showServiceDetails(
      _ServiceDisplayItem item,
      ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _ServiceDetailsSheet(
          item: item,
          isRequesting:
          _requestingServiceId == item.id,
          onRequest: () {
            Navigator.of(context).pop();

            _handleRequestService(
              item.id,
              item.name,
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// DATA
// ============================================================================

class _ServiceDisplayItem {
  const _ServiceDisplayItem({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.status,
    this.rejectionReason,
    this.description,
  });

  final dynamic id;
  final String name;
  final String categoryName;
  final String status;
  final String? rejectionReason;
  final String? description;
}

class _ServiceCategoryGroup {
  const _ServiceCategoryGroup({
    required this.categoryName,
    required this.services,
  });

  final String categoryName;
  final List<_ServiceDisplayItem> services;
}

// ============================================================================
// PAGE INTRO
// ============================================================================

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: AppTypography.label.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PENDING SERVICES - EXPANDABLE
// ============================================================================

class _ExpandablePendingSection extends StatelessWidget {
  const _ExpandablePendingSection({
    required this.expanded,
    required this.services,
    required this.onToggle,
  });

  final bool expanded;
  final List<_ServiceDisplayItem> services;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMidnightDark.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                splashColor: AppColors.warning.tint.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 15, AppSpacing.md, 15),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.warning.tint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.warning.tintBorder),
                        ),
                        child: Icon(
                          Icons.hourglass_top_rounded,
                          size: 21,
                          color: AppColors.warning.base,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending requests',
                              style: AppTypography.headline.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${services.length} service${services.length == 1 ? '' : 's'} waiting for Admin review',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.warning.tint,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'PENDING',
                          style: AppTypography.label.copyWith(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.warning.base,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: services.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PendingServiceCard(item: item),
                  )).toList(),
                ),
              ),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 240),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// APPROVED SERVICES - EXPANDABLE
// ============================================================================

class _ExpandableApprovedSection extends StatelessWidget {
  const _ExpandableApprovedSection({
    required this.expanded,
    required this.services,
    required this.onToggle,
  });

  final bool expanded;
  final List<_ServiceDisplayItem> services;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMidnightDark
                .withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggle,
                splashColor:
                AppColors.primary.withValues(alpha: 0.04),
                highlightColor:
                AppColors.primary.withValues(alpha: 0.025),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    15,
                    AppSpacing.md,
                    15,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.075),
                          borderRadius:
                          BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.10),
                          ),
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 21,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Approved services',
                              style:
                              AppTypography.headline.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color:
                                AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${services.length} service${services.length == 1 ? '' : 's'} authorized',
                              style:
                              AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.075),
                          borderRadius:
                          BorderRadius.circular(100),
                        ),
                        child: Text(
                          'ACTIVE',
                          style:
                          AppTypography.label.copyWith(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration:
                        const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.brandSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _ApprovedServiceList(
                services: services,
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 240),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovedServiceList extends StatelessWidget {
  const _ApprovedServiceList({
    required this.services,
  });

  final List<_ServiceDisplayItem> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 1,
          color: AppColors.border.withValues(alpha: 0.55),
        ),
        for (int index = 0;
        index < services.length;
        index++) ...[
          _ApprovedServiceTile(
            item: services[index],
          ),
          if (index < services.length - 1)
            Divider(
              height: 1,
              indent: 76,
              endIndent: AppSpacing.md,
              color:
              AppColors.border.withValues(alpha: 0.5),
            ),
        ],
      ],
    );
  }
}

class _ApprovedServiceTile extends StatelessWidget {
  const _ApprovedServiceTile({
    required this.item,
  });

  final _ServiceDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      child: Row(
        children: [
          _ServiceIcon(
            item: item,
            semantic: _BadgeSemantic.success,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const StatusBadge(
            status: 'APPROVED',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY APPROVED
// ============================================================================

class _NoApprovedServicesCard extends StatelessWidget {
  const _NoApprovedServicesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandMist,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.handyman_outlined,
              color: AppColors.brandSlate,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'No approved services yet',
                  style: AppTypography.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Request a service from the catalog below to get started.',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DISCOVER HEADER
// ============================================================================

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({
    required this.availableCount,
    this.expanded = false,
    this.onToggle,
  });

  final int availableCount;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        splashColor: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover services',
                      style: AppTypography.headline.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Request authorization for services you can provide.',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (availableCount > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.075),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    '$availableCount AVAILABLE',
                    style: AppTypography.label.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              if (onToggle != null) ...[
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppColors.brandSlate,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

// ============================================================================
// COUNT BADGE
// ============================================================================

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.label,
    this.semantic = _BadgeSemantic.success,
  });

  final int count;
  final String label;
  final _BadgeSemantic semantic;

  @override
  Widget build(BuildContext context) {
    final color = _semanticColor(semantic);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.13),
        ),
      ),
      child: Text(
        '$count $label',
        style: AppTypography.label.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// PENDING
// ============================================================================

class _PendingServiceCard extends StatelessWidget {
  const _PendingServiceCard({
    required this.item,
  });

  final _ServiceDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return _ServiceCardShell(
      borderColor: AppColors.warning.tintBorder,
      accent: AppColors.warning.base,
      child: Row(
        children: [
          _ServiceIcon(
            item: item,
            semantic: _BadgeSemantic.warning,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _StatusPill(
            label: 'PENDING',
            semantic: _BadgeSemantic.warning,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REJECTED
// ============================================================================

class _RejectedServiceCard extends StatelessWidget {
  const _RejectedServiceCard({
    required this.item,
    required this.isRequesting,
    required this.onReapply,
  });

  final _ServiceDisplayItem item;
  final bool isRequesting;
  final VoidCallback onReapply;

  @override
  Widget build(BuildContext context) {
    final reason = item.rejectionReason?.trim();

    return _ServiceCardShell(
      borderColor: AppColors.error.tintBorder,
      accent: AppColors.error.base,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ServiceIcon(
                item: item,
                semantic: _BadgeSemantic.error,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTypography.headline.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _StatusPill(
                label: 'REJECTED',
                semantic: _BadgeSemantic.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.tint.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: AppColors.error.base,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason?.isNotEmpty == true
                        ? reason!
                        : 'This request was rejected by Admin.',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style:
                    AppTypography.bodySmall.copyWith(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.error.base,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: _CompactActionButton(
              label: 'Re-apply',
              icon: Icons.refresh_rounded,
              loading: isRequesting,
              onPressed: onReapply,
              outlined: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AVAILABLE CATEGORY
// ============================================================================

class _AvailableCategory extends StatelessWidget {
  const _AvailableCategory({
    required this.categoryName,
    required this.services,
    required this.requestingServiceId,
    required this.onRequest,
    required this.onDetails,
  });

  final String categoryName;
  final List<_ServiceDisplayItem> services;
  final dynamic requestingServiceId;
  final Future<void> Function(dynamic id, String name)
  onRequest;
  final void Function(_ServiceDisplayItem item)
  onDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 3,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.65,
                      color:
                      AppColors.brandMidnightDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandMist,
                    borderRadius:
                    BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${services.length}',
                    style: AppTypography.label.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border
                    .withValues(alpha: 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandMidnightDark
                      .withValues(alpha: 0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  for (int index = 0;
                  index < services.length;
                  index++) ...[
                    _AvailableServiceTile(
                      item: services[index],
                      isRequesting:
                      requestingServiceId ==
                          services[index].id,
                      onRequest: () {
                        onRequest(
                          services[index].id,
                          services[index].name,
                        );
                      },
                      onDetails: () {
                        onDetails(services[index]);
                      },
                    ),
                    if (index < services.length - 1)
                      Divider(
                        height: 1,
                        indent: 76,
                        endIndent: AppSpacing.md,
                        color: AppColors.border
                            .withValues(alpha: 0.5),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AVAILABLE SERVICE TILE
// ============================================================================

class _AvailableServiceTile extends StatelessWidget {
  const _AvailableServiceTile({
    required this.item,
    required this.isRequesting,
    required this.onRequest,
    required this.onDetails,
  });

  final _ServiceDisplayItem item;
  final bool isRequesting;
  final VoidCallback onRequest;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDetails,
        splashColor:
        AppColors.primary.withValues(alpha: 0.035),
        highlightColor:
        AppColors.primary.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 15,
          ),
          child: Row(
            children: [
              _ServiceIcon(
                item: item,
                semantic: _BadgeSemantic.neutral,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTypography.headline.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                        AppColors.brandMidnightDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description?.trim().isNotEmpty ==
                          true
                          ? item.description!.trim()
                          : item.categoryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                        height: 1.35,
                        color: AppColors.brandSlate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CompactActionButton(
                label:
                isRequesting ? 'Sending' : 'Request',
                icon: isRequesting
                    ? null
                    : Icons.arrow_forward_rounded,
                loading: isRequesting,
                onPressed: onRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARD SHELL
// ============================================================================

class _ServiceCardShell extends StatelessWidget {
  const _ServiceCardShell({
    required this.child,
    required this.borderColor,
    required this.accent,
  });

  final Widget child;
  final Color borderColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================================
// SERVICE ICON
// ============================================================================

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({
    required this.item,
    required this.semantic,
  });

  final _ServiceDisplayItem item;
  final _BadgeSemantic semantic;

  @override
  Widget build(BuildContext context) {
    final color = _semanticColor(semantic);

    final icon = _resolveServiceIcon(
      '${item.name} ${item.categoryName}',
    );

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.11),
        ),
      ),
      child: Icon(
        icon,
        size: 21,
        color: color,
      ),
    );
  }
}

// ============================================================================
// STATUS PILL
// ============================================================================

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.semantic,
  });

  final String label;
  final _BadgeSemantic semantic;

  @override
  Widget build(BuildContext context) {
    final color = _semanticColor(semantic);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.45,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// ACTION BUTTON
// ============================================================================

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final IconData? icon;
  final bool loading;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground =
    outlined ? AppColors.primary : Colors.white;

    return _PressableCard(
      onTap: loading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(
          minHeight: 37,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: outlined
              ? AppColors.surface
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: outlined
              ? Border.all(
            color: AppColors.primary
                .withValues(alpha: 0.55),
          )
              : null,
          boxShadow: outlined
              ? null
              : [
            BoxShadow(
              color: AppColors.primary
                  .withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: foreground,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 14,
                color: foreground,
              ),
            if (loading || icon != null)
              const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH
// ============================================================================

class _ServiceSearchField extends StatelessWidget {
  const _ServiceSearchField({
    required this.controller,
    required this.hasServices,
    required this.hasQuery,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasServices;
  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: hasQuery
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMidnightDark
                .withValues(
              alpha: hasQuery ? 0.04 : 0.025,
            ),
            blurRadius: hasQuery ? 20 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: hasServices,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hasServices
              ? 'Search services or categories'
              : 'No services available',
          hintStyle: AppTypography.bodySmall.copyWith(
            color:
            AppColors.brandSlate.withValues(alpha: 0.75),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: hasQuery
                ? AppColors.primary
                : AppColors.brandSlate,
          ),
          suffixIcon: hasQuery
              ? IconButton(
            onPressed: onClear,
            tooltip: 'Clear search',
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
            ),
            color: AppColors.brandSlate,
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyServiceCard extends StatelessWidget {
  const _EmptyServiceCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.brandMist,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 25,
              color: AppColors.brandSlate,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11.5,
              height: 1.45,
              color: AppColors.brandSlate,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _CatalogLoadingCard extends StatelessWidget {
  const _CatalogLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          for (int index = 0; index < 3; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom:
                index == 2 ? 0 : AppSpacing.sm,
              ),
              child: _SkeletonRow(
                widthFactor:
                0.55 + (index * 0.08),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({
    required this.widthFactor,
  });

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.brandMist,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.brandMist,
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FractionallySizedBox(
                widthFactor: 0.38,
                child: Container(
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.brandMist,
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CATALOG ERROR
// ============================================================================

class _CatalogErrorCard extends StatelessWidget {
  const _CatalogErrorCard({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.tintBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.error.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error.base,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load catalog',
                  style: AppTypography.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Please try again to view available services.',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING SCREEN
// ============================================================================

class _ServicesLoadingState extends StatelessWidget {
  const _ServicesLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        SizedBox(height: AppSpacing.sm),
        _LoadingBlock(
          widthFactor: 0.58,
          height: 27,
        ),
        SizedBox(height: 9),
        _LoadingBlock(
          widthFactor: 0.9,
          height: 12,
        ),
        SizedBox(height: AppSpacing.lg),
        _CatalogLoadingCard(),
        SizedBox(height: AppSpacing.xxl),
        _LoadingBlock(
          widthFactor: 0.42,
          height: 18,
        ),
        SizedBox(height: AppSpacing.md),
        _CatalogLoadingCard(),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({
    required this.widthFactor,
    required this.height,
  });

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.brandMist,
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR SCREEN
// ============================================================================

class _ServicesErrorState extends StatelessWidget {
  const _ServicesErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(
          height:
          MediaQuery.sizeOf(context).height * 0.20,
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.error.tintBorder,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.error.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 28,
                  color: AppColors.error.base,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Unable to load services',
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                error
                    .toString()
                    .replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text('Try again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SERVICE DETAILS SHEET
// ============================================================================

class _ServiceDetailsSheet extends StatelessWidget {
  const _ServiceDetailsSheet({
    required this.item,
    required this.isRequesting,
    required this.onRequest,
  });

  final _ServiceDisplayItem item;
  final bool isRequesting;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg +
            MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius:
                BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _ServiceIcon(
                item: item,
                semantic: _BadgeSemantic.neutral,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      AppTypography.headline.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color:
                        AppColors.brandMidnightDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.categoryName,
                      style:
                      AppTypography.bodySmall.copyWith(
                        color: AppColors.brandSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandMist,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Authorization is required before you can perform this service for customers.',
                    style:
                    AppTypography.bodySmall.copyWith(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.brandSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'About this service',
            style: AppTypography.label.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            item.description?.trim().isNotEmpty == true
                ? item.description!.trim()
                : 'Request authorization from Admin to perform this service.',
            style: AppTypography.bodySmall.copyWith(
              height: 1.5,
              color: AppColors.brandSlate,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
              isRequesting ? null : onRequest,
              icon: isRequesting
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.send_rounded,
                size: 17,
              ),
              label: Text(
                isRequesting
                    ? 'Submitting request...'
                    : 'Request authorization',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                AppColors.primary
                    .withValues(alpha: 0.55),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PRESS ANIMATION
// ============================================================================

class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  @override
  State<_PressableCard> createState() =>
      _PressableCardState();
}

class _PressableCardState
    extends State<_PressableCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || widget.onTap == null) {
      return;
    }

    if (_pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration:
        const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// ENTRY ANIMATION
// ============================================================================

class _AnimatedEntry extends StatefulWidget {
  const _AnimatedEntry({
    required this.child,
    required this.index,
  });

  final Widget child;
  final int index;

  @override
  State<_AnimatedEntry> createState() =>
      _AnimatedEntryState();
}

class _AnimatedEntryState
    extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 420),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(curve);

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (!mounted) {
          return;
        }

        final delay = Duration(
          milliseconds:
          45 * widget.index,
        );

        Future<void>.delayed(
          delay,
              () {
            if (mounted) {
              _controller.forward();
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// SEMANTIC COLORS
// ============================================================================

enum _BadgeSemantic {
  success,
  warning,
  error,
  neutral,
}

Color _semanticColor(
    _BadgeSemantic semantic,
    ) {
  switch (semantic) {
    case _BadgeSemantic.success:
      return AppColors.primary;

    case _BadgeSemantic.warning:
      return AppColors.warning.base;

    case _BadgeSemantic.error:
      return AppColors.error.base;

    case _BadgeSemantic.neutral:
      return AppColors.brandSlate;
  }
}

// ============================================================================
// SERVICE ICON RESOLUTION
// ============================================================================

IconData _resolveServiceIcon(String value) {
  final text = value.toLowerCase();

  if (text.contains('air condition') ||
      text.contains(' ac ') ||
      text.startsWith('ac ') ||
      text.contains('split ac')) {
    return Icons.ac_unit_rounded;
  }

  if (text.contains('refrigerator') ||
      text.contains('fridge')) {
    return Icons.kitchen_rounded;
  }

  if (text.contains('washing') ||
      text.contains('washer')) {
    return Icons.local_laundry_service_rounded;
  }

  if (text.contains('oven') ||
      text.contains('microwave')) {
    return Icons.microwave_rounded;
  }

  if (text.contains('plumb')) {
    return Icons.plumbing_rounded;
  }

  if (text.contains('electric')) {
    return Icons.electrical_services_rounded;
  }

  if (text.contains('paint')) {
    return Icons.format_paint_rounded;
  }

  if (text.contains('clean')) {
    return Icons.cleaning_services_rounded;
  }

  if (text.contains('pest')) {
    return Icons.pest_control_rounded;
  }

  if (text.contains('carpenter') ||
      text.contains('wood')) {
    return Icons.carpenter_rounded;
  }

  if (text.contains('appliance')) {
    return Icons.home_repair_service_rounded;
  }

  if (text.contains('repair') ||
      text.contains('maintenance')) {
    return Icons.build_circle_outlined;
  }

  if (text.contains('install')) {
    return Icons.install_mobile_rounded;
  }

  return Icons.handyman_outlined;
}