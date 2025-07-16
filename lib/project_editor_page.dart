import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:vettore/color_settings.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/settings_image.dart';
import 'package:vettore/models/vector_object_model.dart';

class ProjectEditorPage extends ConsumerStatefulWidget {
  final int projectKey;

  const ProjectEditorPage({super.key, required this.projectKey});

  @override
  ConsumerState<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class _ProjectEditorPageState extends ConsumerState<ProjectEditorPage> {
  bool _showVectors = true;
  bool _showBackground = true;

  void _showColorSettingsDialog() {
    final project = ref.read(projectProvider(widget.projectKey));
    if (project == null || !project.isConverted) {
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
    final project = ref.read(projectProvider(widget.projectKey));
    if (project == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(project: project);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectKey));

    if (project == null) {
      return const Scaffold(
        body: Center(child: Text('Project not found or has been deleted.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
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
                        child: Image.memory(project.imageData),
                      ),
                      if (project.isConverted && _showVectors)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: VectorPainter(
                              objects: project.vectorObjects,
                              imageSize: project.imageWidth != null
                                  ? Size(
                                      project.imageWidth!,
                                      project.imageHeight!,
                                    )
                                  : null,
                              // TODO: Get from settings provider
                              fontSize: 12.0,
                            ),
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
                    onPressed: () => ref
                        .read(projectProvider(widget.projectKey).notifier)
                        .convertProject(),
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
                    project.isConverted
                        ? 'Colors: ${project.uniqueColorCount}'
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
