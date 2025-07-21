import 'dart:typed_data';
import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/vector_object_model.dart';

part 'project_model.g.dart';

@HiveType(typeId: 4)
class Project extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late Uint8List imageData;

  @HiveField(2)
  late Uint8List thumbnailData;

  @HiveField(3)
  bool isConverted = false;

  @HiveField(4)
  List<VectorObject> vectorObjects = [];

  @HiveField(5)
  List<PaletteColor> palette = [];

  @HiveField(6)
  double? imageWidth;

  @HiveField(7)
  double? imageHeight;

  @HiveField(8)
  int? uniqueColorCount;

  @HiveField(9)
  Uint8List? originalImageData;

  @HiveField(10)
  double? originalImageWidth;

  @HiveField(11)
  double? originalImageHeight;

  @HiveField(12, defaultValue: 1)
  int filterQualityIndex = FilterQuality.low.index;

  @HiveField(13)
  int? paletteKey;

  FilterQuality get filterQuality => FilterQuality.values[filterQualityIndex];

  Project copyWith({
    String? name,
    Uint8List? imageData,
    Uint8List? thumbnailData,
    bool? isConverted,
    List<VectorObject>? vectorObjects,
    List<PaletteColor>? palette,
    double? imageWidth,
    double? imageHeight,
    int? uniqueColorCount,
    Uint8List? originalImageData,
    double? originalImageWidth,
    double? originalImageHeight,
    int? filterQualityIndex,
    int? paletteKey,
  }) {
    return Project()
      ..name = name ?? this.name
      ..imageData = imageData ?? this.imageData
      ..thumbnailData = thumbnailData ?? this.thumbnailData
      ..isConverted = isConverted ?? this.isConverted
      ..vectorObjects = vectorObjects ?? this.vectorObjects
      ..palette = palette ?? this.palette
      ..imageWidth = imageWidth ?? this.imageWidth
      ..imageHeight = imageHeight ?? this.imageHeight
      ..uniqueColorCount = uniqueColorCount ?? this.uniqueColorCount
      ..originalImageData = originalImageData ?? this.originalImageData
      ..originalImageWidth = originalImageWidth ?? this.originalImageWidth
      ..originalImageHeight = originalImageHeight ?? this.originalImageHeight
      ..filterQualityIndex = filterQualityIndex ?? this.filterQualityIndex
      ..paletteKey = paletteKey ?? this.paletteKey;
  }
}
