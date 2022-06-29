import 'dart:io';
import 'package:image/image.dart';

int calculate() {
  return 6 * 7;
}

void main(List<String> args) {
  final image = decodeImage(File("bigImage.jpg").readAsBytesSync());

  print(image!.data[0]);
}
