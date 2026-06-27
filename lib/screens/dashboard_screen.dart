import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../constants/vital_thresholds.dart';
import '../providers/ble_provider.dart';
import '../providers/vitals_provider.dart';
import '../widgets/alert_banner.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/live_chart.dart';
import '../widgets/vital_card.dart';

/// ============================================================
/// Dashboard Screen — Main screen showing live vital data
/// ============================================================
/// Displays:
/// - Connection status bar
/// - Alert banner (when abnormal readings detected)
/// - 3 vital cards (HR, SpO2, Temp)
/// - Real-time chart (togglable between vitals)

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToConnection;

  const DashboardScreen({
    super.key,
    required this.onNavigateToConnection,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Which vital is shown in the chart
  int _selectedChartIndex = 0; // 0 = HR, 1 = SpO2, 2 = Temp

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();
    final vitalsProvider = context.watch<VitalsProvider>();
    final reading = vitalsProvider.currentReading;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Connection Status ──
            ConnectionStatusBar(
              connectionState: bleProvider.connectionState,
              deviceName: bleProvider.connectedDeviceName,
              onTap: widget.onNavigateToConnection,
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // ── Alert Banner ──
            AlertBanner(alerts: vitalsProvider.activeAlerts),

            // ── Session Info ──
            if (vitalsProvider.hasActiveSession) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Session active • ${vitalsProvider.recentReadings.length} readings',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppTheme.spacingMd),

            // ── Vital Cards Grid ──
            Row(
              children: [
                Expanded(
                  child: VitalCard(
                    title: 'Heart Rate',
                    value: reading?.heartRate,
                    unit: 'bpm',
                    icon: Icons.favorite_rounded,
                    color: AppTheme.heartRateColor,
                    status: reading != null
                        ? VitalThresholds.getHeartRateStatus(reading.heartRate)
                        : VitalStatus.normal,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: VitalCard(
                    title: 'SpO2',
                    value: reading?.spo2,
                    unit: '%',
                    icon: Icons.air_rounded,
                    color: AppTheme.spo2Color,
                    status: reading != null
                        ? VitalThresholds.getSpo2Status(reading.spo2)
                        : VitalStatus.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingSm),

            // Temperature card (full width)
            VitalCard(
              title: 'Temperature',
              value: reading?.temperature,
              unit: '°C',
              icon: Icons.thermostat_rounded,
              color: AppTheme.temperatureColor,
              status: reading != null
                  ? VitalThresholds.getTemperatureStatus(reading.temperature)
                  : VitalStatus.normal,
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // ── Chart Selector Tabs ──
            Row(
              children: [
                _ChartTab(
                  label: 'HR',
                  color: AppTheme.heartRateColor,
                  isSelected: _selectedChartIndex == 0,
                  onTap: () => setState(() => _selectedChartIndex = 0),
                ),
                const SizedBox(width: 8),
                _ChartTab(
                  label: 'SpO2',
                  color: AppTheme.spo2Color,
                  isSelected: _selectedChartIndex == 1,
                  onTap: () => setState(() => _selectedChartIndex = 1),
                ),
                const SizedBox(width: 8),
                _ChartTab(
                  label: 'Temp',
                  color: AppTheme.temperatureColor,
                  isSelected: _selectedChartIndex == 2,
                  onTap: () => setState(() => _selectedChartIndex = 2),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingSm),

            // ── Live Chart ──
            _buildChart(vitalsProvider),

            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(VitalsProvider vitalsProvider) {
    switch (_selectedChartIndex) {
      case 0:
        return LiveChart(
          readings: vitalsProvider.recentReadings,
          vitalSelector: (r) => r.heartRate,
          lineColor: AppTheme.heartRateColor,
          title: 'Heart Rate',
          unit: 'bpm',
          minY: 40,
          maxY: 160,
        );
      case 1:
        return LiveChart(
          readings: vitalsProvider.recentReadings,
          vitalSelector: (r) => r.spo2,
          lineColor: AppTheme.spo2Color,
          title: 'SpO2',
          unit: '%',
          minY: 80,
          maxY: 100,
        );
      case 2:
        return LiveChart(
          readings: vitalsProvider.recentReadings,
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

/// Tab button for selecting which vital to show in the chart.
class _ChartTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTab({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppTheme.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
