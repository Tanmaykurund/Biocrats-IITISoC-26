import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../constants/vital_thresholds.dart';

/// ============================================================
/// Vital Card — Displays a single vital reading
/// ============================================================
/// Shows: icon, vital name, current value, unit, and status color.
/// Pulses with a glow effect when status is danger.
///
/// USAGE:
///   VitalCard(
///     title: 'Heart Rate',
///     value: 72.0,
///     unit: 'bpm',
///     icon: Icons.favorite,
///     color: AppTheme.heartRateColor,
///     status: VitalStatus.normal,
///   )

class VitalCard extends StatefulWidget {
  final String title;
  final double? value;   // null when no reading yet
  final String unit;
  final IconData icon;
  final Color color;
  final VitalStatus status;

  const VitalCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
  });

  @override
  State<VitalCard> createState() => _VitalCardState();
}

class _VitalCardState extends State<VitalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulsing if initially in danger
    if (widget.status == VitalStatus.danger) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VitalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start/stop pulsing based on danger status
    if (widget.status == VitalStatus.danger) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case VitalStatus.normal:
        return AppTheme.success;
      case VitalStatus.warning:
        return AppTheme.warning;
      case VitalStatus.danger:
        return AppTheme.danger;
    }
  }

  String get _statusLabel {
    switch (widget.status) {
      case VitalStatus.normal:
        return 'Normal';
      case VitalStatus.warning:
        return 'Warning';
      case VitalStatus.danger:
        return 'Alert!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        // Glow intensity: 0 when normal, pulsing when danger
        final glowOpacity = widget.status == VitalStatus.danger
            ? 0.2 + (_pulseAnimation.value * 0.3)
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.status == VitalStatus.danger
                  ? AppTheme.danger.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.08),
              width: widget.status == VitalStatus.danger ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (widget.status == VitalStatus.danger)
                BoxShadow(
                  color: AppTheme.danger.withValues(alpha: glowOpacity),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Icon + Status ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingSm),

              // ── Title ──
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXs),

              // ── Value + Unit ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: AppTheme.animFast,
                    child: Text(
                      widget.value != null
                          ? widget.value!.toStringAsFixed(
                              widget.unit == 'bpm' ? 0 : 1)
                          : '--',
                      key: ValueKey(widget.value),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      widget.unit,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
