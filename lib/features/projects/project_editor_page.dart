import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/features/projects/widgets/resize_dialog.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/pdf_generator.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/color_settings_dialog.dart';
import 'package:vettore/features/projects/widgets/image_tab_view.dart';
import 'package:vettore/features/projects/widgets/convert_tab_view.dart';
import 'package:vettore/features/projects/widgets/output_tab_view.dart';

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

  // State for the decoded image
  ui.Image? _decodedImage;
  Uint8List? _loadedImageData;

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
          child: CustomPaint(
            painter: VectorPainter(
              backgroundImage: _decodedImage,
              objects: displayObjects,
              imageSize: Size(
                project.imageWidth ?? 1,
                project.imageHeight ?? 1,
              ),
              fontSize: settings.outputFontSize.toDouble(),
              showBackground: _isBackgroundVisible(),
              showVectors: _isVectorLayerVisible(),
              showNumbers: _isVectorLayerVisible(),
            ),
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
        if (!listEquals(_loadedImageData, project.imageData)) {
          _loadedImageData = project.imageData;
          // Reset image and start decoding
          _decodedImage = null;
          if (project.imageData.isNotEmpty) {
            ui.instantiateImageCodec(project.imageData).then((codec) {
              return codec.getNextFrame();
            }).then((frame) {
              if (mounted) {
                setState(() {
                  _decodedImage = frame.image;
                });
              }
            });
          }
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
                          ImageTabView(
                            project: project,
                            isImageTooLarge: isImageTooLarge,
                          ),
                          ConvertTabView(
                            project: project,
                            settings: settings,
                            maxObjectColorsController:
                                _maxObjectColorsController,
                            showVectors: _showVectors,
                            showBackground: _showBackground,
                            onShowColorSettings: _showColorSettingsDialog,
                            onShowVectorsChanged: (value) {
                              setState(() {
                                _showVectors = value;
                              });
                            },
                            onShowBackgroundChanged: (value) {
                              setState(() {
                                _showBackground = value;
                              });
                            },
                          ),
                          OutputTabView(
                            settings: settings,
                            objectOutputSizeController:
                                _objectOutputSizeController,
                            outputFontSizeController: _outputFontSizeController,
                            outputBordersController: _outputBordersController,
                            customPageWidthController:
                                _customPageWidthController,
                            customPageHeightController:
                                _customPageHeightController,
                            isSaving: _isSaving,
                            canGenerate: project.vectorObjects.isNotEmpty,
                            onGenerate: _handlePdfGeneration,
                            pageFormats: _pageFormats,
                            selectedPageFormat: _selectedPageFormat,
                            onPageFormatChanged: (value) {
                              setState(() {
                                _selectedPageFormat = value;
                                settings.setPageFormat(value);
                              });
                            },
                            isLandscape: _isLandscape,
                            onLandscapeChanged: (value) {
                              setState(() {
                                _isLandscape = value;
                                settings.setIsLandscape(value);
                              });
                            },
                            centerImage: _centerImage,
                            onCenterImageChanged: (value) {
                              setState(() {
                                _centerImage = value;
                                settings.setCenterImage(value);
                              });
                            },
                            printBackground: _printBackground,
                            onPrintBackgroundChanged: (value) {
                              setState(() {
                                _printBackground = value;
                                settings.setPrintBackground(value);
                              });
                            },
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
  final ui.Image? backgroundImage;
  final List<DisplayVectorObject> objects;
  final Size imageSize;
  final double fontSize;
  final bool showNumbers;
  final bool showBackground;
  final bool showVectors;

  VectorPainter({
    this.backgroundImage,
    required this.objects,
    required this.imageSize,
    required this.fontSize,
    required this.showNumbers,
    required this.showBackground,
    required this.showVectors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Calculate the destination rectangle to fit the image with aspect ratio
    final double imageWidth = imageSize.width;
    final double imageHeight = imageSize.height;
    if (imageWidth == 0 || imageHeight == 0) return;

    final imageAspectRatio = imageWidth / imageHeight;
    final canvasAspectRatio = size.width / size.height;

    double dstWidth;
    double dstHeight;

    if (imageAspectRatio > canvasAspectRatio) {
      dstWidth = size.width;
      dstHeight = dstWidth / imageAspectRatio;
    } else {
      dstHeight = size.height;
      dstWidth = dstHeight * imageAspectRatio;
    }

    final dstRect = Rect.fromLTWH(
      (size.width - dstWidth) / 2,
      (size.height - dstHeight) / 2,
      dstWidth,
      dstHeight,
    );

    // Layer 1: Background Image
    if (showBackground && backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(
          0,
          0,
          backgroundImage!.width.toDouble(),
          backgroundImage!.height.toDouble(),
        ),
        dstRect,
        Paint()..filterQuality = FilterQuality.none,
      );
    }

    // Layer 2: Vectors and Numbers (drawn within the same dstRect)
    if (showVectors && objects.isNotEmpty) {
      final cellWidth = dstRect.width / imageWidth;
      final cellHeight = dstRect.height / imageHeight;

      final uniqueColors = objects.map((o) => o.color).toSet().toList();
      for (final obj in objects) {
        final rect = Rect.fromLTWH(
          dstRect.left + (obj.x * cellWidth),
          dstRect.top + (obj.y * cellHeight),
          cellWidth,
          cellHeight,
        );

        final borderPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawRect(rect, borderPaint);

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
    return oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.objects != objects ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.fontSize != fontSize ||
        oldDelegate.showNumbers != showNumbers ||
        oldDelegate.showBackground != showBackground ||
        oldDelegate.showVectors != showVectors;
  }
}
