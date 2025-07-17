import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:vettore/models/project_model.dart';
import 'package:vettore/models/vector_object_model.dart';

class ProjectService {
  Future<Project?> createProjectFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false, // We'll handle one file at a time
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final imageData = await File(file.path!).readAsBytes();
      final originalImage = img.decodeImage(imageData);
      if (originalImage == null) return null;

      final thumbnail = img.copyResize(originalImage, width: 200);
      final thumbnailData = img.encodePng(thumbnail);

      return Project()
        ..name = p.basename(file.path!)
        ..imageData = imageData
        ..thumbnailData = thumbnailData
        ..imageWidth = originalImage.width.toDouble()
        ..imageHeight = originalImage.height.toDouble()
        ..originalImageData = imageData
        ..originalImageWidth = originalImage.width.toDouble()
        ..originalImageHeight = originalImage.height.toDouble();
    }
    return null;
  }

  Future<Project> performVectorConversion(Project project) async {
    // We pass the project data to the isolate.
    // Downscaling is now handled separately in the UI.
    return await compute(_performConversion, project);
  }
}

// This function will run in a separate isolate.
Project _performConversion(Project project) {
  final Uint8List imageData = project.imageData;
  final img.Image? imageToConvert = img.decodeImage(imageData);

  if (imageToConvert == null) {
    // Or handle error appropriately
    throw Exception('Could not decode image');
  }

  final List<VectorObject> vectorObjects = [];
  final Map<int, int> colorIndexMap = {};
  int nextColorIndex = 1;

  for (int y = 0; y < imageToConvert.height; y++) {
    for (int x = 0; x < imageToConvert.width; x++) {
      final pixel = imageToConvert.getPixel(x, y);
      final flutterColor = Color.fromARGB(
        pixel.a.toInt(),
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );

      int colorIndex;
      if (colorIndexMap.containsKey(flutterColor.toARGB32())) {
        colorIndex = colorIndexMap[flutterColor.toARGB32()]!;
      } else {
        colorIndex = nextColorIndex;
        colorIndexMap[flutterColor.toARGB32()] = colorIndex;
        nextColorIndex++;
      }

      vectorObjects.add(
        VectorObject.fromRectAndColor(
          rect: Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          color: flutterColor,
          colorIndex: colorIndex,
        ),
      );
    }
  }

  final Size imageSize = Size(
    imageToConvert.width.toDouble(),
    imageToConvert.height.toDouble(),
  );
  final Set<int> uniqueColors = vectorObjects
      .map((obj) => obj.color.toARGB32())
      .toSet();

  // Return a new or updated project object
  return project.copyWith(
    vectorObjects: vectorObjects,
    imageWidth: imageSize.width,
    imageHeight: imageSize.height,
    isConverted: true,
    uniqueColorCount: uniqueColors.length,
  );
}
