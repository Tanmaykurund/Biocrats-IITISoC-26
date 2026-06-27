import '../constants/vital_thresholds.dart';
import '../models/vital_reading.dart';
import 'ble_service.dart';

/// ============================================================
/// Alert Service — Detects abnormal vitals & triggers buzzer
/// ============================================================
/// Pure logic class. Takes a VitalReading, checks thresholds,
/// returns alerts, and optionally tells ESP32 to buzz.

/// Represents a single alert for one vital sign.
class VitalAlert {
  final String vitalName;   // "Heart Rate", "SpO2", "Temperature"
  final double value;        // The reading that triggered the alert
  final String unit;         // "bpm", "%", "°C"
  final VitalStatus status;  // warning or danger
  final String message;      // Human-readable alert text

  const VitalAlert({
    required this.vitalName,
    required this.value,
    required this.unit,
    required this.status,
    required this.message,
  });

  @override
  String toString() => '$vitalName: $message';
}

class AlertService {
  AlertService._();

  /// Check a reading against all thresholds.
  /// Returns a list of alerts (empty list = all normal).
  static List<VitalAlert> checkReading(VitalReading reading) {
    final alerts = <VitalAlert>[];

    // ── Heart Rate ──────────────────────────────────────────
    final hrStatus = VitalThresholds.getHeartRateStatus(reading.heartRate);
    if (hrStatus != VitalStatus.normal) {
      final label = reading.heartRate > VitalThresholds.hrNormalHigh
          ? 'High'
          : 'Low';
      alerts.add(VitalAlert(
        vitalName: 'Heart Rate',
        value: reading.heartRate,
        unit: 'bpm',
        status: hrStatus,
        message: '$label Heart Rate: ${reading.heartRate.toStringAsFixed(0)} bpm',
      ));
    }

    // ── SpO2 ────────────────────────────────────────────────
    final spo2Status = VitalThresholds.getSpo2Status(reading.spo2);
    if (spo2Status != VitalStatus.normal) {
      alerts.add(VitalAlert(
        vitalName: 'SpO2',
        value: reading.spo2,
        unit: '%',
        status: spo2Status,
        message: 'Low SpO2: ${reading.spo2.toStringAsFixed(1)}%',
      ));
    }

    // ── Temperature ─────────────────────────────────────────
    final tempStatus =
        VitalThresholds.getTemperatureStatus(reading.temperature);
    if (tempStatus != VitalStatus.normal) {
      final label =
          reading.temperature > VitalThresholds.tempNormalHigh ? 'High' : 'Low';
      alerts.add(VitalAlert(
        vitalName: 'Temperature',
        value: reading.temperature,
        unit: '°C',
        status: tempStatus,
        message:
            '$label Temperature: ${reading.temperature.toStringAsFixed(1)}°C',
      ));
    }

    return alerts;
  }

  /// Check if any alert is at danger level (requires buzzer).
  static bool hasDangerAlert(List<VitalAlert> alerts) {
    return alerts.any((a) => a.status == VitalStatus.danger);
  }

  /// Trigger buzzer on the ESP32 if a danger-level alert exists.
  /// Returns true if buzzer was activated.
  static Future<bool> handleAlerts(
    List<VitalAlert> alerts,
    BleService bleService,
  ) async {
    if (hasDangerAlert(alerts)) {
      try {
        await bleService.sendBuzzerCommand(true);
        return true;
      } catch (e) {
        // Buzzer command failed — log but don't crash
        // The visual alert in the app still shows
        return false;
      }
    } else {
      // No danger alerts — make sure buzzer is off
      try {
        await bleService.sendBuzzerCommand(false);
      } catch (_) {
        // Ignore errors when turning off buzzer
      }
      return false;
    }
  }
}
