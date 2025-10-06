import 'package:flutter/material.dart';

enum ColorSortCriteria { none, hue, saturation, lightness, appearance }

class _ColorInfo {
  final Color color;
  final int number;
  _ColorInfo(this.color, this.number);
}

class ColorSettingsDialog extends StatefulWidget {
  final List<Color> colors;

  const ColorSettingsDialog({super.key, required this.colors});

  @override
  ColorSettingsDialogState createState() => ColorSettingsDialogState();
}

class ColorSettingsDialogState extends State<ColorSettingsDialog> {
  late List<_ColorInfo> _sortedColors;
  late List<_ColorInfo> _originalColors;
  ColorSortCriteria _sortCriteria = ColorSortCriteria.none;

  @override
  void initState() {
    super.initState();
    _originalColors = widget.colors
        .asMap()
        .entries
        .map((e) => _ColorInfo(e.value, e.key + 1))
        .toList();
    _sortedColors = List.from(_originalColors);
  }

  void _sortColors(ColorSortCriteria criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (criteria == ColorSortCriteria.none) {
        _sortedColors = List.from(_originalColors);
      } else {
        _sortedColors.sort((a, b) {
          final hslA = HSLColor.fromColor(a.color);
          final hslB = HSLColor.fromColor(b.color);
          switch (criteria) {
            case ColorSortCriteria.appearance:
              // First sort by Hue
              int hueCompare = hslA.hue.compareTo(hslB.hue);
              if (hueCompare != 0) return hueCompare;
              // Then sort by Lightness
              return hslA.lightness.compareTo(hslB.lightness);
            case ColorSortCriteria.hue:
              return hslA.hue.compareTo(hslB.hue);
            case ColorSortCriteria.saturation:
              return hslA.saturation.compareTo(hslB.saturation);
            case ColorSortCriteria.lightness:
              return hslA.lightness.compareTo(hslB.lightness);
            case ColorSortCriteria.none:
              return 0;
          }
        });
      }
    });
  }

  Widget _buildColorInfoTab() {
    return ListView.builder(
      itemCount: _sortedColors.length,
      itemBuilder: (context, index) {
        final colorInfo = _sortedColors[index];
        final color = colorInfo.color;
        final hex =
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        final rgb = '${color.red}, ${color.green}, ${color.blue}';

        return ListTile(
          leading: Text(colorInfo.number.toString()),
          title: Text(hex),
          subtitle: Text('RGB: $rgb'),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Color Information'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<ColorSortCriteria>(
                  value: _sortCriteria,
                  items: const [
                    DropdownMenuItem(
                      value: ColorSortCriteria.none,
                      child: Text('None'),
                    ),
                    DropdownMenuItem(
                      value: ColorSortCriteria.appearance,
                      child: Text('Appearance'),
                    ),
                    DropdownMenuItem(
                      value: ColorSortCriteria.hue,
                      child: Text('Hue'),
                    ),
                    DropdownMenuItem(
                      value: ColorSortCriteria.saturation,
                      child: Text('Saturation'),
                    ),
                    DropdownMenuItem(
                      value: ColorSortCriteria.lightness,
                      child: Text('Lightness'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _sortColors(value);
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(child: _buildColorInfoTab()),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
