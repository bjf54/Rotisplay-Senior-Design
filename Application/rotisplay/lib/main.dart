import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:flutter_blue/flutter_blue.dart';

import 'dart:io';

import './image_processing.dart' as image_processor;

import './bluetooth_connect.dart';
import './image_view.dart';

const numberLeds = 64;

void main() {
  runApp(const Rotisplay());
}

class Rotisplay extends StatelessWidget {
  const Rotisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Rotisplay Application',
      home: RotisplayMainPage(title: "Rotisplay"),
    );
  }
}

class RotisplayMainPage extends StatefulWidget {
  const RotisplayMainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RotisplayMainPage> createState() => _RotisplayMainPageState();
}

class _RotisplayMainPageState extends State<RotisplayMainPage> {
  final imagePicker = image_picker.ImagePicker();
  dynamic imagePickerError;

  File? originalImage;
  File? processedImage;

  BluetoothDevice? _connectedDevice;

  Widget _buildImageButton(
      BuildContext context, image_picker.ImageSource imageSource, String text) {
    return ElevatedButton(
        onPressed: () async {
          try {
            final img = await imagePicker.pickImage(source: imageSource);
            // imagePath = File(img!.path);
            setState(() {
              originalImage = File(img!.path);
              processedImage = image_processor.ImageProcessor.run(
                  numberLEDs: numberLeds, imgPath: originalImage!.path);
            });
          } catch (e) {
            setState(() {
              imagePickerError = e;
            });
          }

          if (!mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ImageView(processedImage!, title: "Image View")));
        },
        child: Text(text));
  }

  Widget _buildImageSelection(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (imagePickerError != null) Text(imagePickerError.toString()),
      _buildImageButton(
          context, image_picker.ImageSource.gallery, "Select Image"),
      _buildImageButton(
          context, image_picker.ImageSource.camera, "Take Picture"),
    ]);
  }

  void _getBluetoothDevice() async {
    final device = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BluetoothConnectPage(title: "Bluetooth Connection Page")));
    if (device == null) return;
    setState(() {
      _connectedDevice = device;
    });
  }

  Widget _buildBluetoothConnectionWidgets() {
    String? connectionStatus;
    if (_connectedDevice == null) {
      connectionStatus = "Not Connected";
    } else {
      connectionStatus = "Connected to ${_connectedDevice!.name}";
    }
    return Column(
      children: [
        ElevatedButton(
            onPressed: _getBluetoothDevice,
            child: const Text("Connect to Rotisplay")),
        Text("Status: $connectionStatus"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildBluetoothConnectionWidgets(),
          Center(
            child: _buildImageSelection(context),
          ),
        ]));
  }
}
