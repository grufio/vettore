import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/models/vector_object_model.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/features/projects/services/pdf_generator.dart';
import 'package:vettore/widgets/color_settings_dialog.dart';

class ProjectEditorPage extends ConsumerStatefulWidget {
  final int projectKey;

  const ProjectEditorPage({super.key, required this.projectKey});
  @override
  ConsumerState<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class _ProjectEditorPageState extends ConsumerState<ProjectEditorPage>
    with SingleTickerProviderStateMixin {
  bool _showVectors = true;
  bool _showBackground = true;

  // Controllers for conversion settings
  late final TextEditingController _downsampleScaleController;
  late final TextEditingController _maxObjectColorsController;

  // State for Output tab
  late final TextEditingController _objectOutputSizeController;
  late final TextEditingController _outputFontSizeController;
  late final TextEditingController _customPageWidthController;
  late final TextEditingController _customPageHeightController;
  late final TextEditingController _outputBordersController;
  bool _printBackground = false;
  bool _isSaving = false;
  String _selectedPageFormat = 'A4';
  bool _centerImage = true;
  bool _isLandscape = false;

  final ValueNotifier<Size?> _resultingDimensionsNotifier = ValueNotifier(null);

  TabController? _tabController;

  final Map<String, PdfPageFormat?> _pageFormats = {
    'A4': PdfPageFormat.a4,
    'A3': PdfPageFormat.a3,
    'Letter': PdfPageFormat.letter,
    'Custom': null,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final settingsBox = Hive.box('settings');
    _downsampleScaleController = TextEditingController(
      text: settingsBox.get('downsampleScale', defaultValue: '10'),
    );
    _downsampleScaleController.addListener(_calculateResultingDimensions);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateResultingDimensions();
    });

    _maxObjectColorsController = TextEditingController(
      text: settingsBox.get('maxObjectColors', defaultValue: '40'),
    );

