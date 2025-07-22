import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/features/projects/widgets/resize_dialog.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/pdf_generator.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/color_settings_dialog.dart';

class ProjectEditorPage extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectEditorPage({super.key, required this.projectId});
  @override
  ConsumerState<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class DisplayVectorObject {
  final int x, y;
  final Color color;
  DisplayVectorObject(this.x, this.y, this.color);
}

class _ProjectEditorPageState extends ConsumerState<ProjectEditorPage>
    with SingleTickerProviderStateMixin {
  bool _showVectors = true;
  bool _showBackground = true;

  late final TextEditingController _maxObjectColorsController;
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
    final settings = ref.read(settingsServiceProvider);
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(_handleTabSelection);

    _maxObjectColorsController = TextEditingController(
      text: settings.maxObjectColors.toString(),
    );

    _objectOutputSizeController = TextEditingController(
      text: settings.objectOutputSize.toString(),
    );
    _outputFontSizeController = TextEditingController(
      text: settings.outputFontSize.toString(),
    );
    _customPageWidthController = TextEditingController(
      text: settings.customPageWidth.toString(),
    );
    _customPageHeightController = TextEditingController(
      text: settings.customPageHeight.toString(),
    );
    _outputBordersController = TextEditingController(
      text: settings.outputBorders.toString(),
    );
    _printBackground = settings.printBackground;
    _selectedPageFormat = settings.pageFormat;
    _centerImage = settings.centerImage;
    _isLandscape = settings.isLandscape;
  }

  @override
  void dispose() {
    _tabController!.removeListener(_handleTabSelection);
    _tabController!.dispose();
    _maxObjectColorsController.dispose();
    _objectOutputSizeController.dispose();
    _outputFontSizeController.dispose();
    _customPageWidthController.dispose();
    _customPageHeightController.dispose();
    _outputBordersController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    final project = ref.read(projectStreamProvider(widget.projectId)).value;
    if (project == null) return;
    final isImageTooLarge =
        (project.imageWidth ?? 0) > 500 || (project.imageHeight ?? 0) > 500;

    if (isImageTooLarge && _tabController!.indexIsChanging) {
      if (_tabController!.index != 0) {
        _tabController!.index = 0;
      }
    }
    // This setState will trigger a rebuild when the tab changes,
    // which is needed to update the painter's visibility flags.
    setState(() {});
  }

  bool _isBackgroundVisible() {
    if (_tabController == null) return false;
    switch (_tabController!.index) {
      case 0: // Image Tab
        return true;
      case 1: // Convert Tab
        return _showBackground;
      case 2: // PDF Tab
        return _printBackground;
      default:
        return false;
    }
  }

  bool _isVectorLayerVisible() {
    if (_tabController == null) return false;
    switch (_tabController!.index) {
      case 1: // Convert Tab
        return _showVectors;
      case 2: // PDF Tab
        return true; // Always show vectors in PDF preview
      default:
        return false;
    }
  }

  Widget _buildCurrentView(Project project,
      List<DisplayVectorObject> displayObjects, SettingsService settings) {
    final currentTabIndex = _tabController?.index ?? 0;

    if (currentTabIndex == 0) {
      // Viewer for Image Tab
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: Image.memory(
          project.imageData,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      );
    } else {
      // Advanced Viewer for Convert & PDF Tabs
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: AspectRatio(
          aspectRatio: (project.imageWidth ?? 1) / (project.imageHeight ?? 1),
          child: Stack(
            key: ValueKey(
                '${_tabController?.index}:${_showBackground}:${_showVectors}:${_printBackground}'),
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: _isBackgroundVisible() ? 1.0 : 0.0,
                  child: Image.memory(
                    project.imageData,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: _isVectorLayerVisible() ? 1.0 : 0.0,
                  child: CustomPaint(
                    painter: VectorPainter(
                      objects: displayObjects,
                      imageSize: Size(
                        project.imageWidth ?? 1,
                        project.imageHeight ?? 1,
                      ),
                      fontSize: settings.outputFontSize.toDouble(),
                      showNumbers: _showVectors,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _handlePdfGeneration() async {
    final project = ref.read(projectStreamProvider(widget.projectId)).value;
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

    final decodedObjects = jsonDecode(project.vectorObjects) as List;
    final displayObjects = decodedObjects
        .map((obj) =>
            DisplayVectorObject(obj['x'], obj['y'], Color(obj['color'] as int)))
        .toList();

    await generateVectorPdf(
      vectorObjects: displayObjects
          .map((e) => PdfVectorObject(x: e.x, y: e.y, color: e.color))
          .toList(),
      imageSize: Size(project.imageWidth ?? 0.0, project.imageHeight ?? 0.0),
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
    final project = ref.read(projectStreamProvider(widget.projectId)).value;
    if (project == null || !project.isConverted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please convert the image first.')),
      );
      return;
    }

    final decodedObjects = jsonDecode(project.vectorObjects) as List;
    final uniqueColors = decodedObjects
        .map((obj) => Color(obj['color'] as int))
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => ColorSettingsDialog(colors: uniqueColors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectAsyncValue =
        ref.watch(projectStreamProvider(widget.projectId));
    final settings = ref.watch(settingsServiceProvider);

    return projectAsyncValue.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      data: (project) {
        if (project == null) {
          return const Scaffold(
            body: Center(child: Text('Project not found.')),
          );
        }

        final List<DisplayVectorObject> displayObjects;
        if (project.isConverted && project.vectorObjects.isNotEmpty) {
          final decoded = jsonDecode(project.vectorObjects) as List;
          displayObjects = decoded
              .map((obj) => DisplayVectorObject(
                  obj['x'], obj['y'], Color(obj['color'] as int)))
              .toList();
        } else {
          displayObjects = [];
        }

        final bool isImageTooLarge =
            (project.imageWidth ?? 0) > 500 || (project.imageHeight ?? 0) > 500;

        return Scaffold(
          appBar: AppBar(title: Text(project.name)),
          body: Row(
            children: [
              Expanded(
                child: _buildCurrentView(project, displayObjects, settings),
              ),
              Container(
                width: 300,
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Column(
                  children: [
                    TabBar(
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
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Image Tab
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Original Dimensions: ${project.originalImageWidth?.toInt() ?? 'N/A'} x ${project.originalImageHeight?.toInt() ?? 'N/A'}',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Current Dimensions: ${project.imageWidth?.toInt() ?? 'N/A'} x ${project.imageHeight?.toInt() ?? 'N/A'}',
                                ),
                                const SizedBox(height: 16),
                                if (isImageTooLarge)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      'Image > 500px. Please update.',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final result =
                                              await showDialog<ResizeResult>(
                                            context: context,
                                            builder: (context) =>
                                                const ResizeDialog(),
                                          );

                                          if (result != null && mounted) {
                                            ref
                                                .read(projectLogicProvider(
                                                    widget.projectId))
                                                .updateImage(
                                                  result.percentage,
                                                  result.filterQuality,
                                                );
                                          }
                                        },
                                        child: const Text('Resize Image'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: (project.originalImageData ==
                                              null)
                                          ? null
                                          : () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text('Confirm'),
                                                  content: const Text(
                                                    'You are loosing all information',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                        context,
                                                      ).pop(),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        ref
                                                            .read(projectLogicProvider(
                                                                widget
                                                                    .projectId))
                                                            .resetImage();
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      child: const Text('Reset'),
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
                                    onChanged: (value) => settings
                                        .setMaxObjectColors(int.parse(value)),
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
                                          ? 'Colors: ${project.uniqueColorCount ?? 0}'
                                          : 'Colors: N/A',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
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
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    ref
                                                        .read(
                                                            projectLogicProvider(
                                                                widget
                                                                    .projectId))
                                                        .convertProject();
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          ref
                                              .read(projectLogicProvider(
                                                  widget.projectId))
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
                                    onChanged: (value) =>
                                        settings.setObjectOutputSize(
                                            double.parse(value)),
                                  ),
                                  TextField(
                                    controller: _outputFontSizeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Font Size',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => settings
                                        .setOutputFontSize(int.parse(value)),
                                  ),
                                  TextField(
                                    controller: _outputBordersController,
                                    decoration: const InputDecoration(
                                      labelText: 'Output Borders (mm)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => settings
                                        .setOutputBorders(double.parse(value)),
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
                                        settings.setPageFormat(newValue);
                                      });
                                    },
                                  ),
                                  if (_selectedPageFormat == 'Custom')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                _customPageWidthController,
                                            decoration: const InputDecoration(
                                              labelText: 'Width (mm)',
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) =>
                                                settings.setCustomPageWidth(
                                                    double.parse(value)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                _customPageHeightController,
                                            decoration: const InputDecoration(
                                              labelText: 'Height (mm)',
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) =>
                                                settings.setCustomPageHeight(
                                                    double.parse(value)),
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
                                        settings.setIsLandscape(_isLandscape);
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
                                        settings.setCenterImage(_centerImage);
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
                                        settings.setPrintBackground(
                                            _printBackground);
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
                                        onPressed:
                                            (project.vectorObjects).isEmpty
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
      },
    );
  }
}

class VectorPainter extends CustomPainter {
  final List<DisplayVectorObject> objects;
  final Size imageSize;
  final double fontSize;
  final bool showNumbers;

  VectorPainter({
    required this.objects,
    required this.imageSize,
    required this.fontSize,
    required this.showNumbers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final imageWidth = imageSize.width;
    final imageHeight = imageSize.height;
    if (imageWidth == 0 || imageHeight == 0) return;

    final cellWidth = size.width / imageWidth;
    final cellHeight = size.height / imageHeight;

    if (objects.isNotEmpty) {
      final uniqueColors = objects.map((o) => o.color).toSet().toList();
      for (final obj in objects) {
        final rect = Rect.fromLTWH(
          obj.x * cellWidth,
          obj.y * cellHeight,
          cellWidth,
          cellHeight,
        );
        final cellPaint = Paint()
          ..color = obj.color
          ..isAntiAlias = false;
        canvas.drawRect(rect, cellPaint);

        if (showNumbers) {
          final colorIndex = uniqueColors.indexOf(obj.color);
          final textSpan = TextSpan(
            text: '${colorIndex + 1}',
            style: TextStyle(
              color: Colors.red,
              fontSize: fontSize,
            ),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: ui.TextDirection.ltr,
          );
          textPainter.layout(minWidth: 0, maxWidth: cellWidth);
          final textOffset = Offset(
            rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2,
          );
          textPainter.paint(canvas, textOffset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant VectorPainter oldDelegate) {
    return oldDelegate.objects != objects ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.fontSize != fontSize ||
        oldDelegate.showNumbers != oldDelegate.showNumbers;
  }
}
