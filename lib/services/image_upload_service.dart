import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: always_use_package_imports
import '../providers/application_providers.dart';
import 'image_compute.dart' as ic;

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
    final repo = ref.read(imageRepositoryPgProvider);
    // Decode in isolates
    final dims = await compute(ic.decodeDimensions, bytes);
    final int? decodedDpi = await compute(ic.decodeDpi, bytes);
    final int? width = dims.width;
    final int? height = dims.height;
    final String mime = ic.detectMimeType(bytes);
    // Insert base row
    final imageId = await repo.insertBase(
      origSrc: bytes,
      origBytes: bytes.length,
      origWidth: width,
      origHeight: height,
      mimeType: mime,
    );
    // Persist DPI and phys px
    final int resolvedDpi =
        (decodedDpi != null && decodedDpi > 0) ? decodedDpi : 96;
    await repo.setDpiAndPhys(
        imageId, resolvedDpi, width?.toDouble(), height?.toDouble());
    debugPrint(
        '[ImageUploadService] stored image id=$imageId dpi=$resolvedDpi');
    return UploadedImageResult(
        imageId: imageId, width: width, height: height, dpi: resolvedDpi);
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return const ImageUploadService();
});
