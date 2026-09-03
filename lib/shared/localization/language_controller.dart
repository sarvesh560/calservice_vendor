import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/data/language_storage.dart';

class LanguageController extends StateNotifier<String> {
  LanguageController(this._storage) : super('en') {
    _loadSavedLanguage();
  }

  final LanguageStorage _storage;

  Future<void> _loadSavedLanguage() async {
    final code = await _storage.getLanguageCode();
    state = code;
  }

  Future<void> setLanguage(String code) async {
    if (['en', 'ta', 'hi'].contains(code)) {
      state = code;
      await _storage.setLanguageCode(code);
    }
  }
}

final languageControllerProvider =
    StateNotifierProvider<LanguageController, String>((ref) {
  return LanguageController(ref.watch(languageStorageProvider));
});
