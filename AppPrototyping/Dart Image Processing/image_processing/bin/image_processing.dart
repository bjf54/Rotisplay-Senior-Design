import 'dart:io';
import 'dart:math';
import 'package:image/image.dart';

Cartesian pol2cart(Polar pol) {
  final radians = pol.theta * (pi / 180); // convert
  return Cartesian((pol.r * cos(radians)), pol.r * sin(radians));
}

void main() {
  ImageProcessor.run(64, "bigImage.jpg");
}

class Cartesian {
  num x = 0, y = 0;

  Cartesian(this.x, this.y);
}

class Polar {
  num r = 0, theta = 0;

  Polar(this.r, this.theta);
}

class ImageProcessor {
  static void run(int numberLEDs, String imgPath) {
    final image = decodeImage(File(imgPath).readAsBytesSync())!;

    final resizedImage = copyResize(image,
        width: 2 * numberLEDs,
        height: 2 * numberLEDs,
        interpolation: Interpolation
            .average); // average gave the cleanest look at lower resolutions

    final imgData = resizedImage.data;

    final circArray = Image(64, 360, channels: Channels.rgb);

    for (int angle = 0; angle < 360; angle += 1) {
      for (int mag = 0; mag < numberLEDs; mag += 1) {
        final cartCords = pol2cart(Polar(mag, angle));

        circArray.data[mag + (angle * numberLEDs)] = imgData[
            (numberLEDs + cartCords.x).round() +
                resizedImage.width * (numberLEDs + cartCords.y).round()];
      }
    }

    // Might want to return the resulting image as a bmp here
  }
}
