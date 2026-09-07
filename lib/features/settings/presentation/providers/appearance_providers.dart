import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/auth_controller.dart';
import '../../data/appearance_repository.dart';
import '../../domain/appearance_preferences.dart';

/// The single source of truth for the app's live appearance. app.dart reads
/// this to build the actual MaterialApp theme, so saving here has an
/// immediate, app-wide effect — not just a stored value nobody reads.
class AppearanceController extends AsyncNotifier<AppearancePreferences> {
  @override
  Future<AppearancePreferences> build() async {
    final repo = ref.read(appearanceRepositoryProvider);
    final localPref = await repo.fetchLocalPreferences();

    final authState = ref.watch(authControllerProvider);
    final isApprovedEmployee =
        authState.status == AuthStatus.authenticated &&
        (authState.user?.isEmployee ?? false) &&
        authState.user?.registrationStatus == 'approved';

    if (!isApprovedEmployee) {
      return localPref;
    }

    try {
      return await repo.fetchPreferences();
    } catch (_) {
      return localPref;
    }
  }

  Future<void> save(AppearancePreferences preferences) async {
    final saved = await ref.read(appearanceRepositoryProvider).savePreferences(preferences);
    state = AsyncData(saved);
  }
}

final appearanceControllerProvider =
    AsyncNotifierProvider<AppearanceController, AppearancePreferences>(AppearanceController.new);

/// Safe-default accessor for widgets that just need to render (e.g. app.dart
/// building the theme) without caring about loading/error state.
final currentAppearanceProvider = Provider<AppearancePreferences>((ref) {
  return ref.watch(appearanceControllerProvider).valueOrNull ?? AppearancePreferences.defaults;
});
