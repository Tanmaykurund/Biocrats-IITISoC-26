import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  Future scanmydevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
    }
  }

  Future<void> connectomydevice(BluetoothDevice myDevice) async {
    print(myDevice);
    await myDevice.connect(
      timeout: const Duration(seconds: 15),
      license: License.nonprofit,
    );
    myDevice.connectionState.listen((isconnected) {
      if (isconnected == BluetoothConnectionState) {
        print("device is connecting");
      } else if (isconnected == BluetoothConnectionState.connected) {
        print("device connected");
      } else {
        print("device dissconnected");
      }
    });
  }

  Stream<List<ScanResult>> get mydevices => FlutterBluePlus.scanResults;
}
