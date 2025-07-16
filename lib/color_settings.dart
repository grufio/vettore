import 'package:flutter/material.dart';

class ColorSettingsDialog extends StatefulWidget {
  final List<Color> colors;

  const ColorSettingsDialog({super.key, required this.colors});

  @override
  ColorSettingsDialogState createState() => ColorSettingsDialogState();
}

class ColorSettingsDialogState extends State<ColorSettingsDialog> {
  Widget _buildColorInfoTab() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('#')),
          DataColumn(label: Text('HEX')),
          DataColumn(label: Text('RGB')),
        ],
        rows: List<DataRow>.generate(widget.colors.length, (index) {
          final color = widget.colors[index];
          final red = (color.toARGB32() >> 16) & 0xFF;
          final green = (color.toARGB32() >> 8) & 0xFF;
          final blue = color.toARGB32() & 0xFF;
          final hex =
              '#${red.toRadixString(16).padLeft(2, '0')}'
                      '${green.toRadixString(16).padLeft(2, '0')}'
                      '${blue.toRadixString(16).padLeft(2, '0')}'
                  .toUpperCase();
          final rgb = '$red, $green, $blue';
          return DataRow(
            cells: <DataCell>[
              DataCell(Text((index + 1).toString())),
              DataCell(
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    Text(hex),
                  ],
                ),
              ),
              DataCell(Text(rgb)),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Color Information'),
      content: DefaultTabController(
        length: 1,
        child: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              const TabBar(tabs: [Tab(text: 'Color Info')]),
              Expanded(child: TabBarView(children: [_buildColorInfoTab()])),
            ],
          ),
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
