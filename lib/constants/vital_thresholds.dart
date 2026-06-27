// ============================================================
// Vital Thresholds — Normal ranges & alert limits
// ============================================================
// Defines what counts as "normal", "warning", and "danger"
// for each vital sign. Used by AlertService to detect abnormalities.

enum VitalStatus {
  normal,  // Within healthy range
  warning, // Borderline — worth monitoring
  danger,  // Abnormal — trigger alert + buzzer
}

class VitalThresholds {
  VitalThresholds._();

  // ── Heart Rate (bpm) ─────────────────────────────────────────
  static const double hrNormalLow = 60;
  static const double hrNormalHigh = 100;
  static const double hrWarningLow = 50;   // Below this → danger
  static const double hrWarningHigh = 120; // Above this → danger
  static const double hrDangerLow = 40;    // Critical
  static const double hrDangerHigh = 150;  // Critical

  // ── SpO2 (%) ─────────────────────────────────────────────────
  static const double spo2Normal = 95;     // 95-100% is normal
  static const double spo2Warning = 90;    // 90-94% is warning
  static const double spo2Danger = 85;     // Below 85% is critical

  // ── Temperature (°C) ────────────────────────────────────────
  static const double tempNormalLow = 36.1;
  static const double tempNormalHigh = 37.2;
  static const double tempWarningLow = 35.0;
  static const double tempWarningHigh = 38.0;
  static const double tempDangerLow = 34.0;
  static const double tempDangerHigh = 39.5;

  // ── Status Checkers ──────────────────────────────────────────

  /// Returns the status for a heart rate reading.
  static VitalStatus getHeartRateStatus(double bpm) {
    if (bpm <= hrDangerLow || bpm >= hrDangerHigh) return VitalStatus.danger;
    if (bpm <= hrWarningLow || bpm >= hrWarningHigh) return VitalStatus.warning;
    if (bpm >= hrNormalLow && bpm <= hrNormalHigh) return VitalStatus.normal;
    return VitalStatus.warning; // Between warning and normal boundaries
  }

  /// Returns the status for an SpO2 reading.
  static VitalStatus getSpo2Status(double percent) {
    if (percent < spo2Danger) return VitalStatus.danger;
    if (percent < spo2Warning) return VitalStatus.warning;
    if (percent >= spo2Normal) return VitalStatus.normal;
    return VitalStatus.warning;
  }

  /// Returns the status for a temperature reading.
  static VitalStatus getTemperatureStatus(double celsius) {
    if (celsius <= tempDangerLow || celsius >= tempDangerHigh) {
      return VitalStatus.danger;
    }
    if (celsius <= tempWarningLow || celsius >= tempWarningHigh) {
      return VitalStatus.warning;
    }
    if (celsius >= tempNormalLow && celsius <= tempNormalHigh) {
      return VitalStatus.normal;
    }
    return VitalStatus.warning;
  }
}
