import 'package:hive/hive.dart';
import 'package:vettore/models/palette_color.dart';

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

  Palette();

  // Copy constructor
  Palette.from(Palette other) {
    name = other.name;
    colors = List<PaletteColor>.from(
      other.colors.map((c) => PaletteColor.from(c)),
    );
    sizeInMl = other.sizeInMl;
    factor = other.factor;
    // Note: We don't copy the key from 'other' because this should be a new object
    // or an object that already has a key.
  }
}
