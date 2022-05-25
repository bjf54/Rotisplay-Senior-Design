import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  final flutterBlue = FlutterBlue.instance;
  final devicesList = <BluetoothDevice>[];

  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService>? _services;

  void _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
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
    widget.flutterBlue.startScan();
  }

  void connectToDevice() async {
    try {
      await _connectedDevice?.connect();
    } catch (e) {
      if (e.toString() != "already_connected") {
        rethrow;
      }
    } finally {
      _services = await _connectedDevice?.discoverServices();
    }
  }

  ListView _buildListViewOfDevices() {
    return ListView.builder(
        itemCount: (widget.devicesList.isEmpty) ? 2 : widget.devicesList.length,
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return const Divider();
          }

          if (widget.devicesList.isEmpty) {
            return const ListTile(title: Text("No Devices Found."));
          }

          final index = i ~/ 2;

          final device = widget.devicesList[index];

          return ListTile(
              title: Column(children: <Widget>[
            Text(
                style: const TextStyle(fontSize: 18),
                device.name == '' ? '(unknown device)' : device.name),
            Text(style: const TextStyle(fontSize: 12), device.id.toString()),
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
                    rethrow;
                  }
                } finally {
                  services = await device.discoverServices();
                }
                widget.flutterBlue.stopScan();
                setState(() {
                  _connectedDevice = device;
                  _services = services;
                });
              },
            ),
          ]));
        });
  }

  ListView _buildConnectedDeviceView() {
    final containers = <Container>[];

    for (BluetoothService service in _services!) {
      final characteristicsWidget = <Widget>[];
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristic.value.listen((value) {
          print(value);
        });
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                        'Value: ${widget.readValues[characteristic.uuid].toString()}'),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    final buttons = <ButtonTheme>[];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              // color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildView() {
    if (_connectedDevice == null) {
      return _buildListViewOfDevices();
    } else {
      connectToDevice();
      return _buildConnectedDeviceView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (_connectedDevice == null)
        ? "Bluetooth Finder"
        : _connectedDevice!.name;
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _buildView());
  }
}
