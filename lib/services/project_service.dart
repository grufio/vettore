import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:vettore/data/database.dart';

class ProjectService {
  Future<ProjectsCompanion?> createProjectFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final imageData = await File(file.path!).readAsBytes();
      final originalImage = img.decodeImage(imageData);
      if (originalImage == null) return null;

      final thumbnail = img.copyResize(originalImage, width: 200);
      final thumbnailData = Uint8List.fromList(img.encodePng(thumbnail));

      return ProjectsCompanion(
        name: Value(p.basename(file.path!)),
        imageData: Value(imageData),
        thumbnailData: Value(thumbnailData),
        imageWidth: Value(originalImage.width.toDouble()),
        imageHeight: Value(originalImage.height.toDouble()),
        originalImageData: Value(imageData),
        originalImageWidth: Value(originalImage.width.toDouble()),
        originalImageHeight: Value(originalImage.height.toDouble()),
      );
    }
    return null;
  }
}
