import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/appearance_preferences.dart';
import 'appearance_api.dart';

class AppearanceRepository {
  AppearanceRepository(this._api, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final AppearanceApi _api;
  final FlutterSecureStorage _storage;
  static const _storageKey = 'calservice_appearance_preferences_v1';

  Future<AppearancePreferences> fetchLocalPreferences() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return AppearancePreferences.fromJson(decoded);
        }
      }
    } catch (_) {}
    return AppearancePreferences.defaults;
  }

  Future<AppearancePreferences> fetchPreferences() async {
    final local = await fetchLocalPreferences();
    try {
      final json = await _api.fetchPreferences();
      final remote = AppearancePreferences.fromJson(json);
      await saveLocalPreferences(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<void> saveLocalPreferences(AppearancePreferences preferences) async {
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(preferences.toJson()));
    } catch (_) {}
  }

  Future<AppearancePreferences> savePreferences(AppearancePreferences preferences) async {
    await saveLocalPreferences(preferences);
    try {
      final json = await _api.savePreferences(preferences.toJson());
      final saved = json['preferences'];
      if (saved is Map<String, dynamic>) {
        final updated = AppearancePreferences.fromJson(saved);
        await saveLocalPreferences(updated);
        return updated;
      }
    } catch (_) {}
    return preferences;
  }
}

final appearanceRepositoryProvider = Provider<AppearanceRepository>((ref) {
  return AppearanceRepository(ref.watch(appearanceApiProvider));
});
