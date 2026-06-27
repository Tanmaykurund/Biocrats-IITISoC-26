// ============================================================
// VitalReading — A single snapshot of all vital signs
// ============================================================
// Represents one reading from the ESP32 at a point in time.
// Stored in SQLite and displayed on charts.

class VitalReading {
  final int? id;          // SQLite row ID (null before saving)
  final int sessionId;    // Which session this belongs to
  final double heartRate; // bpm
  final double spo2;      // percentage (0-100)
  final double temperature; // °C
  final DateTime timestamp;

  const VitalReading({
    this.id,
    required this.sessionId,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.timestamp,
  });

  /// Create from a SQLite row map.
  factory VitalReading.fromMap(Map<String, dynamic> map) {
    return VitalReading(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      heartRate: (map['heart_rate'] as num).toDouble(),
      spo2: (map['spo2'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  /// Convert to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'heart_rate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with some fields changed.
  VitalReading copyWith({
    int? id,
    int? sessionId,
    double? heartRate,
    double? spo2,
    double? temperature,
    DateTime? timestamp,
  }) {
    return VitalReading(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      temperature: temperature ?? this.temperature,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'VitalReading(HR: $heartRate bpm, SpO2: $spo2%, Temp: $temperature°C, '
        'time: $timestamp)';
  }
}
