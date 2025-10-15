import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift show Variable;
import 'package:vettore/providers/application_providers.dart';

// Image bytes provider: render converted (working) bytes when present, else original
final imageBytesProvider =
    FutureProvider.family<Uint8List?, int>((ref, imageId) async {
  final db = ref.read(appDatabaseProvider);
  final row = await (db.select(db.images)..where((t) => t.id.equals(imageId)))
      .getSingleOrNull();
  if (row?.convSrc != null && (row?.convBytes ?? 0) > 0) {
    return row!.convSrc;
  }
  return row?.origSrc;
});

// Image dimensions provider: show converted size when a working image exists,
// otherwise show original size.
final imageDimensionsProvider =
    FutureProvider.family<(int?, int?), int>((ref, imageId) async {
  final db = ref.read(appDatabaseProvider);
  final row = await (db.select(db.images)..where((t) => t.id.equals(imageId)))
      .getSingleOrNull();
  final hasConv = (row?.convSrc != null && (row?.convBytes ?? 0) > 0);
  final w = hasConv ? row?.convWidth : row?.origWidth;
  final h = hasConv ? row?.convHeight : row?.origHeight;
  return (w, h);
});

// Image DPI provider: returns the mutable image DPI (images.dpi)
final imageDpiProvider = FutureProvider.family<int?, int>((ref, imageId) async {
  final db = ref.read(appDatabaseProvider);
  final row = await db.customSelect(
      'SELECT dpi FROM images WHERE id = ? LIMIT 1',
      variables: [drift.Variable<int>(imageId)]).getSingleOrNull();
  if (row == null) return null;
  return row.data['dpi'] as int?;
});

// Physical pixel dimensions provider (4-decimal floats) - single source of truth
final imagePhysPixelsProvider =
    FutureProvider.family<(double?, double?), int>((ref, imageId) async {
  final db = ref.read(appDatabaseProvider);
  final row = await db.customSelect(
      'SELECT phys_width_px4, phys_height_px4 FROM images WHERE id = ? LIMIT 1',
      variables: [drift.Variable<int>(imageId)]).getSingleOrNull();
  if (row == null) return (null, null);
  final data = row.data;
  final num? w = data['phys_width_px4'] as num?;
  final num? h = data['phys_height_px4'] as num?;
  return (w?.toDouble(), h?.toDouble());
});
