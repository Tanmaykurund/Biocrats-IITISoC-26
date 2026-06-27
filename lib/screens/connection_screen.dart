import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../providers/ble_provider.dart';
import '../providers/vitals_provider.dart';

/// ============================================================
/// Connection Screen — Scan, connect, disconnect BLE devices
/// ============================================================
/// Shows:
/// - Scan button with loading indicator
/// - List of discovered devices with signal strength
/// - Connect/Disconnect toggle
/// - Connection status

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();
    final vitalsProvider = context.read<VitalsProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            const Text(
              'Connect Device',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Find and connect to your ESP32 BioVitals device',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // ── Connected Device Info ──
            if (bleProvider.isConnected) ...[
              _ConnectedDeviceCard(
                deviceName: bleProvider.connectedDeviceName,
                onDisconnect: () async {
                  await vitalsProvider.endSession();
                  await bleProvider.disconnect();
                },
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],

            // ── Scan Button ──
            if (!bleProvider.isConnected)
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed:
                      bleProvider.isScanning ? null : bleProvider.startScan,
                  icon: bleProvider.isScanning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.background,
                          ),
                        )
                      : const Icon(Icons.bluetooth_searching, size: 20),
                  label: Text(
                    bleProvider.isScanning
                        ? 'Scanning...'
                        : 'Scan for Devices',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppTheme.spacingMd),

            // ── Scan Results ──
            if (bleProvider.scanResults.isNotEmpty &&
                !bleProvider.isConnected) ...[
              Text(
                'Found ${bleProvider.scanResults.length} device(s)',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],

            // Device List
            if (!bleProvider.isConnected)
              Expanded(
                child: bleProvider.scanResults.isEmpty
                    ? _EmptyState(isScanning: bleProvider.isScanning)
                    : ListView.builder(
                        itemCount: bleProvider.scanResults.length,
                        itemBuilder: (context, index) {
                          final result = bleProvider.scanResults[index];
                          return _DeviceListItem(
                            result: result,
                            onConnect: () => _connectToDevice(
                              context,
                              bleProvider,
                              vitalsProvider,
                              result,
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectToDevice(
    BuildContext context,
    BleProvider bleProvider,
    VitalsProvider vitalsProvider,
    ScanResult result,
  ) async {
    try {
      // Stop scanning
      await bleProvider.stopScan();

      // Connect
      await bleProvider.connect(result.device);

      // Start a new monitoring session
      await vitalsProvider.startSession(
        deviceName: result.device.platformName.isNotEmpty
            ? result.device.platformName
            : 'ESP32 Device',
        deviceId: result.device.remoteId.str,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}

// ── Subwidgets ──────────────────────────────────────────────────

class _ConnectedDeviceCard extends StatelessWidget {
  final String deviceName;
  final VoidCallback onDisconnect;

  const _ConnectedDeviceCard({
    required this.deviceName,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.bluetooth_connected,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Connected • Receiving data',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onDisconnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _DeviceListItem extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onConnect;

  const _DeviceListItem({
    required this.result,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final name = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : 'Unknown Device';
    final rssi = result.rssi;
    final signalStrength = _rssiToStrength(rssi);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: AppTheme.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingXs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(
            Icons.bluetooth,
            color: AppTheme.accent,
            size: 22,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Signal: $signalStrength ($rssi dBm)',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onConnect,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: AppTheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
          child: const Text('Connect'),
        ),
      ),
    );
  }

  String _rssiToStrength(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -70) return 'Good';
    if (rssi >= -85) return 'Fair';
    return 'Weak';
  }
}

class _EmptyState extends StatelessWidget {
  final bool isScanning;

  const _EmptyState({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
            color: AppTheme.textMuted,
            size: 48,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            isScanning
                ? 'Searching for devices...'
                : 'Tap "Scan for Devices" to find your ESP32',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
