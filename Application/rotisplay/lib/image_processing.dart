import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:file/memory.dart';

Cartesian pol2cart(Polar pol) {
  final radians = pol.theta * (pi / 180); // convert
  return Cartesian((pol.r * cos(radians)), pol.r * sin(radians));
}

void main() {
  final imProcesser = ImageProcessor(
    numberLEDs: 70,
    fileSystem: MemoryFileSystem(),
  );
  imProcesser.run("bigImage.jpg");
}

class Cartesian {
  num x = 0, y = 0;

  Cartesian(this.x, this.y);
}

class Polar {
  num r = 0, theta = 0;

  Polar(this.r, this.theta);
}

class ImagePackage {
  ImagePackage({
    required this.circular,
    required this.reconstructed,
    this.original,
    this.average,
    this.linear,
    this.nearest,
    this.cubic,
  });

  File circular, reconstructed;
  File? original, average, linear, nearest, cubic;
}

var imgNum = 0;

class ImageProcessor {
  int numberLEDs;
  MemoryFileSystem fileSystem;

  ImageProcessor({required this.numberLEDs, required this.fileSystem});

  Future<ImagePackage> run(String imgPath,
      {img.Interpolation? interpolationType}) async {
    final image = img.decodeImage(File(imgPath).readAsBytesSync())!;

    final resizedImage = img.copyResize(
      image,
      width: 2 * numberLEDs,
      height: 2 * numberLEDs,
      interpolation: interpolationType ?? img.Interpolation.average,
    ); // average gave the cleanest look at lower resolutions

    final average = img.copyResize(
      image,
      width: 2 * numberLEDs,
      height: 2 * numberLEDs,
      interpolation: img.Interpolation.average,
    );
    final averageFile = MemoryFileSystem().file("avgImg.bmp");
    averageFile.writeAsBytesSync(img.encodeBmp(average));

    final cubic = img.copyResize(
      image,
      width: 2 * numberLEDs,
      height: 2 * numberLEDs,
      interpolation: img.Interpolation.cubic,
    );
    final cubicFile = MemoryFileSystem().file("cubicImg.bmp");
    cubicFile.writeAsBytesSync(img.encodeBmp(cubic));

    final linear = img.copyResize(
      image,
      width: 2 * numberLEDs,
      height: 2 * numberLEDs,
      interpolation: img.Interpolation.linear,
    );
    final linearFile = MemoryFileSystem().file("linearImg.bmp");
    linearFile.writeAsBytesSync(img.encodeBmp(linear));

    final nearest = img.copyResize(
      image,
      width: 2 * numberLEDs,
      height: 2 * numberLEDs,
      interpolation: img.Interpolation.nearest,
    );
    final nearestFile = MemoryFileSystem().file("nearestImg.bmp");
    nearestFile.writeAsBytesSync(img.encodeBmp(nearest));

    final imgData = resizedImage.data;

    final circArray = img.Image(numberLEDs, 360, channels: img.Channels.rgba);
    final reconstructedArray = img.Image(numberLEDs * 2, numberLEDs * 2);

    for (int angle = 0; angle < 360; angle += 1) {
      for (int mag = 0; mag < numberLEDs; mag += 1) {
        final cartCords = pol2cart(Polar(mag, angle));

        circArray.data[mag + (angle * numberLEDs)] = imgData[
            (numberLEDs + cartCords.x).round() +
                resizedImage.width * (numberLEDs + cartCords.y).round()];

        reconstructedArray[(numberLEDs + cartCords.x).round() +
                resizedImage.width * (numberLEDs + cartCords.y).round()] =
            imgData[(numberLEDs + cartCords.x).round() +
                resizedImage.width * (numberLEDs + cartCords.y).round()];
      }
    }
    final circFile = MemoryFileSystem().file("circImg$imgNum.bmp");
    circFile.writeAsBytesSync(img.encodeBmp(circArray));

    final reconstructedFile =
        MemoryFileSystem().file("reconstructedImg$imgNum.png");
    reconstructedFile.writeAsBytesSync(img.encodePng(reconstructedArray));

    imgNum += 1;
    return ImagePackage(
      circular: circFile,
      reconstructed: reconstructedFile,
      average: averageFile,
      cubic: cubicFile,
      linear: linearFile,
      nearest: nearestFile,
      original: File(imgPath),
    );
  }
}
