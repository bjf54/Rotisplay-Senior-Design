import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'dart:convert';

class SettingsView extends StatefulWidget {
  const SettingsView(
      {Key? key, required this.title, required this.useCharacteristic})
      : super(key: key);

  final String title;

  final BluetoothCharacteristic useCharacteristic;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  double _currentOffset = 0.0;
  double _currentBrightness = 0.0;
  bool _diplayRPM = false;

  Widget buildOffsetOption() {
    return Column(children: [
      Text("Current angular offset: ${_currentOffset.round().toString()}"),
      Slider(
        value: _currentOffset,
        max: 360,
        onChanged: (double value) {
          widget.useCharacteristic.write(
              utf8.encode("o${_currentOffset.round().toString()}"),
              withoutResponse: true);
          log("o${_currentOffset.round().toString()}!");

          setState(() {
            _currentOffset = value;
          });
        },
      )
    ]);
  }

  Widget buildBrightnessOption() {
    return Column(children: [
      Text("Current Brightness: ${_currentBrightness.round().toString()}"),
      Slider(
        value: _currentBrightness,
        max: 200,
        divisions: 200,
        onChanged: (double value) async {
          await widget.useCharacteristic.write(
              utf8.encode("b${_currentBrightness.round().toString()}"),
              withoutResponse: true);
          // log("b${_currentBrightness.round().toString()}!");

          setState(() {
            _currentBrightness = value;
          });
        },
      )
    ]);
  }

  Widget buildRPMOption() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Display RPM: "),
      Checkbox(
          checkColor: Colors.white,
          value: _diplayRPM,
          onChanged: (bool? newValue) {
            if (newValue == null) return;

            int boolValue = 0;
            if (newValue) {
              boolValue = 1;
            } else {
              boolValue = 0;
            }
            // widget.useCharacteristic
            //     .write(utf8.encode("sr${newValue.toString()}"));
            log("r${boolValue.toString()}!");
            setState(() {
              _diplayRPM = newValue;
            });
          }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildOffsetOption(),
            buildBrightnessOption(),
            // buildRPMOption(),
          ],
        ),
      ),
    );
  }
}
