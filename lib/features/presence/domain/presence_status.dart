class PresenceStatus {
  const PresenceStatus({
    required this.isOnline,
    required this.availability,
    this.message,
    this.registrationStatus,
  });

  factory PresenceStatus.fromJson(Map<String, dynamic> json) {
    return PresenceStatus(
      isOnline: json['is_online'] == true,
      availability: (json['availability'] as String?)?.toLowerCase() ?? 'offline',
      message: json['message'] as String?,
      registrationStatus: json['registration_status'] as String?,
    );
  }

  /// Initial default offline state for app launch
  factory PresenceStatus.initialOffline() {
    return const PresenceStatus(
      isOnline: false,
      availability: 'offline',
    );
  }

  final bool isOnline;
  final String availability;
  final String? message;
  final String? registrationStatus;

  PresenceStatus copyWith({
    bool? isOnline,
    String? availability,
    String? message,
    String? registrationStatus,
  }) {
    return PresenceStatus(
      isOnline: isOnline ?? this.isOnline,
      availability: availability ?? this.availability,
      message: message ?? this.message,
      registrationStatus: registrationStatus ?? this.registrationStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresenceStatus &&
          runtimeType == other.runtimeType &&
          isOnline == other.isOnline &&
          availability == other.availability;

  @override
  int get hashCode => isOnline.hashCode ^ availability.hashCode;
}
