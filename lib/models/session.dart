// ============================================================
// Session — One monitoring session (connect → disconnect)
// ============================================================
// A session represents a period of continuous monitoring.
// Created when user connects to ESP32, ended on disconnect.

class Session {
  final int? id;          // SQLite row ID
  final String deviceName;
  final String deviceId;  // BLE device address
  final DateTime startTime;
  final DateTime? endTime; // null while session is active

  const Session({
    this.id,
    required this.deviceName,
    required this.deviceId,
    required this.startTime,
    this.endTime,
  });

  /// Whether this session is still in progress.
  bool get isActive => endTime == null;

  /// Duration of the session. Returns elapsed time if still active.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Create from a SQLite row map.
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int?,
      deviceName: map['device_name'] as String,
      deviceId: map['device_id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : null,
    );
  }

  /// Convert to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'device_name': deviceName,
      'device_id': deviceId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with some fields changed.
  Session copyWith({
    int? id,
    String? deviceName,
    String? deviceId,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Session(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'Session(device: $deviceName, start: $startTime, '
        'end: ${endTime ?? "active"})';
  }
}
