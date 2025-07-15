import 'package:hive/hive.dart';
import 'package:vettore/palette_color.dart';

part 'palette_model.g.dart';

@HiveType(typeId: 1)
class Palette extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  List<PaletteColor> colors = [];

  @HiveField(2)
  double sizeInMl = 60.0;

  @HiveField(3)
  double factor = 1.5;
}