    // Init Output state
    _objectOutputSizeController = TextEditingController(
      text: settingsBox.get('objectOutputSize', defaultValue: '10'),
    );
    _outputFontSizeController = TextEditingController(
      text: settingsBox.get('outputFontSize', defaultValue: '10'),
    );
    _customPageWidthController = TextEditingController(
      text: settingsBox.get('customPageWidth', defaultValue: '210'),
    );
    _customPageHeightController = TextEditingController(
      text: settingsBox.get('customPageHeight', defaultValue: '297'),
    );
    _outputBordersController = TextEditingController(
      text: settingsBox.get('outputBorders', defaultValue: '10'),
    );
    _printBackground = settingsBox.get('printBackground', defaultValue: false);
    _selectedPageFormat = settingsBox.get('pageFormat', defaultValue: 'A4');
    _centerImage = settingsBox.get('centerImage', defaultValue: true);
    _isLandscape = settingsBox.get('isLandscape', defaultValue: false);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _downsampleScaleController.removeListener(_calculateResultingDimensions);
    _downsampleScaleController.dispose();
    _maxObjectColorsController.dispose();
    _objectOutputSizeController.dispose();
    _outputFontSizeController.dispose();
    _customPageWidthController.dispose();
    _customPageHeightController.dispose();
    _outputBordersController.dispose();
    _resultingDimensionsNotifier.dispose();
    super.dispose();
  }

  void _calculateResultingDimensions() {
    final project = ref.read(projectProvider(widget.projectKey)).project;
    if (project == null) {
      _resultingDimensionsNotifier.value = null;
      return;
    }

    final scale = double.tryParse(_downsampleScaleController.text) ?? 0.0;
    if (project.imageWidth != null && project.imageHeight != null) {
      _resultingDimensionsNotifier.value = Size(
        (project.imageWidth! * scale / 100).round().toDouble(),
        (project.imageHeight! * scale / 100).round().toDouble(),
      );
    } else {
      _resultingDimensionsNotifier.value = null;
    }
  }

  Future<void> _handlePdfGeneration() async {
    final project = ref.read(projectProvider(widget.projectKey)).project;
    if (project == null) return;

    setState(() => _isSaving = true);

    PdfPageFormat pageFormat;
    if (_selectedPageFormat == 'Custom') {
      final width = double.tryParse(_customPageWidthController.text) ?? 210;
      final height = double.tryParse(_customPageHeightController.text) ?? 297;
      pageFormat = PdfPageFormat(
        width * PdfPageFormat.mm,
        height * PdfPageFormat.mm,
      );
    } else {
      pageFormat = _pageFormats[_selectedPageFormat]!;
    }

    if (_isLandscape) {
      pageFormat = pageFormat.landscape;
    }

    // Since this widget is now part of the project feature,
    // we can import the pdf_generator directly.
    await generateVectorPdf(
      vectorObjects: project.vectorObjects,
      imageSize: Size(project.imageWidth!, project.imageHeight!),
      objectOutputSize: double.parse(_objectOutputSizeController.text),
      fontSize: double.parse(_outputFontSizeController.text),
      printBackground: _printBackground,
      originalImageData: project.imageData,
      pageFormat: pageFormat,
      centerImage: _centerImage,
      outputBorders: double.tryParse(_outputBordersController.text) ?? 10.0,
    );
    if (mounted) setState(() => _isSaving = false);
  }

  void _showColorSettingsDialog() {
    final project = ref.read(projectProvider(widget.projectKey)).project;
    if (project == null || !project.isConverted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please convert the image first.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) =>
          const ColorSettingsDialog(colors: []), // TODO: Fix this
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider(widget.projectKey));
    final project = projectState.project;
    if (project == null) {
      return const Scaffold(
        body: Center(child: Text('Project not found or has been deleted.')),
      );
    }

    final bool isImageTooLarge =
        (project.imageWidth ?? 0) > 500 || (project.imageHeight ?? 0) > 500;

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
            width: 300, // Increased width for the tabs
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              children: [
                IgnorePointer(
                  ignoring: isImageTooLarge,
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      const Tab(icon: Icon(Icons.image_outlined)),
                      Tab(
                        icon: Icon(
                          Icons.transform_outlined,
                          color: isImageTooLarge
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Icons.picture_as_pdf_outlined,
                          color: isImageTooLarge
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: isImageTooLarge
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    controller: _tabController,
                    children: [
                      // Image Tab
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Original Dimensions: ${project.imageWidth?.toInt() ?? 'N/A'} x ${project.imageHeight?.toInt() ?? 'N/A'}',
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _downsampleScaleController,
                              decoration: const InputDecoration(
                                labelText: 'Downsample Scale (%)',
                                helperText:
                                    'Reduces image size before conversion. Applied on "Update Image".',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => Hive.box(
                                'settings',
                              ).put('downsampleScale', value),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<Size?>(
                              valueListenable: _resultingDimensionsNotifier,
                              builder: (context, size, child) {
                                final width = size?.width.toInt() ?? '...';
                                final height = size?.height.toInt() ?? '...';
                                return Text(
                                  'Resulting Dimensions: $width x $height',
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            if (projectState.isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final scale =
                                            double.tryParse(
                                              _downsampleScaleController.text,
                                            ) ??
                                            100.0;
                                        ref
                                            .read(
                                              projectProvider(
                                                widget.projectKey,
                                              ).notifier,
                                            )
                                            .updateImage(scale);
                                      },
                                      icon: const Icon(Icons.update),
                                      label: const Text('Update'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => ref
                                        .read(
                                          projectProvider(
                                            widget.projectKey,
                                          ).notifier,
                                        )
                                        .resetImage(),
                                    child: const Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Conversion Tab
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _maxObjectColorsController,
                                decoration: const InputDecoration(
                                  labelText: 'Max. Object Colors',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => Hive.box(
                                  'settings',
                                ).put('maxObjectColors', value),
                              ),
                              const Divider(height: 32),
                              const Text('Preview'),
                              CheckboxListTile(
                                title: const Text('Show Vectors'),
                                value: _showVectors,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _showVectors = value ?? true;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
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
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              const Divider(),
                              TextButton.icon(
                                onPressed: _showColorSettingsDialog,
                                icon: const Icon(Icons.palette_outlined),
                                label: Text(
                                  project.isConverted
                                      ? 'Colors: ${project.uniqueColorCount}'
                                      : 'Colors: N/A',
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (projectState.isLoading)
                                const Center(child: CircularProgressIndicator())
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (project.isConverted) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirm'),
                                            content: const Text(
                                              'This will overwrite the existing grid and resolution data. Are you sure?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  ref
                                                      .read(
                                                        projectProvider(
                                                          widget.projectKey,
                                                        ).notifier,
                                                      )
                                                      .convertProject();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        ref
                                            .read(
                                              projectProvider(
                                                widget.projectKey,
                                              ).notifier,
                                            )
                                            .convertProject();
                                      }
                                    },
                                    icon: const Icon(Icons.transform),
                                    label: const Text('Convert'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Output Tab
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _objectOutputSizeController,
                                decoration: const InputDecoration(
                                  labelText: 'Object Output Size (mm)',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => Hive.box(
                                  'settings',
                                ).put('objectOutputSize', value),
                              ),
                              TextField(
                                controller: _outputFontSizeController,
                                decoration: const InputDecoration(
                                  labelText: 'Font Size',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => Hive.box(
                                  'settings',
                                ).put('outputFontSize', value),
                              ),
                              TextField(
                                controller: _outputBordersController,
                                decoration: const InputDecoration(
                                  labelText: 'Output Borders (mm)',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => Hive.box(
                                  'settings',
                                ).put('outputBorders', value),
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedPageFormat,
                                decoration: const InputDecoration(
                                  labelText: 'Page Format',
                                ),
                                items: _pageFormats.keys.map((String key) {
                                  return DropdownMenuItem<String>(
                                    value: key,
                                    child: Text(key),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPageFormat = newValue!;
                                    Hive.box(
                                      'settings',
                                    ).put('pageFormat', newValue);
                                  });
                                },
                              ),
                              if (_selectedPageFormat == 'Custom')
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _customPageWidthController,
                                        decoration: const InputDecoration(
                                          labelText: 'Width (mm)',
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => Hive.box(
                                          'settings',
                                        ).put('customPageWidth', value),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _customPageHeightController,
                                        decoration: const InputDecoration(
                                          labelText: 'Height (mm)',
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => Hive.box(
                                          'settings',
                                        ).put('customPageHeight', value),
                                      ),
                                    ),
                                  ],
                                ),
                              CheckboxListTile(
                                title: const Text('Landscape'),
                                value: _isLandscape,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isLandscape = value ?? false;
                                    Hive.box(
                                      'settings',
                                    ).put('isLandscape', _isLandscape);
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                title: const Text('Center Image'),
                                value: _centerImage,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _centerImage = value ?? true;
                                    Hive.box(
                                      'settings',
                                    ).put('centerImage', _centerImage);
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                title: const Text('Print background'),
                                value: _printBackground,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _printBackground = value ?? false;
                                    Hive.box(
                                      'settings',
                                    ).put('printBackground', _printBackground);
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 16),
                              if (_isSaving)
                                const CircularProgressIndicator()
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: project.vectorObjects.isEmpty
                                        ? null
                                        : _handlePdfGeneration,
                                    icon: const Icon(
                                      Icons.picture_as_pdf_outlined,
                                    ),
                                    label: const Text('Generate PDF'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
      ..strokeJoin = StrokeJoin.bevel
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, totalGridWidth, totalGridHeight),
      gridPaint,
    );
    final innerLinesPath = Path();
    for (int i = 1; i < imageWidth; i++) {
      final x = offsetX + i * cellWidth;
      innerLinesPath.moveTo(x, offsetY);
      innerLinesPath.lineTo(x, offsetY + totalGridHeight);
    }
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
