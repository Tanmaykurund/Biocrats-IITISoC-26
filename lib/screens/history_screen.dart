import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../models/session.dart';
import '../models/vital_reading.dart';
import '../providers/vitals_provider.dart';
import '../widgets/history_chart.dart';

/// ============================================================
/// History Screen — Browse past monitoring sessions
/// ============================================================
/// Shows a list of past sessions. Tap a session to see its
/// vital data in historical charts.

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Session? _selectedSession;
  List<VitalReading> _sessionReadings = [];
  bool _loadingReadings = false;

  // Which vital chart to show
  int _selectedVital = 0; // 0 = HR, 1 = SpO2, 2 = Temp

  @override
  void initState() {
    super.initState();
    // Load past sessions when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VitalsProvider>().loadPastSessions();
    });
  }

  Future<void> _loadSessionReadings(Session session) async {
    setState(() {
      _selectedSession = session;
      _loadingReadings = true;
    });

    final readings = await context
        .read<VitalsProvider>()
        .getSessionReadings(session.id!);

    setState(() {
      _sessionReadings = readings;
      _loadingReadings = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vitalsProvider = context.watch<VitalsProvider>();
    final sessions = vitalsProvider.pastSessions;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          const Padding(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            child: Text(
              'Session History',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (sessions.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      color: AppTheme.textMuted,
                      size: 48,
                    ),
                    SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'No sessions yet',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connect to your device to start monitoring',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: _selectedSession == null
                  ? _buildSessionList(sessions, dateFormat, timeFormat)
                  : _buildSessionDetail(dateFormat, timeFormat),
            ),
        ],
      ),
    );
  }

  // ── Session List ──────────────────────────────────────────────

  Widget _buildSessionList(
    List<Session> sessions,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final duration = session.duration;
        final durationStr = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

        return GestureDetector(
          onTap: () => _loadSessionReadings(session),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                // ── Icon ──
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    session.isActive
                        ? Icons.sensors
                        : Icons.history,
                    color: session.isActive
                        ? AppTheme.success
                        : AppTheme.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),

                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.deviceName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(session.startTime)} '
                        'at ${timeFormat.format(session.startTime)}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Duration ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      durationStr,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (session.isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Session Detail (Charts) ──────────────────────────────────

  Widget _buildSessionDetail(
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Back Button + Session Info ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _selectedSession = null;
                  _sessionReadings = [];
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedSession!.deviceName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${dateFormat.format(_selectedSession!.startTime)} '
                      '• ${_sessionReadings.length} readings',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // ── Vital Selector Tabs ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            children: [
              _VitalTab(
                label: 'Heart Rate',
                color: AppTheme.heartRateColor,
                isSelected: _selectedVital == 0,
                onTap: () => setState(() => _selectedVital = 0),
              ),
              const SizedBox(width: 8),
              _VitalTab(
                label: 'SpO2',
                color: AppTheme.spo2Color,
                isSelected: _selectedVital == 1,
                onTap: () => setState(() => _selectedVital = 1),
              ),
              const SizedBox(width: 8),
              _VitalTab(
                label: 'Temp',
                color: AppTheme.temperatureColor,
                isSelected: _selectedVital == 2,
                onTap: () => setState(() => _selectedVital = 2),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // ── Chart ──
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: _loadingReadings
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppTheme.accent,
                      ),
                    ),
                  )
                : _buildHistoryChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChart() {
    switch (_selectedVital) {
      case 0:
        return HistoryChart(
          readings: _sessionReadings,
          vitalSelector: (r) => r.heartRate,
          lineColor: AppTheme.heartRateColor,
          title: 'Heart Rate',
          unit: 'bpm',
          minY: 40,
          maxY: 160,
        );
      case 1:
        return HistoryChart(
          readings: _sessionReadings,
          vitalSelector: (r) => r.spo2,
          lineColor: AppTheme.spo2Color,
          title: 'SpO2',
          unit: '%',
          minY: 80,
          maxY: 100,
        );
      case 2:
        return HistoryChart(
          readings: _sessionReadings,
          vitalSelector: (r) => r.temperature,
          lineColor: AppTheme.temperatureColor,
          title: 'Temperature',
          unit: '°C',
          minY: 34,
          maxY: 42,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _VitalTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _VitalTab({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
