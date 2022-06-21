import 'dart:io';
import 'dart:math';
import 'package:image/image.dart';

List<double> pol2cart(int r, int theta) {
  final radians = theta * (pi / 180);
  return [r * cos(radians), r * sin(radians)];
}

void main() {
  final processor = new ImageProcessor(64, "bigImage.jpg");
}

class ImageProcessor {
  int numberLEDs;
  String imgPath;

  ImageProcessor(this.numberLEDs, this.imgPath) {
    final image = decodeImage(File(this.imgPath).readAsBytesSync())!;
    final resizedImage = copyResize(image,
        width: 120, height: 120, interpolation: Interpolation.average);

    final imgData = resizedImage.data;

    final circArray = Image(64, 360);

    for (int i = 0; i < 500; i += 1) {
      circArray.data[i] = 0xffffffff;
    }

    File('test.png').writeAsBytesSync(encodePng(circArray));
  }
}
