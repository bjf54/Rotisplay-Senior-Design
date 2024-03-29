import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothConnectPage extends StatefulWidget {
  BluetoothConnectPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final flutterBlue = FlutterBlue.instance;
  final deviceList = <BluetoothDevice>[];

  @override
  State<BluetoothConnectPage> createState() => _BluetoothConnectState();
}

class BluetoothWrapper {
  BluetoothDevice device;
  List<BluetoothService> services;

  BluetoothWrapper(this.device, this.services);
}

class _BluetoothConnectState extends State<BluetoothConnectPage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService>? _services;

  @override
  void initState() {
    try {
      super.initState();
      widget.flutterBlue.connectedDevices
          .asStream()
          .listen((List<BluetoothDevice> devices) {
        for (BluetoothDevice device in devices) {
          _addDeviceToList(device);
        }
      });
      widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          _addDeviceToList(result.device);
        }
      });

      widget.flutterBlue.isScanning.listen((bool isScanning) {
        if (!isScanning) {
          widget.flutterBlue.startScan();
        }
      });
    } catch (e) {
      // log(e.toString());
    }
  }

  void _addDeviceToList(final BluetoothDevice device) {
    // if (!widget.deviceList.contains(device) &&
    // device.id.toString().contains("314")) {
    if (!widget.deviceList.contains(device) && device.name != '') {
      setState(() {
        widget.deviceList.add(device);
      });

      // log(device.type.toString());
    }
  }

  Widget _buildView() {
    return Expanded(
        child: ListView.builder(
            itemCount:
                (widget.deviceList.isEmpty) ? 2 : widget.deviceList.length,
            itemBuilder: (context, i) {
              if (i.isOdd) {
                return const Divider();
              }

              if (widget.deviceList.isEmpty) {
                return const ListTile(title: Text("No Devices Found."));
              }

              final index = i ~/ 2;

              final device = widget.deviceList[index];

              return ListTile(
                  title: Column(children: <Widget>[
                Text(
                    style: const TextStyle(fontSize: 18),
                    device.name == '' ? '(unknown device)' : device.name),
                Text(
                    style: const TextStyle(fontSize: 12), device.id.toString()),
                ElevatedButton(
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    List<BluetoothService>? services;
                    try {
                      await device.connect();
                    } catch (e) {
                      if (e.toString() != "already_connected") {
                        // rethrow;
                      }
                    }
                    services = await device.discoverServices();

                    // widget.flutterBlue.stopScan();
                    // setState(() {
                    _connectedDevice = device;
                    _services = services;
                    // });

                    if (!mounted) return;
                    // Navigator.pop(context, _connectedDevice);
                    Navigator.pop(context,
                        BluetoothWrapper(_connectedDevice!, _services!));
                  },
                ),
              ]));
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Bluetooth Connect")),
        body: Column(
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    widget.deviceList.clear();
                  });
                  // widget.flutterBlue.isScanning.listen((bool isScanning) {
                  //   if (isScanning) {
                  //     widget.flutterBlue.stopScan();
                  //   }
                  // });
                  // widget.flutterBlue
                  //     .startScan(timeout: const Duration(seconds: 5));
                },
                icon: const Icon(Icons.refresh)),
            _buildView()
          ],
        ));
  }
}
