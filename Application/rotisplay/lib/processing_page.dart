import 'package:flutter/material.dart';
import 'package:rotisplay/image_processing.dart';

import 'dart:io';

const bigDickerson = AssetImage("images/bigImage.jpg");
const averageDickerson = AssetImage("images/average.bmp");
const cubicDickerson = AssetImage("images/cubic.bmp");
const linearDickerson = AssetImage("images/linear.bmp");
const nearestDickerson = AssetImage("images/nearest.bmp");

enum InterpolationTypes { none, average, cubic, linear, nearest }

class ProcessingOptions extends StatefulWidget {
  const ProcessingOptions({
    Key? key,
    required this.title,
    required this.images,
  }) : super(key: key);

  final String title;

  final ImagePackage images;

  @override
  State<ProcessingOptions> createState() => _ProcessingOptionsState();
}

class _ProcessingOptionsState extends State<ProcessingOptions> {
  InterpolationTypes currentSelection = InterpolationTypes.none;

  Widget showImage(
    AssetImage assetImage, {
    File? fileImage,
    BoxFit? fit = BoxFit.scaleDown,
    String? caption,
    double? width,
    double? height,
  }) {
    return Column(
      children: [
        fileImage == null
            ? Image(
                width: width,
                image: assetImage,
                fit: fit,
              )
            : Image.file(
                fileImage,
                width: width,
                fit: fit,
              ),
        if (caption != null)
          Text(
            caption,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget buildImageButton(
      String caption, bool isSelected, AssetImage assetImage,
      {File? fileImage, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: isSelected ? Border.all(width: 3) : null,
        ),
        child: showImage(
          assetImage,
          fileImage: fileImage,
          caption: caption,
        ),
      ),
    );
  }

  Widget buildImageOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildImageButton(
                "Average",
                currentSelection == InterpolationTypes.average,
                averageDickerson,
                fileImage: widget.images.average, onTap: () {
              setState(() {
                currentSelection = InterpolationTypes.average;
              });
            }),
            buildImageButton("Cubic",
                currentSelection == InterpolationTypes.cubic, cubicDickerson,
                fileImage: widget.images.cubic, onTap: () {
              setState(() {
                currentSelection = InterpolationTypes.cubic;
              });
            }),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildImageButton("Linear",
                currentSelection == InterpolationTypes.linear, linearDickerson,
                fileImage: widget.images.linear, onTap: () {
              setState(() {
                currentSelection = InterpolationTypes.linear;
              });
            }),
            buildImageButton(
                "Nearest",
                currentSelection == InterpolationTypes.nearest,
                nearestDickerson,
                fileImage: widget.images.nearest, onTap: () {
              setState(() {
                currentSelection = InterpolationTypes.nearest;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget buildImageViews() {
    AssetImage? useImage;
    File? useFile;

    switch (currentSelection) {
      case InterpolationTypes.average:
        useImage = averageDickerson;
        useFile = widget.images.average;
        break;
      case InterpolationTypes.cubic:
        useImage = cubicDickerson;
        useFile = widget.images.cubic;

        break;
      case InterpolationTypes.linear:
        useImage = linearDickerson;
        useFile = widget.images.linear;

        break;
      case InterpolationTypes.nearest:
        useImage = nearestDickerson;
        useFile = widget.images.nearest;

        break;
      default:
        useImage = bigDickerson;
        useFile = widget.images.original;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: 300,
            height: 250,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: showImage(
                useImage,
                fileImage: useFile,
                // caption: imageCaptionMap[useImage],
                // ),
              ),
            ),
            // const SizedBox(
            //   height: 10,
          ),
          const Divider(
            color: Colors.black,
          ),
          const Text(
            "Select Interpolation Type",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                fontSize: 25),
          ),
          const SizedBox(height: 25),
          buildImageOptions(),
          if (currentSelection != InterpolationTypes.none &&
              widget.images.average != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, currentSelection);
              },
              child: const Text("Use Interpolation Method"),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Processing"),
        ),
        floatingActionButton: currentSelection != InterpolationTypes.none
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    currentSelection = InterpolationTypes.none;
                  });
                },
                child: const Icon(Icons.undo),
              )
            : null,
        body: buildImageViews());
  }
}
