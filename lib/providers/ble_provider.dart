import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/ble_service.dart';

/// ============================================================
/// BLE Provider — Manages BLE connection state for the UI
/// ============================================================
/// Wraps BleService and exposes connection/scanning state
/// using ChangeNotifier so widgets can rebuild when state changes.
///
/// WHAT IT EXPOSES TO THE UI:
/// - isScanning         → show/hide scan indicator
/// - scanResults        → list of discovered devices
/// - connectionState    → connected / disconnected / connecting
/// - connectedDeviceName → name for the status bar
/// - isConnected        → quick boolean check

class BleProvider extends ChangeNotifier {
  final BleService _bleService;

  BleProvider(this._bleService) {
    _listenToConnectionState();
  }

  // ── State ────────────────────────────────────────────────────
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  String _connectedDeviceName = '';

  // ── Getters ──────────────────────────────────────────────────
  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothConnectionState get connectionState => _connectionState;
  String get connectedDeviceName => _connectedDeviceName;
  bool get isConnected =>
      _connectionState == BluetoothConnectionState.connected;
  BleService get bleService => _bleService;

  // ── Subscriptions ────────────────────────────────────────────
  StreamSubscription? _connectionSub;
  StreamSubscription? _scanSub;

  void _listenToConnectionState() {
    _connectionSub = _bleService.connectionState.listen((state) {
      _connectionState = state;
      if (state == BluetoothConnectionState.disconnected) {
        _connectedDeviceName = '';
      }
      notifyListeners();
    });
  }

  // ── Actions ──────────────────────────────────────────────────

  /// Start scanning for ESP32 devices.
  Future<void> startScan() async {
    _isScanning = true;
    _scanResults = [];
    notifyListeners();

    // Listen to scan results
    _scanSub?.cancel();
    _scanSub = _bleService.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    try {
      await _bleService.startScan();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Stop scanning.
  Future<void> stopScan() async {
    await _bleService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  /// Connect to a device.
  Future<void> connect(BluetoothDevice device) async {
    _connectionState = BluetoothConnectionState.connected;
    _connectedDeviceName = device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device';
    notifyListeners();

    try {
      await _bleService.connect(device);
    } catch (e) {
      _connectionState = BluetoothConnectionState.disconnected;
      _connectedDeviceName = '';
      notifyListeners();
      rethrow;
    }
  }

  /// Disconnect from the current device.
  Future<void> disconnect() async {
    await _bleService.disconnect();
    _connectionState = BluetoothConnectionState.disconnected;
    _connectedDeviceName = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _scanSub?.cancel();
    super.dispose();
  }
}
