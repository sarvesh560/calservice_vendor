import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/presence_repository.dart';
import '../domain/presence_status.dart';

class PresenceState {
  const PresenceState({
    required this.status,
    this.isToggling = false,
    this.errorMessage,
  });

  factory PresenceState.initial() {
    return PresenceState(
      status: PresenceStatus.initialOffline(),
      isToggling: false,
    );
  }

  final PresenceStatus status;
  final bool isToggling;
  final String? errorMessage;

  bool get isOnline => status.isOnline;
  String get availability => status.availability;

  PresenceState copyWith({
    PresenceStatus? status,
    bool? isToggling,
    String? errorMessage,
  }) {
    return PresenceState(
      status: status ?? this.status,
      isToggling: isToggling ?? this.isToggling,
      errorMessage: errorMessage,
    );
  }
}

class PresenceController extends StateNotifier<PresenceState> {
  PresenceController(this._repository) : super(PresenceState.initial());

  final PresenceRepository _repository;

  /// Toggles or sets explicitly desired online/offline availability state.
  ///
  /// State is ONLY updated after server confirms the operation (server-confirmed state).
  /// Double-taps are prevented by setting `isToggling = true` during in-flight API request.
  Future<void> setOnline(bool targetState) async {
    if (state.isToggling) return; // Prevent duplicate rapid taps

    state = state.copyWith(isToggling: true, errorMessage: null);

    try {
      final updatedStatus = await _repository.setAvailability(isOnline: targetState);
      state = PresenceState(
        status: updatedStatus,
        isToggling: false,
      );
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isToggling: false,
        errorMessage: errorMsg,
      );
      rethrow;
    }
  }

  /// Called upon user logout to ensure technician availability is marked OFFLINE on backend.
  Future<void> setOfflineOnLogout() async {
    try {
      await _repository.setAvailability(isOnline: false);
    } catch (_) {
      // Best-effort cleanup on logout
    } finally {
      state = PresenceState.initial();
    }
  }

  /// Reset state to initial offline state (e.g. on fresh launch or auth reset)
  void resetToOffline() {
    state = PresenceState.initial();
  }
}

final presenceControllerProvider =
    StateNotifierProvider<PresenceController, PresenceState>((ref) {
  return PresenceController(ref.watch(presenceRepositoryProvider));
});
