import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/vital_reading.dart';

/// ============================================================
/// Live Chart — Real-time scrolling line chart
/// ============================================================
/// Displays the last N vital readings as a live-updating chart.
/// Auto-scrolls as new data arrives.
///
/// USAGE:
///   LiveChart(
///     readings: vitalsProvider.recentReadings,
///     vitalSelector: (r) => r.heartRate,
///     lineColor: AppTheme.heartRateColor,
///     title: 'Heart Rate',
///     unit: 'bpm',
///     minY: 40,
///     maxY: 160,
///   )

class LiveChart extends StatelessWidget {
  final List<VitalReading> readings;
  final double Function(VitalReading) vitalSelector; // Which vital to plot
  final Color lineColor;
  final String title;
  final String unit;
  final double minY;
  final double maxY;

  const LiveChart({
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
          // ── Chart Title ──
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
              Text(
                'Last ${readings.length} readings',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // ── Chart ──
          SizedBox(
            height: 150,
            child: readings.isEmpty
                ? const Center(
                    child: Text(
                      'Waiting for data...',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : LineChart(
                    _buildChartData(),
                    duration: AppTheme.animFast,
                  ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    // Convert readings to chart spots (x = index, y = value)
    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      spots.add(FlSpot(i.toDouble(), vitalSelector(readings[i])));
    }

    return LineChartData(
      // Grid
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.05),
          strokeWidth: 1,
        ),
      ),

      // Axes
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
        // Hide other axis labels for clean look
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      // Border
      borderData: FlBorderData(show: false),

      // Range
      minX: 0,
      maxX: (readings.length - 1).toDouble().clamp(1, double.infinity),
      minY: minY,
      maxY: maxY,

      // Line appearance
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: lineColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false), // No dots for clean look
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withValues(alpha: 0.3),
                lineColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],

      // Touch interaction
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.surfaceLight,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} $unit',
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
