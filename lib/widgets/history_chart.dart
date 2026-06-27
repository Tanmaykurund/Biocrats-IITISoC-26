import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_theme.dart';
import '../models/vital_reading.dart';

/// ============================================================
/// History Chart — Displays past readings for a session
/// ============================================================
/// Static chart (not live-updating) for viewing historical data.
/// Shows timestamps on the X axis and values on Y axis.

class HistoryChart extends StatelessWidget {
  final List<VitalReading> readings;
  final double Function(VitalReading) vitalSelector;
  final Color lineColor;
  final String title;
  final String unit;
  final double minY;
  final double maxY;

  const HistoryChart({
    super.key,
    required this.readings,
    required this.vitalSelector,
    required this.lineColor,
    required this.title,
    required this.unit,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Row ──
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (readings.isNotEmpty) ...[
                _StatChip(
                  label: 'Avg',
                  value: _average().toStringAsFixed(1),
                  color: lineColor,
                ),
                const SizedBox(width: 6),
                _StatChip(
                  label: 'Min',
                  value: _min().toStringAsFixed(1),
                  color: AppTheme.info,
                ),
                const SizedBox(width: 6),
                _StatChip(
                  label: 'Max',
                  value: _max().toStringAsFixed(1),
                  color: AppTheme.warning,
                ),
              ],
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // ── Chart ──
          SizedBox(
            height: 180,
            child: readings.isEmpty
                ? const Center(
                    child: Text(
                      'No data for this session',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : LineChart(_buildChartData()),
          ),
        ],
      ),
    );
  }

  double _average() {
    if (readings.isEmpty) return 0;
    final sum =
        readings.fold<double>(0, (s, r) => s + vitalSelector(r));
    return sum / readings.length;
  }

  double _min() {
    if (readings.isEmpty) return 0;
    return readings
        .map((r) => vitalSelector(r))
        .reduce((a, b) => a < b ? a : b);
  }

  double _max() {
    if (readings.isEmpty) return 0;
    return readings
        .map((r) => vitalSelector(r))
        .reduce((a, b) => a > b ? a : b);
  }

  LineChartData _buildChartData() {
    final timeFormat = DateFormat('HH:mm');
    final firstTime = readings.first.timestamp.millisecondsSinceEpoch;

    // Convert readings to spots (x = seconds since start, y = value)
    final spots = readings.map((r) {
      final x = (r.timestamp.millisecondsSinceEpoch - firstTime) / 1000.0;
      return FlSpot(x, vitalSelector(r));
    }).toList();

    final maxX = spots.last.x;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.05),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: maxX > 0 ? maxX / 4 : 1,
            getTitlesWidget: (value, meta) {
              final ms = firstTime + (value * 1000).toInt();
              final time = DateTime.fromMillisecondsSinceEpoch(ms);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  timeFormat.format(time),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 9,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX > 0 ? maxX : 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: lineColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: readings.length < 50, // Show dots only for small datasets
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 2,
              color: lineColor,
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withValues(alpha: 0.2),
                lineColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.surfaceLight,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final ms = firstTime + (spot.x * 1000).toInt();
              final time = DateTime.fromMillisecondsSinceEpoch(ms);
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} $unit\n${timeFormat.format(time)}',
                TextStyle(
                  color: lineColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

/// Small stat chip showing label + value.
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
