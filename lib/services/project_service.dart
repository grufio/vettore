import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:vettore/models/project_model.dart';

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
}
