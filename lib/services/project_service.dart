import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
        ..thumbnailData = thumbnailData;
    }
    return null;
  }

  Project performVectorConversion(Project project) {
    final settings = Hive.box('settings');
    final scalePercent =
        double.tryParse(settings.get('downsampleScale', defaultValue: '10')) ??
        10.0;

    final Uint8List imageData = project.imageData;
    final img.Image? originalImage = img.decodeImage(imageData);

    if (originalImage == null) {
      // Or handle error appropriately
      throw Exception('Could not decode image');
    }

    final int newWidth = (originalImage.width * scalePercent / 100).round();
    final int newHeight = (originalImage.height * scalePercent / 100).round();

    final img.Image downsampledImage = img.copyResize(
      originalImage,
      width: newWidth > 0 ? newWidth : 1,
      height: newHeight > 0 ? newHeight : 1,
      interpolation: img.Interpolation.nearest,
    );

    final List<VectorObject> vectorObjects = [];
    final Map<int, int> colorIndexMap = {};
    int nextColorIndex = 1;

    for (int y = 0; y < downsampledImage.height; y++) {
      for (int x = 0; x < downsampledImage.width; x++) {
        final pixel = downsampledImage.getPixel(x, y);
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
      downsampledImage.width.toDouble(),
      downsampledImage.height.toDouble(),
    );
    final Set<int> uniqueColors = vectorObjects
        .map((obj) => obj.color.toARGB32())
        .toSet();

    // Return a new or updated project object
    return project
      ..vectorObjects = vectorObjects
      ..imageWidth = imageSize.width
      ..imageHeight = imageSize.height
      ..isConverted = true
      ..uniqueColorCount = uniqueColors.length;
  }
}
