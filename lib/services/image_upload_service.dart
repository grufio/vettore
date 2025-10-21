import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/data/database.dart';

class UploadedImageResult {
  const UploadedImageResult({
    required this.imageId,
    required this.width,
    required this.height,
    required this.dpi,
  });
  final int imageId;
  final int? width;
  final int? height;
  final int dpi;
}

class ImageUploadService {
  const ImageUploadService();

  /// Insert an uploaded image into DB, set DPI and seed phys_width/phys_height.
  /// Returns image id and decoded metadata.
  Future<UploadedImageResult> insertImageAndMetadata(
      WidgetRef ref, Uint8List bytes) async {
    final imagesDao = ref.read(appDatabaseProvider);
    // Decode in isolates
    final dims = await compute(ic.decodeDimensions, bytes);
    final int? decodedDpi = await compute(ic.decodeDpi, bytes);
    final int? width = dims.width;
    final int? height = dims.height;
    final String mime = ic.detectMimeType(bytes);
    // Insert base row
    final imageId = await imagesDao.into(imagesDao.images).insert(
          ImagesCompanion.insert(
            origSrc: Value(bytes),
            origBytes: Value(bytes.length),
            origWidth: width != null ? Value(width) : const Value.absent(),
            origHeight: height != null ? Value(height) : const Value.absent(),
            mimeType: Value(mime),
          ),
        );
    // Persist DPI and phys px
    final int resolvedDpi =
        (decodedDpi != null && decodedDpi > 0) ? decodedDpi : 96;
    await imagesDao.customStatement(
      'UPDATE images SET orig_dpi = ?, dpi = ?, phys_width_px4 = ?, phys_height_px4 = ? WHERE id = ?',
      [
        resolvedDpi,
        resolvedDpi,
        width?.toDouble(),
        height?.toDouble(),
        imageId,
      ],
    );
    debugPrint(
        '[ImageUploadService] stored image id=$imageId dpi=$resolvedDpi');
    return UploadedImageResult(
        imageId: imageId, width: width, height: height, dpi: resolvedDpi);
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return const ImageUploadService();
});
