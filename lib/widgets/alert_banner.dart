import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../constants/vital_thresholds.dart';
import '../services/alert_service.dart';

/// ============================================================
/// Alert Banner — Shows abnormal reading warnings
/// ============================================================
/// Slides down from the top when alerts are active.
/// Displays each alert with its severity level.

class AlertBanner extends StatelessWidget {
  final List<VitalAlert> alerts;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.alerts,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final hasDanger = alerts.any((a) => a.status == VitalStatus.danger);
    final bgColor = hasDanger
        ? AppTheme.danger.withValues(alpha: 0.15)
        : AppTheme.warning.withValues(alpha: 0.15);
    final borderColor = hasDanger
        ? AppTheme.danger.withValues(alpha: 0.5)
        : AppTheme.warning.withValues(alpha: 0.5);
    final iconColor = hasDanger ? AppTheme.danger : AppTheme.warning;

    return AnimatedSize(
      duration: AppTheme.animNormal,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingSm + 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Row(
              children: [
                Icon(
                  hasDanger ? Icons.warning_amber_rounded : Icons.info_outline,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasDanger ? 'Abnormal Reading Detected!' : 'Warning',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(
                      Icons.close,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // ── Alert Messages ──
            ...alerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: alert.status == VitalStatus.danger
                              ? AppTheme.danger
                              : AppTheme.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.message,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
