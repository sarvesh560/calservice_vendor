import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/presence_status.dart';

class PresenceApi {
  PresenceApi(this._dio);

  final Dio _dio;

  /// Toggle or set explicit online/offline availability state.
  /// Backend endpoint: POST /workforce/presence/toggle-online/
  Future<PresenceStatus> toggleOnline({bool? isOnline}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workforce/presence/toggle-online/',
      data: isOnline != null ? {'is_online': isOnline} : null,
    );
    return PresenceStatus.fromJson(response.data!);
  }

  /// Get current technician presence status from backend.
  /// Backend endpoint: GET /workforce/presence/status/
  Future<PresenceStatus> getStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workforce/presence/status/',
    );
    return PresenceStatus.fromJson(response.data!);
  }
}

final presenceApiProvider = Provider<PresenceApi>((ref) {
  return PresenceApi(ref.watch(apiClientProvider));
});
