import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:vettore/color_settings.dart';
import 'package:vettore/settings_image.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vettore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class TabData {
  final String imagePath;
  final Uint8List imageData;
  bool isConverted = false;
  List<VectorObject> vectorObjects = [];
  List<Color> palette = [];
  Size? originalImageSize;
  int? uniqueColorCount;

  TabData({required this.imagePath, required this.imageData});
}

class VectorObject {
  final Rect rect;
  final Color color;
  final int colorIndex;

  VectorObject({
    required this.rect,
    required this.color,
    required this.colorIndex,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TabData> _tabs = [];
  int _currentIndex = 0;

  void _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          final imageData = await File(file.path!).readAsBytes();
          setState(() {
            _tabs.add(TabData(imagePath: file.path!, imageData: imageData));
          });
        }
      }
      setState(() {
        _currentIndex = _tabs.length - 1;
      });
    }
  }

  void _closeTab(int index) {
    setState(() {
      _tabs.removeAt(index);
      if (_currentIndex >= _tabs.length && _tabs.isNotEmpty) {
        _currentIndex = _tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: _currentIndex,
      child: Scaffold(
        appBar: AppBar(
          bottom: _tabs.isEmpty
              ? null
              : TabBar(
                  isScrollable: true,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  tabs: [
                    for (int i = 0; i < _tabs.length; i++)
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.basename(_tabs[i].imagePath)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => _closeTab(i),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _tabs.isEmpty
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SettingsDialog(tabData: _tabs[_currentIndex]);
                        },
                      );
                    },
            ),
          ],
        ),
        body: _tabs.isEmpty
            ? const Center(child: Text('No images selected.'))
            : TabBarView(
                children: _tabs
                    .map(
                      (tab) => ImageTabView(
                        key: ValueKey(tab.imagePath),
                        tabData: tab,
                        onConvert: () =>
                            _runVectorConversion(_tabs.indexOf(tab)),
                      ),
                    )
                    .toList(),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _pickImages,
          tooltip: 'Select Images',
          child: const Icon(Icons.add_photo_alternate),
        ),
      ),
    );
  }

  void _runVectorConversion(int tabIndex) async {
    final settings = Hive.box('settings');
    final scalePercent =
        double.tryParse(settings.get('downsampleScale', defaultValue: '10')) ??
        10.0;
    final Uint8List imageData = _tabs[tabIndex].imageData;

    // Perform conversion in the main thread for simplicity and to avoid isolate errors.
    final img.Image? originalImage = img.decodeImage(imageData);

    if (originalImage == null) {
      // Optionally, show an error to the user.
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
        final imageColorValue = flutterColor.value;

        int colorIndex;
        if (colorIndexMap.containsKey(imageColorValue)) {
          colorIndex = colorIndexMap[imageColorValue]!;
        } else {
          colorIndex = nextColorIndex;
          colorIndexMap[imageColorValue] = colorIndex;
          finalPalette.add(flutterColor);
          nextColorIndex++;
        }

        vectorObjects.add(
          VectorObject(
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
        .map((obj) => obj.color.toARGB32())
        .toSet();

    setState(() {
      _tabs[tabIndex].vectorObjects = vectorObjects;
      _tabs[tabIndex].originalImageSize = imageSize;
      _tabs[tabIndex].isConverted = true;
      _tabs[tabIndex].uniqueColorCount = uniqueColors.length;
      _tabs[tabIndex].palette = finalPalette;
    });
  }
}

class ImageTabView extends StatefulWidget {
  final TabData tabData;
  final VoidCallback onConvert;

  const ImageTabView({
    super.key,
    required this.tabData,
    required this.onConvert,
  });

  @override
  State<ImageTabView> createState() => _ImageTabViewState();
}

class _ImageTabViewState extends State<ImageTabView> {
  bool _showVectors = true;
  bool _showBackground = true;

  void _showColorSettingsDialog() {
    if (!widget.tabData.isConverted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please convert the image first.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => ColorSettingsDialog(colors: widget.tabData.palette),
    );
  }

  void _showImageSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(tabData: widget.tabData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                      child: Image.memory(widget.tabData.imageData),
                    ),
                    if (widget.tabData.isConverted && _showVectors)
                      Positioned.fill(
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box('settings').listenable(),
                          builder: (context, box, _) {
                            return CustomPaint(
                              painter: VectorPainter(
                                objects: widget.tabData.vectorObjects,
                                imageSize: widget.tabData.originalImageSize,
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
                  onPressed: widget.onConvert,
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
                  widget.tabData.isConverted
                      ? 'Colors: ${widget.tabData.uniqueColorCount}'
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
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= imageWidth; i++) {
      final x = i * cellWidth + offsetX;
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + totalGridHeight),
        gridPaint,
      );
    }

    for (int i = 0; i <= imageHeight; i++) {
      final y = i * cellHeight + offsetY;
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + totalGridWidth, y),
        gridPaint,
      );
    }

    for (final obj in objects) {
      final rect = Rect.fromLTWH(
        obj.rect.left * cellWidth + offsetX,
        obj.rect.top * cellHeight + offsetY,
        obj.rect.width * cellWidth,
        obj.rect.height * cellHeight,
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
