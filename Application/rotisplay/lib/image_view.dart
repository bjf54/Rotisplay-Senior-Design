import 'package:flutter/material.dart';
import 'dart:io';

class ImageView extends StatefulWidget {
  const ImageView(this.processedImage, {Key? key, required this.title})
      : super(key: key);

  final String title;

  final File processedImage;

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Processed Image"),
      ),
      body: Center(
        child: Image.file(widget.processedImage),
      ),
    );
  }
}
