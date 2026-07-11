import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_controller.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect Device',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Find and connect to your ESP32 Biovitals device',
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(255, 151, 179, 223),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF050827),
      ),
      backgroundColor: Color(0xFF050827),
      body: SafeArea(
        child: GetBuilder<BleController>(
          init: BleController(),
          builder: (BleController controller) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: StreamBuilder<List<ScanResult>>(
                      stream: FlutterBluePlus.scanResults,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              return Card(
                                elevation: 2,
                                color: const Color.fromARGB(169, 29, 45, 86),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.bluetooth,
                                    color: Color.fromARGB(202, 65, 90, 152),
                                    size: 50,
                                  ),
                                  title: Text(
                                    data.device.platformName.isNotEmpty
                                        ? data.device.platformName
                                        : "Unknown device",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        151,
                                        179,
                                        223,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    data.device.remoteId.toString(),
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        151,
                                        179,
                                        223,
                                      ),
                                    ),
                                  ),
                                  trailing: Text(data.rssi.toString()),
                                  onTap: () =>
                                      controller.connectomydevice(data.device),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bluetooth,
                                  color: Color.fromARGB(255, 151, 179, 223),
                                  size: 50,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Tap on "Scan for devices" to find your device',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 151, 179, 223),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 229, 255),
                              foregroundColor: Color.fromARGB(255, 15, 44, 47),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all(
                                Color.fromARGB(99, 5, 8, 39),
                              ),
                            ),
                        onPressed: () => controller.scanmydevices(),
                        child: const Text(
                          'Scan for devices',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF050827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ], //children
              ),
            );
          },
        ),
      ),
    );
  }
}
