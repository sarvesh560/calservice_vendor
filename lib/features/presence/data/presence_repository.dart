import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../domain/presence_status.dart';
import 'presence_api.dart';

class PresenceRepository {
  PresenceRepository(this._api);

  final PresenceApi _api;

  Future<PresenceStatus> setAvailability({required bool isOnline}) async {
    try {
      return await _api.toggleOnline(isOnline: isOnline);
    } on DioException catch (e) {
      throw describeDioError(
        e,
        fallback: 'Unable to update availability status. Please try again.',
      );
    } catch (e) {
      if (e is String) rethrow;
      throw 'Unable to update availability status. Please try again.';
    }
  }

  Future<PresenceStatus> fetchStatus() async {
    try {
      return await _api.getStatus();
    } catch (_) {
      return PresenceStatus.initialOffline();
    }
  }
}

final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  return PresenceRepository(ref.watch(presenceApiProvider));
});
