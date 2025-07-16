import 'package:hive/hive.dart';
import 'color_component_model.dart';

part 'palette_color.g.dart';

@HiveType(typeId: 2)
class PaletteColor {
  @HiveField(0)
  String title;

  @HiveField(1)
  int color;

  @HiveField(2)
  String status;

  @deprecated
  @HiveField(3)
  List<ColorComponent> components;

  @HiveField(4)
  List<int> componentKeys;

  PaletteColor({
    required this.title,
    required this.color,
    this.status = '',
    List<ColorComponent>? components,
    List<int>? componentKeys,
  }) : components = components ?? [],
       componentKeys = componentKeys ?? [];

  PaletteColor.from(PaletteColor other)
    : title = other.title,
      color = other.color,
      status = other.status,
      components = List<ColorComponent>.from(
        other.components.map((c) => ColorComponent.from(c)),
      ),
      componentKeys = List<int>.from(other.componentKeys);

  List<ColorComponent> getComponents() {
    final box = Hive.box<ColorComponent>('color_components');
    return componentKeys
        .map((key) => box.get(key)!)
        .where((c) => c != null)
        .toList();
  }
}
