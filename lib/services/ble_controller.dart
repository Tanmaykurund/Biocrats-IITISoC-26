import '../Constants/ble_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';



class BleController extends GetxController {

  BluetoothService? myservice;
  BluetoothCharacteristic? mycharacteristics;

  int? bpm;
  int? spo2percent;
  double? temp;

  bool isConnected = false;

  final List<StreamSubscription> mySubs = [];

  Future<void> scanmydevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
    } else {
      print("⚠️ BLE permissions not granted:");
    }
  }

  Stream<List<ScanResult>> get mydevices => FlutterBluePlus.scanResults;

  Future<void> connectomydevice(BluetoothDevice myDevice) async {
    print(myDevice);
    try {
      await myDevice.connect(
        timeout: const Duration(seconds: 15),
        license: License.nonprofit,
      );

      mySubs.add(myDevice.connectionState.listen((state) {
        isConnected = state == BluetoothConnectionState.connected;
        print(isConnected ? "device connected" : "device disconnected");
        update();
      }));

      final myservices = await myDevice.discoverServices();

      for (final service in myservices) {
        print("Service: ${service.uuid}");
        for (final char in service.characteristics) {
          print("  Char: ${char.uuid}  "
              "notify=${char.properties.notify} "
              "write=${char.properties.write} "
              "read=${char.properties.read}");
        }
      }

      for(final service in myservices){
        if(service.uuid.toString().toLowerCase() == bleconstants.ServiceUUID.toLowerCase()){
          print("service found ✅");
          myservice = service;

          for (final char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() ==
                bleconstants.CharacteristicUUID.toLowerCase()) {
              mycharacteristics = char;
              print("characteristic found ✅: ${char.uuid}");
            }
          }
        }
      }

      if (mycharacteristics == null){
        print("⚠️ Expected characteristic not found on this device.");
        return;
      }
      await subscribeToNotifications();
    }catch (e) {
      print('Connection failed: $e');}
    }
  Future<void> subscribeToNotifications() async{
    await mycharacteristics!.setNotifyValue(true);
    
    mySubs.add(mycharacteristics!.lastValueStream.listen((bytes) {
      if (bytes.length < bleconstants.bytesize) {
        print("⚠️ Unexpected packet length: ${bytes.length}");
        return;
      }
      bpm = bytes[0];
      spo2percent = bytes[1];
      final rawTempe = bytes[2] | (bytes[3]<<8);
      temp = rawTempe / 10.0;
      
      print('HR $bpm SpO2: $spo2percent% Temp: $temp°C');
      update();
    }));
  }
  @override
  void onClose() {
    for (final s in mySubs) {
      s.cancel();
    }
    super.onClose();
  }
}