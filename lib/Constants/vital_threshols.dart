enum VitalStatus{
  normal,warning,danger
}

class VitalThresholds {
  VitalThresholds._();

  static const double normalHeartRateLow = 60;
  static const double normalHeartRateHigh = 100;
  static const double warningHeartRateLow = 59;
  static const double warningHeartRateHigh = 101;
  static const double dangerHeartRateLow = 40;
  static const double dangerHeartRateHigh = 120;

  static const double spo2Normal = 95;
  static const double spo2Warning = 90;
  static const double spo2Danger = 85;

  static const double tempNormalLow = 36.1;
  static const double tempNormalHigh = 37.2;
  static const double tempWarningLow = 35.0;
  static const double tempWarningHigh = 38.0;
  static const double tempDangerLow = 34.0;
  static const double tempDangerHigh = 39.5;


  static VitalStatus getHeartRateStatus(double bpm) {
    if (bpm <= dangerHeartRateLow || bpm >= dangerHeartRateHigh) return VitalStatus.danger;
    if (bpm <= warningHeartRateLow || bpm >= warningHeartRateHigh) return VitalStatus.warning;
    if (bpm <= normalHeartRateLow || bpm >= normalHeartRateHigh) {return VitalStatus.normal;}
    else{return VitalStatus.warning;}
  }

  static VitalStatus getSpo2Status(double spo2percent) {
    if (spo2percent < spo2Danger) return VitalStatus.danger;
    if (spo2percent < spo2Warning) return VitalStatus.warning;
    if (spo2percent >= spo2Normal) {return VitalStatus.normal;}
    else{return VitalStatus.warning;}
  }


  static VitalStatus getTemperatureStatus(double temp) {
    if (temp <= tempDangerLow || temp >= tempDangerHigh) {
      return VitalStatus.danger;
    }
    if (temp <= tempWarningLow || temp >= tempWarningHigh) {
      return VitalStatus.warning;
    }
    if (temp >= tempNormalLow && temp <= tempNormalHigh) {
      return VitalStatus.normal;
    }
    else{return VitalStatus.warning;}
  }

}