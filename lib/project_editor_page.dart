import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:vettore/color_settings.dart';
import 'package:vettore/project_model.dart';
import 'package:vettore/settings_image.dart';
import 'package:vettore/vector_object_model.dart';

class ProjectEditorPage extends StatefulWidget {
  final int projectKey;

  const ProjectEditorPage({super.key, required this.projectKey});

  @override
  State<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class _ProjectEditorPageState extends State<ProjectEditorPage> {
  late Project _project;
  bool _showVectors = true;
  bool _showBackground = true;

  @override
  void initState() {
    super.initState();
    _project = Hive.box<Project>('projects').get(widget.projectKey)!;
  }

  void _runVectorConversion() async {
    final settings = Hive.box('settings');
    final scalePercent =
        double.tryParse(settings.get('downsampleScale', defaultValue: '10')) ??
        10.0;
    final Uint8List imageData = _project.imageData;

    final img.Image? originalImage = img.decodeImage(imageData);

    if (originalImage == null) {
      return;
    }

    final int newWidth = (originalImage.width * scalePercent / 100).round();
    final int newHeight = (originalImage.height * scalePercent / 100).round();

    final img.Image downsampledImage = img.copyResize(
      originalImage,
      width: newWidth > 0 ? newWidth : 1,
      height: newHeight > 0 ? newHeight : 1,
      interpolation: img.Interpolation.nearest,
    );

    final List<VectorObject> vectorObjects = [];
    final Map<int, int> colorIndexMap = {};
    int nextColorIndex = 1;
    final List<Color> finalPalette = [];

    for (int y = 0; y < downsampledImage.height; y++) {
      for (int x = 0; x < downsampledImage.width; x++) {
        final pixel = downsampledImage.getPixel(x, y);
        final flutterColor = Color.fromARGB(
          pixel.a.toInt(),
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        int colorIndex;
        if (colorIndexMap.containsKey(flutterColor.value)) {
          colorIndex = colorIndexMap[flutterColor.value]!;
        } else {
          colorIndex = nextColorIndex;
          colorIndexMap[flutterColor.value] = colorIndex;
          finalPalette.add(flutterColor);
          nextColorIndex++;
        }

        vectorObjects.add(
          VectorObject.fromRectAndColor(
            rect: Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
            color: flutterColor,
            colorIndex: colorIndex,
          ),
        );
      }
    }

    final Size imageSize = Size(
      downsampledImage.width.toDouble(),
      downsampledImage.height.toDouble(),
    );
    final Set<int> uniqueColors = vectorObjects
        .map((obj) => obj.color.value)
        .toSet();

    setState(() {
      _project.vectorObjects = vectorObjects;
      _project.imageWidth = imageSize.width;
      _project.imageHeight = imageSize.height;
      _project.isConverted = true;
      _project.uniqueColorCount = uniqueColors.length;
      // TODO: Save palette properly
      // _project.palette = finalPalette;
      _project.save();
    });
  }

  void _showColorSettingsDialog() {
    if (!_project.isConverted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please convert the image first.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => ColorSettingsDialog(colors: []), // TODO: Fix this
    );
  }

  void _showImageSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(project: _project);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_project.name)),
      body: Row(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 10.0,
              child: RepaintBoundary(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Visibility(
                        visible: _showBackground,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: Image.memory(_project.imageData),
                      ),
                      if (_project.isConverted && _showVectors)
                        Positioned.fill(
                          child: ValueListenableBuilder(
                            valueListenable: Hive.box('settings').listenable(),
                            builder: (context, box, _) {
                              return CustomPaint(
                                painter: VectorPainter(
                                  objects: _project.vectorObjects,
                                  imageSize: _project.imageWidth != null
                                      ? Size(
                                          _project.imageWidth!,
                                          _project.imageHeight!,
                                        )
                                      : null,
                                  fontSize:
                                      double.tryParse(
                                        box.get('fontSize', defaultValue: '12'),
                                      ) ??
                                      12.0,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            color: Theme.of(context).colorScheme.surfaceContainer,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runVectorConversion,
                    child: const Text('Convert'),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showImageSettingsDialog,
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Image Settings'),
                ),
                TextButton.icon(
                  onPressed: _showColorSettingsDialog,
                  icon: const Icon(Icons.palette_outlined),
                  label: Text(
                    _project.isConverted
                        ? 'Colors: ${_project.uniqueColorCount}'
                        : 'Colors: N/A',
                  ),
                ),
                const Divider(),
                const Text('Preview'),
                CheckboxListTile(
                  title: const Text('Show Vectors'),
                  value: _showVectors,
                  onChanged: (bool? value) {
                    setState(() {
                      _showVectors = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Show Background'),
                  value: _showBackground,
                  onChanged: (bool? value) {
                    setState(() {
                      _showBackground = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VectorPainter extends CustomPainter {
  final List<VectorObject> objects;
  final Size? imageSize;
  final double fontSize;

  VectorPainter({
    required this.objects,
    required this.imageSize,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == null || objects.isEmpty) return;

    final imageWidth = imageSize!.width;
    final imageHeight = imageSize!.height;
    if (imageWidth == 0 || imageHeight == 0) return;

    final canvasWidth = size.width;
    final canvasHeight = size.height;

    final scaleX = canvasWidth / imageWidth;
    final scaleY = canvasHeight / imageHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final cellWidth = scale;
    final cellHeight = scale;
    final totalGridWidth = imageWidth * cellWidth;
    final totalGridHeight = imageHeight * cellHeight;

    final offsetX = (canvasWidth - totalGridWidth) / 2;
    final offsetY = (canvasHeight - totalGridHeight) / 2;

    final gridPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin
          .bevel // This prevents corner overlap.
      ..isAntiAlias = false;

    // Step 1: Draw the outer border as a single, clean rectangle.
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, totalGridWidth, totalGridHeight),
      gridPaint,
    );

    // Step 2: Draw only the inner lines.
    final innerLinesPath = Path();

    // Add inner vertical lines to the path
    for (int i = 1; i < imageWidth; i++) {
      final x = offsetX + i * cellWidth;
      innerLinesPath.moveTo(x, offsetY);
      innerLinesPath.lineTo(x, offsetY + totalGridHeight);
    }

    // Add inner horizontal lines to the path
    for (int i = 1; i < imageHeight; i++) {
      final y = offsetY + i * cellHeight;
      innerLinesPath.moveTo(offsetX, y);
      innerLinesPath.lineTo(offsetX + totalGridWidth, y);
    }

    canvas.drawPath(innerLinesPath, gridPaint);

    for (final obj in objects) {
      final rect = Rect.fromLTWH(
        obj.rect.left * cellWidth + offsetX,
        obj.rect.top * cellHeight + offsetY,
        cellWidth,
        cellHeight,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: obj.colorIndex.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = Offset(
        rect.center.dx - (textPainter.width / 2),
        rect.center.dy - (textPainter.height / 2),
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant VectorPainter oldDelegate) {
    return oldDelegate.objects != objects ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.fontSize != fontSize;
  }
}
