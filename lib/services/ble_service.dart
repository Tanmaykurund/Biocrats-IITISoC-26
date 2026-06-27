import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../constants/ble_constants.dart';
import '../models/vital_reading.dart';

/// ============================================================
/// BLE Service — Handles all Bluetooth communication with ESP32
/// ============================================================
/// This is a plain Dart class (no Flutter framework dependency).
///
/// FLOW:
/// 1. startScan()   → find nearby ESP32 devices
/// 2. connect()     → establish BLE connection
/// 3. subscribeToVitals() → listen to real-time vital data
/// 4. sendBuzzerCommand() → tell ESP32 to activate/deactivate buzzer
/// 5. disconnect()  → clean up

class BleService {
  // ── Private State ────────────────────────────────────────────
  BluetoothDevice? _connectedDevice;
  final List<StreamSubscription> _subscriptions = [];
  BluetoothCharacteristic? _buzzerCharacteristic;

  // ── Stream Controllers ───────────────────────────────────────
  // These broadcast streams let multiple listeners (providers, UI) subscribe.

  final _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();
  final _vitalReadingController =
      StreamController<VitalReading>.broadcast();
  final _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();

  /// Stream of connection state changes.
  Stream<BluetoothConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Stream of parsed vital readings from ESP32.
  Stream<VitalReading> get vitalReadings => _vitalReadingController.stream;

  /// Stream of BLE scan results (discovered devices).
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  /// The currently connected device (null if not connected).
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // ── Scanning ─────────────────────────────────────────────────

  /// Start scanning for BLE devices.
  /// Results are emitted on the [scanResults] stream.
  Future<void> startScan() async {
    // Stop any ongoing scan first
    await FlutterBluePlus.stopScan();

    // Listen to scan results and filter by device name prefix
    final sub = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) {
        final name = r.device.platformName;
        return name.isNotEmpty &&
            name.startsWith(BleConstants.deviceNamePrefix);
      }).toList();
      _scanResultsController.add(filtered);
    });
    _subscriptions.add(sub);

    // Start scan with timeout
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: BleConstants.scanDurationSeconds),
    );
  }

  /// Stop scanning.
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // ── Connection ───────────────────────────────────────────────

  /// Connect to a specific BLE device.
  Future<void> connect(BluetoothDevice device) async {
    // Listen to connection state changes
    final sub = device.connectionState.listen((state) {
      _connectionStateController.add(state);

      if (state == BluetoothConnectionState.disconnected) {
        _connectedDevice = null;
        _buzzerCharacteristic = null;
      }
    });
    _subscriptions.add(sub);

    // Establish the connection
    await device.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 10),
    );
    _connectedDevice = device;
  }

  /// Disconnect from the current device.
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _buzzerCharacteristic = null;
    }
  }

  // ── Vital Data Subscription ──────────────────────────────────

  /// Discover services and subscribe to vital sign notifications.
  /// Call this AFTER connecting.
  ///
  /// The ESP32 sends raw bytes on separate characteristics:
  /// - Heart Rate:   2 bytes, uint16 LE, value × 10
  /// - SpO2:         2 bytes, uint16 LE, value × 10
  /// - Temperature:  2 bytes, uint16 LE, value × 100
  Future<void> subscribeToVitals({required int sessionId}) async {
    if (_connectedDevice == null) {
      throw StateError('Not connected to any device');
    }

    // Discover all services on the device
    final services = await _connectedDevice!.discoverServices();

    // Find our custom service
    final targetServiceGuid = Guid(BleConstants.serviceUuid);
    final service = services.firstWhere(
      (s) => s.uuid == targetServiceGuid,
      orElse: () => throw StateError(
          'Service ${BleConstants.serviceUuid} not found on device'),
    );

    // Track latest values — we build a complete VitalReading from partials
    double latestHr = 0;
    double latestSpo2 = 0;
    double latestTemp = 0;

    // Helper: emit a new VitalReading with the latest values
    void emitReading() {
      _vitalReadingController.add(VitalReading(
        sessionId: sessionId,
        heartRate: latestHr,
        spo2: latestSpo2,
        temperature: latestTemp,
        timestamp: DateTime.now(),
      ));
    }

    // Subscribe to each characteristic
    for (final char in service.characteristics) {
      final uuid = char.uuid.toString().toLowerCase();

      if (uuid == BleConstants.heartRateCharUuid.toLowerCase()) {
        // Heart Rate characteristic
        await char.setNotifyValue(true);
        final sub = char.onValueReceived.listen((value) {
          latestHr = _parseUint16(value) / 10.0;
          emitReading();
        });
        _subscriptions.add(sub);
      } else if (uuid == BleConstants.spo2CharUuid.toLowerCase()) {
        // SpO2 characteristic
        await char.setNotifyValue(true);
        final sub = char.onValueReceived.listen((value) {
          latestSpo2 = _parseUint16(value) / 10.0;
          emitReading();
        });
        _subscriptions.add(sub);
      } else if (uuid == BleConstants.temperatureCharUuid.toLowerCase()) {
        // Temperature characteristic
        await char.setNotifyValue(true);
        final sub = char.onValueReceived.listen((value) {
          latestTemp = _parseUint16(value) / 100.0;
          emitReading();
        });
        _subscriptions.add(sub);
      } else if (uuid == BleConstants.buzzerCharUuid.toLowerCase()) {
        // Save reference to buzzer characteristic for writing later
        _buzzerCharacteristic = char;
      }
    }
  }

  // ── Buzzer Control ───────────────────────────────────────────

  /// Send a command to the ESP32 to activate or deactivate the buzzer.
  Future<void> sendBuzzerCommand(bool activate) async {
    if (_buzzerCharacteristic == null) {
      throw StateError('Buzzer characteristic not found. '
          'Make sure you are connected and subscribed.');
    }

    final command = activate ? [0x01] : [0x00];
    await _buzzerCharacteristic!.write(command, withoutResponse: false);
  }

  // ── Cleanup ──────────────────────────────────────────────────

  /// Cancel all subscriptions and close stream controllers.
  /// Call this when the app is shutting down.
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _connectionStateController.close();
    _vitalReadingController.close();
    _scanResultsController.close();
  }

  // ── Private Helpers ──────────────────────────────────────────

  /// Parse 2 raw bytes as a uint16 little-endian value.
  double _parseUint16(List<int> bytes) {
    if (bytes.length < 2) return 0;
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getUint16(0, Endian.little).toDouble();
  }
}
