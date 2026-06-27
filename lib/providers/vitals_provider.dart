import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/session.dart';
import '../models/vital_reading.dart';
import '../services/alert_service.dart';
import '../services/ble_service.dart';
import '../services/database_service.dart';

/// ============================================================
/// Vitals Provider — Live readings, history, alerts & sessions
/// ============================================================
/// The "brain" of the app. Subscribes to BLE vital data, checks
/// for alerts, saves to database, and exposes everything to the UI.
///
/// WHAT IT EXPOSES TO THE UI:
/// - currentReading     → latest vital values for the dashboard
/// - recentReadings     → last 60 readings for the live chart
/// - activeAlerts       → current alerts to show in the banner
/// - currentSession     → the active monitoring session
/// - pastSessions       → list of past sessions for history

class VitalsProvider extends ChangeNotifier {
  final BleService _bleService;
  final DatabaseService _databaseService;

  VitalsProvider(this._bleService, this._databaseService);

  // ── State ────────────────────────────────────────────────────
  VitalReading? _currentReading;
  final List<VitalReading> _recentReadings = []; // Last 60 readings for chart
  List<VitalAlert> _activeAlerts = [];
  bool _buzzerActive = false;

  // Session state
  Session? _currentSession;
  List<Session> _pastSessions = [];

  // Subscriptions
  StreamSubscription? _vitalSub;

  // ── Getters ──────────────────────────────────────────────────
  VitalReading? get currentReading => _currentReading;
  List<VitalReading> get recentReadings => List.unmodifiable(_recentReadings);
  List<VitalAlert> get activeAlerts => List.unmodifiable(_activeAlerts);
  bool get buzzerActive => _buzzerActive;
  Session? get currentSession => _currentSession;
  List<Session> get pastSessions => List.unmodifiable(_pastSessions);
  bool get hasActiveSession => _currentSession != null;

  // ── Session Management ───────────────────────────────────────

  /// Start a new monitoring session.
  /// Call this right after BLE connection is established.
  Future<void> startSession({
    required String deviceName,
    required String deviceId,
  }) async {
    // Create session in database
    final sessionId = await _databaseService.startSession(
      deviceName: deviceName,
      deviceId: deviceId,
    );

    _currentSession = Session(
      id: sessionId,
      deviceName: deviceName,
      deviceId: deviceId,
      startTime: DateTime.now(),
    );

    // Clear previous data
    _recentReadings.clear();
    _currentReading = null;
    _activeAlerts = [];
    _buzzerActive = false;

    // Subscribe to BLE vital data
    _vitalSub?.cancel();
    await _bleService.subscribeToVitals(sessionId: sessionId);
    _vitalSub = _bleService.vitalReadings.listen(_onNewReading);

    notifyListeners();
  }

  /// End the current monitoring session.
  /// Call this when BLE disconnects.
  Future<void> endSession() async {
    if (_currentSession?.id != null) {
      await _databaseService.endSession(_currentSession!.id!);
    }

    // Turn off buzzer if it was active
    if (_buzzerActive) {
      try {
        await _bleService.sendBuzzerCommand(false);
      } catch (_) {}
      _buzzerActive = false;
    }

    _vitalSub?.cancel();
    _currentSession = null;

    // Refresh past sessions list
    await loadPastSessions();
    notifyListeners();
  }

  /// Load past sessions from the database.
  Future<void> loadPastSessions() async {
    _pastSessions = await _databaseService.getAllSessions();
    notifyListeners();
  }

  /// Get readings for a specific session (for history view).
  Future<List<VitalReading>> getSessionReadings(int sessionId) async {
    return await _databaseService.getReadingsForSession(sessionId);
  }

  // ── Private: Handle Incoming Readings ────────────────────────

  void _onNewReading(VitalReading reading) async {
    _currentReading = reading;

    // Keep last 60 readings for the live chart (≈ 1 minute at 1/sec)
    _recentReadings.add(reading);
    if (_recentReadings.length > 60) {
      _recentReadings.removeAt(0);
    }

    // Check for alerts
    _activeAlerts = AlertService.checkReading(reading);

    // Handle buzzer
    final shouldBuzz = AlertService.hasDangerAlert(_activeAlerts);
    if (shouldBuzz != _buzzerActive) {
      _buzzerActive = shouldBuzz;
      await AlertService.handleAlerts(_activeAlerts, _bleService);
    }

    // Save to database (fire-and-forget, don't block UI)
    _databaseService.saveReading(reading);

    notifyListeners();
  }

  // ── Cleanup ──────────────────────────────────────────────────

  @override
  void dispose() {
    _vitalSub?.cancel();
    super.dispose();
  }
}
