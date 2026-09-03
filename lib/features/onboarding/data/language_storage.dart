import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistent storage for the user's selected app language preference.
class LanguageStorage {
  LanguageStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _languageKey = 'sevo_selected_language_v1';

  /// Reads the saved language code ('en', 'ta', 'hi'). Defaults to 'en' if not set.
  Future<String> getLanguageCode() async {
    try {
      final code = await _storage.read(key: _languageKey);
      if (code != null && ['en', 'ta', 'hi'].contains(code)) {
        return code;
      }
      return 'en';
    } catch (_) {
      return 'en';
    }
  }

  /// Persists the selected language code.
  Future<void> setLanguageCode(String code) async {
    try {
      await _storage.write(key: _languageKey, value: code);
    } catch (_) {}
  }
}

final languageStorageProvider =
    Provider<LanguageStorage>((ref) => LanguageStorage());
