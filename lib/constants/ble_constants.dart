// ============================================================
// BLE Constants — ESP32 Service & Characteristic UUIDs
// ============================================================
// Update these UUIDs to match your ESP32 firmware.
//
// HOW IT WORKS:
// The ESP32 exposes a BLE service with characteristics.
// Each characteristic sends raw bytes for a specific vital.
//
// BYTE PROTOCOL (expected from ESP32):
// ┌──────────────────────────────────────────────────────────┐
// │ Heart Rate Characteristic (2 bytes):                     │
// │   Byte 0-1: uint16 little-endian — HR in bpm × 10       │
// │   Example: 720 → 72.0 bpm → bytes [0xD0, 0x02]          │
// │                                                          │
// │ SpO2 Characteristic (2 bytes):                           │
// │   Byte 0-1: uint16 little-endian — SpO2 in % × 10       │
// │   Example: 980 → 98.0% → bytes [0xD4, 0x03]             │
// │                                                          │
// │ Temperature Characteristic (2 bytes):                    │
// │   Byte 0-1: uint16 little-endian — Temp in °C × 100     │
// │   Example: 3650 → 36.50°C → bytes [0x42, 0x0E]          │
// │                                                          │
// │ Buzzer Characteristic (1 byte, WRITE):                   │
// │   0x01 = activate buzzer                                 │
// │   0x00 = deactivate buzzer                               │
// └──────────────────────────────────────────────────────────┘

class BleConstants {
  BleConstants._();

  /// Name prefix to filter ESP32 devices during scanning.
  /// Only devices whose advertised name starts with this will be shown.
  static const String deviceNamePrefix = 'BioVitals';

  /// How long to scan for BLE devices (seconds).
  static const int scanDurationSeconds = 10;

  // ── BLE Service UUID ─────────────────────────────────────────
  // TODO: Replace with your ESP32's service UUID
  static const String serviceUuid = '12345678-1234-1234-1234-123456789abc';

  // ── Characteristic UUIDs ─────────────────────────────────────
  // TODO: Replace with your ESP32's characteristic UUIDs

  /// Heart rate — NOTIFY, 2 bytes (uint16 LE, value × 10)
  static const String heartRateCharUuid = '12345678-1234-1234-1234-123456789ab1';

  /// SpO2 — NOTIFY, 2 bytes (uint16 LE, value × 10)
  static const String spo2CharUuid = '12345678-1234-1234-1234-123456789ab2';

  /// Temperature — NOTIFY, 2 bytes (uint16 LE, value × 100)
  static const String temperatureCharUuid = '12345678-1234-1234-1234-123456789ab3';

  /// Buzzer — WRITE, 1 byte (0x01 = on, 0x00 = off)
  static const String buzzerCharUuid = '12345678-1234-1234-1234-123456789ab4';
}
