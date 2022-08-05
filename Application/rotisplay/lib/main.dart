import 'dart:developer';
import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:flutter_blue/flutter_blue.dart';

import 'package:image/image.dart' as image;

import 'dart:io';
import 'dart:convert';

import 'package:rotisplay/image_processing.dart' as image_processor;

import 'package:rotisplay/bluetooth_connect.dart';
import 'package:rotisplay/settings_page.dart';
import 'package:rotisplay/processing_page.dart';

const numberLeds = 70;

const Map<String, int> premadeImages = {
  'Dickerson': 0,
  'Pitt': 1,
  'Smile': 2,
  'Mushroom': 3,
  // 'Mushroom': 4
};

void main() {
  runApp(const Rotisplay());
}

class Rotisplay extends StatelessWidget {
  const Rotisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotisplay Application',
      // home: ProcessingOptions(
      //   title: "LoadingView",
      //   images: image_processor.ImagePackage(
      //       circular: File(""), reconstructed: File("")),
      // ),
      home: RotisplayMainPage(title: "Rotisplay"),
      builder: EasyLoading.init(),
    );
  }
}

class RotisplayMainPage extends StatefulWidget {
  RotisplayMainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final memoryFileSystem = MemoryFileSystem();

  @override
  State<RotisplayMainPage> createState() => _RotisplayMainPageState();
}

class _RotisplayMainPageState extends State<RotisplayMainPage> {
  final imagePicker = image_picker.ImagePicker();
  dynamic imagePickerError;

  image_processor.ImageProcessor? imageProcessor;

  String dropDownValue = premadeImages.keys.first;

  File? originalImage;
  // File? processedImage;
  image_processor.ImagePackage? processedImages;

  BluetoothWrapper? _connectedDevice;
  BluetoothCharacteristic? useCharacteristic;

  Future<image_processor.ImagePackage> processImage(File imageFile,
      {image.Interpolation? interpolationType}) async {
    EasyLoading.show(status: "Loading...");
    final result = await imageProcessor!
        .run(originalImage!.path, interpolationType: interpolationType);
    await EasyLoading.dismiss();
    return result;
  }

  Widget _buildImageButton(
      BuildContext context, image_picker.ImageSource imageSource, String text) {
    return ElevatedButton(
        onPressed: () async {
          // processedImages = null;
          try {
            final img = await imagePicker.pickImage(source: imageSource);

            // return if no image was picked
            if (img == null) return;

            originalImage = File(img.path);
            imageProcessor = image_processor.ImageProcessor(
                numberLEDs: numberLeds, fileSystem: widget.memoryFileSystem);

            final result = await processImage(originalImage!);
            // EasyLoading.show(status: "Loading...");
            // final result = await imageProcessor!.run(originalImage!.path);
            // await EasyLoading.dismiss();
            setState(() {
              processedImages = result;
              // If there was a previous error, itll get wiped when getting a new image
              imagePickerError = null;
            });
          } catch (e) {
            setState(() {
              imagePickerError = e;
            });
          }
        },
        child: Text(text));
  }

