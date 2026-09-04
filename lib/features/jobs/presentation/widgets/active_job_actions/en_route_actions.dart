import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/location/location_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/premium_buttons.dart';
import '../../../domain/job.dart';
import '../../jobs_providers.dart';
import '../../../data/job_actions_repository.dart';

class EnRouteActions extends ConsumerStatefulWidget {
  const EnRouteActions({super.key, required this.job});
  final Job job;

  @override
  ConsumerState<EnRouteActions> createState() => _EnRouteActionsState();
}

class _EnRouteActionsState extends ConsumerState<EnRouteActions> {
  bool _isLoading = false;
  String? _error;

  Future<void> _verifyArrival() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pos = await LocationService().getCurrentPosition();
      final lat = pos.latitude;
      final lng = pos.longitude;

      if (!mounted) return;

      final repo = ref.read(jobActionsRepositoryProvider);
      await repo.verifyArrival(widget.job.id, lat: lat, lon: lng);
      
      if (!mounted) return;
      
      ref.invalidate(activeJobsProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigate() async {
    final lat = widget.job.latitude ?? 20.5937;
    final lng = widget.job.longitude ?? 78.9629;
    final url = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final fallbackUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.job.latitude;
    final lng = widget.job.longitude;
    final hasCoords = lat != null && lng != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.error.tintBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error.base, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.error.base),
                  ),
                ),
              ],
            ),
          ),
        
        if (hasCoords)
          Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'online.caldimservices.vendor',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_pin,
                        size: 36,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        PremiumButton(
          onPressed: _isLoading ? null : _verifyArrival,
          label: 'Verify Arrival',
          icon: Icons.check_circle_outline,
          isLoading: _isLoading,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          onPressed: _navigate,
          label: 'Navigate to Customer',
          icon: Icons.navigation_rounded,
        ),
      ],
    );
  }
}
