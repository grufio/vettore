import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: always_use_package_imports
import '../providers/application_providers.dart';

/// Image bytes (Uint8List?) for an image id.
/// Source: uses converted bytes when present, otherwise original bytes.
final imageBytesProvider =
    FutureProvider.family<Uint8List?, int>((ref, imageId) async {
  final repo = ref.read(imageRepositoryPgProvider);
  return repo.getBestBytes(imageId);
});

// (Removed) Raster dimensions legacy provider. Use bytes or phys pixels providers instead.

/// DPI metadata for an image id.
/// Source: reads `images.dpi` (mutable per-image metadata; does not affect size).
final imageDpiProvider = FutureProvider.family<int?, int>((ref, imageId) async {
  final repo = ref.read(imageRepositoryPgProvider);
  return repo.getDpi(imageId);
});

/// Physical pixel floats (w,h) with 4 decimals.
/// Source of truth for logical image size; preview raster rounds these to ints.
final imagePhysPixelsProvider =
    FutureProvider.family<(double?, double?), int>((ref, imageId) async {
  final repo = ref.read(imageRepositoryPgProvider);
  return repo.getPhys(imageId);
});