  Widget _buildImageSelection(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (imagePickerError != null) Text(imagePickerError.toString()),
      if (processedImages == null)
        _buildImageButton(
            context, image_picker.ImageSource.gallery, "Select Image")
      else
        ElevatedButton(
            onPressed: () async {
              final interpolType = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProcessingOptions(
                            title: "Bluetooth Connection Page",
                            images: processedImages!,
                          )));

              if (interpolType == null) return;

              image.Interpolation? interpolation;
              switch (interpolType) {
                case InterpolationTypes.average:
                  interpolation = image.Interpolation.average;
                  break;
                case InterpolationTypes.cubic:
                  interpolation = image.Interpolation.cubic;
                  break;
                case InterpolationTypes.linear:
                  interpolation = image.Interpolation.linear;
                  break;
                case InterpolationTypes.nearest:
                  interpolation = image.Interpolation.nearest;
                  break;
                default:
                  interpolation = null;
              }

              final result = await processImage(originalImage!,
                  interpolationType: interpolation);

              setState(() {
                processedImages = result;
              });
            },
            child: const Text("Image Processing Options")),
      if (processedImages == null)
        _buildImageButton(
            context, image_picker.ImageSource.camera, "Take Picture")
      else
        ElevatedButton(
            onPressed: () {
              setState(() {
                processedImages = null;
              });
            },
            child: const Text("Discard Image")),
    ]);
  }

  List<int> stringToInt(String str) {
    final intList = <int>[];

    for (int i = 0; i < str.length; i++) {
      intList.add(str.codeUnitAt(i));
    }

    return intList;
  }

  // The idea of this function is to send potential config data to device on connection
  // and to scan for the characteristic we will be communicating with
  void _sendConnectionNotification() async {
    for (BluetoothService service in _connectedDevice!.services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if ((characteristic.properties.write ||
                characteristic.properties.writeWithoutResponse) &&
            characteristic.properties.read &&
            characteristic.properties.notify) {
          // if (characteristic.properties.write == true) {
          try {
            await characteristic.write(utf8.encode("c!"),
                withoutResponse: true);
          } catch (e) {
            return;
          }
          useCharacteristic = characteristic;
        }
      }
    }
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
    _sendConnectionNotification();
  }

  Widget _buildBluetoothConnectionWidgets() {
    String? connectionStatus;
    if (_connectedDevice == null) {
      connectionStatus = "Not Connected";
    } else {
      connectionStatus = "Connected to ${_connectedDevice!.device.name}";
    }
    return Column(
      children: [
        if (_connectedDevice == null)
          ElevatedButton(
              onPressed: _getBluetoothDevice,
              child: const Text("Connect to Rotisplay"))
        else
          Column(children: [
            // ElevatedButton(
            //     onPressed: () async {
            //       await Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => SettingsView(
            //                     title: "Bluetooth Connection Page",
            //                     useCharacteristic: useCharacteristic!,
            //                   )));
            //     },
            //     child: const Text("Settings")),
            ElevatedButton(
                onPressed: () async {
                  await _connectedDevice!.device.disconnect();

                  _connectedDevice = null;
                  useCharacteristic = null;

                  setState(() {});
                },
                child: const Text("Disconnect"))
          ]),
        Text("Status: $connectionStatus"),
      ],
    );
  }

  List<Uint8List> splitImg(int mtu, Uint8List image) {
    final splitImgList = <Uint8List>[];

    int? lastIndex;

    for (int i = 0; i <= image.length - mtu; i += mtu) {
      final chunk = image.getRange(i, i + mtu);
      splitImgList.add(Uint8List.fromList(chunk.toList()));
      lastIndex = i;
    }

    final chunk = image.getRange(lastIndex!, image.length);
    splitImgList.add(Uint8List.fromList(chunk.toList()));

    return splitImgList;
  }

  Future<void> sendImage() async {
    final deviceMtu = await _connectedDevice!.device.mtu.first;

    // The -2 accounts for the brackets sent with the rest of the array
    // (since it is sent as a string ¯\_(ツ)_/¯)
    final sendList = splitImg((deviceMtu ~/ 2) - 2, processedImages!.circular.readAsBytesSync());
    // (deviceMtu ~/ 2) - 2,
    // processedImage!.readAsBytesSync());

    EasyLoading.show(status: "Transfering Image...");

    useCharacteristic!.write(utf8.encode("s!"));
    await Future.delayed(const Duration(seconds: 1));

    int numSends = 0;
    for (final packet in sendList) {
      numSends++;
      await useCharacteristic!
          // .write(utf8.encode(packet.toString()), withoutResponse: true);
          .write(packet, withoutResponse: true);
      // await useCharacteristic!
      //     .write(utf8.encode(sendList[0].toString()), withoutResponse: true);
    }

    log(numSends.toString());

    // var readRawData = <int>[];
    // final test = utf8.encode("tc!");
    // while (listEquals(readRawData, utf8.encode("tc!"))) {
    //   readRawData = await useCharacteristic!.read();
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }

    await Future.delayed(const Duration(seconds: 2));
    useCharacteristic!.write(utf8.encode("e!"));
    await EasyLoading.dismiss();
  }

  Widget _buildImageView() {
    return Column(
      children: [
        const Text(
          "Image Preview",
        ),

        SizedBox(
          height: 300,
          width: 300,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Image.file(
              processedImages!.reconstructed,
            ),
          ),
        ),
        // Image.file(processedImages!.reconstructed),
        if (_connectedDevice != null)
          ElevatedButton(
              onPressed: () async {
                await sendImage();
              },
              child: const Text("Send Image"))
        else
          const Text("Please connect to device."),
      ],
    );
  }

  Widget _buildSelectPremadeImage() {
    return Column(children: [
      DropdownButton<String>(
        value: dropDownValue,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        // style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (String? newValue) {
          // useCharacteristic!.write(utf8.encode("p$newValue!"));
          setState(() {
            dropDownValue = newValue!;
          });
        },
        items: <String>[...premadeImages.keys]
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      ElevatedButton(
          onPressed: () {
            useCharacteristic!
                .write(utf8.encode("p${premadeImages[dropDownValue]}!"));
          },
          child: const Text("Use Image")),
    ]);
  }

  Widget? buildFloatingActionButton() {
    if (processedImages == null) {
      return FloatingActionButton(
          child: const Icon(Icons.more_horiz),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProcessingOptions(
                          title: "LoadingView",
                          images: image_processor.ImagePackage(
                              circular: File(""), reconstructed: File("")),
                        )));
          });
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(),
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          if (_connectedDevice != null)
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsView(
                                  title: "Bluetooth Connection Page",
                                  useCharacteristic: useCharacteristic!,
                                )));
                  },
                  child: const Icon(
                    Icons.settings,
                    size: 26.0,
                  ),
                )),
        ],
      ),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(
          height: 20,
        ),
        _buildBluetoothConnectionWidgets(),
        if (_connectedDevice != null) _buildSelectPremadeImage(),
        const Spacer(),
        if (processedImages != null)
          // if (processedImages != null)
          _buildImageView()
        else
          const Text("No image selected."),
        const Spacer(),
        Center(
          child: _buildImageSelection(context),
        ),
        const SizedBox(
          height: 50,
        ),
      ]),
    );
  }
}
