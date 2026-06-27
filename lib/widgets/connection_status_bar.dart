import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../constants/app_theme.dart';

/// ============================================================
/// Connection Status Bar — Shows BLE connection state
/// ============================================================
/// A compact bar at the top of the dashboard showing:
/// - Connected (green) with device name
/// - Connecting (yellow) with loading indicator
/// - Disconnected (red) with tap-to-connect hint

class ConnectionStatusBar extends StatelessWidget {
  final BluetoothConnectionState connectionState;
  final String deviceName;
  final VoidCallback? onTap;

  const ConnectionStatusBar({
    super.key,
    required this.connectionState,
    required this.deviceName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected =
        connectionState == BluetoothConnectionState.connected;

    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String text;

    if (isConnected) {
      bgColor = AppTheme.success.withValues(alpha: 0.15);
      textColor = AppTheme.success;
      icon = Icons.bluetooth_connected;
      text = 'Connected to $deviceName';
    } else {
      bgColor = AppTheme.danger.withValues(alpha: 0.15);
      textColor = AppTheme.danger;
      icon = Icons.bluetooth_disabled;
      text = 'Disconnected — Tap to connect';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animNormal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
