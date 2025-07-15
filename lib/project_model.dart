import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:vettore/palette_color.dart';
import 'package:vettore/vector_object_model.dart';

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
}
