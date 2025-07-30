import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/features/projects/widgets/resize_dialog.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/pdf_generator.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/color_settings_dialog.dart';
import 'package:vettore/features/projects/widgets/image_tab_view.dart';
import 'package:vettore/features/projects/widgets/convert_tab_view.dart';
import 'package:vettore/features/projects/widgets/output_tab_view.dart';
import 'package:vettore/features/projects/widgets/grid_tab_view.dart';

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
  // REMOVED:
  // ui.Image? _decodedImage;
  // Uint8List? _loadedImageData;

  late final TextEditingController _maxObjectColorsController;
  late final TextEditingController _objectOutputSizeController;
  late final TextEditingController _outputFontSizeController;
  late final TextEditingController _customPageWidthController;
  late final TextEditingController _customPageHeightController;
  late final TextEditingController _colorSeparationController;
  late final TextEditingController _klController;
  late final TextEditingController _kcController;
  late final TextEditingController _khController;
  bool _isSaving = false;
  Uint8List? _pdfData;
  late final PdfViewerController _pdfController;

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _pdfController = PdfViewerController();

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
    _colorSeparationController = TextEditingController(
      text: settings.colorSeparation.toString(),
    );
    _klController = TextEditingController(
      text: settings.kl.toString(),
    );
    _kcController = TextEditingController(
      text: settings.kc.toString(),
    );
    _khController = TextEditingController(
      text: settings.kh.toString(),
    );
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
    _colorSeparationController.dispose();
    _klController.dispose();
    _kcController.dispose();
    _khController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    final projectState =
        ref.read(projectStreamProvider(widget.projectId)).value;
    if (projectState == null) return;
    final project = projectState.project;
    final isImageTooLarge =
        (project.imageWidth ?? 0) > 500 || (project.imageHeight ?? 0) > 500;

    if (isImageTooLarge && _tabController!.indexIsChanging) {
      if (_tabController!.index != 0) {
        // Allow returning to the first tab, but block moving to others
        if (_tabController!.previousIndex != 0) {
          _tabController!.index = _tabController!.previousIndex;
        } else {
          _tabController!.index = 0;
        }
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
        return true; // Always show the base image
      case 2: // Grid Tab
        return _showBackground; // Controlled by checkbox
      case 3: // PDF Tab
        // Read directly from settings
        return ref.read(settingsServiceProvider).printBackground;
      default:
        return false;
    }
  }

  bool _isVectorLayerVisible() {
    if (_tabController == null) return false;
    switch (_tabController!.index) {
      case 1: // Convert Tab
        return false; // Never show vectors on the convert tab
      case 2: // Grid Tab
        return _showVectors; // Controlled by checkbox
      case 3: // PDF Tab
        return true; // Always show vectors in PDF preview
      default:
        return false;
    }
  }

  Widget _buildCurrentView(Project project, ui.Image? decodedImage,
      List<DisplayVectorObject> displayObjects, SettingsService settings) {
    final currentTabIndex = _tabController?.index ?? 0;

    if (currentTabIndex == 3) {
      if (_pdfData != null) {
        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: SfPdfViewer.memory(
            _pdfData!,
            controller: _pdfController,
          ),
        );
      } else {
        return const Center(child: Text('No preview generated.'));
      }
    } else if (currentTabIndex == 0) {
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
              backgroundImage: decodedImage,
              objects: displayObjects,
              imageSize: Size(
                project.imageWidth ?? 1,
                project.imageHeight ?? 1,
              ),
              fontSize: settings.outputFontSize.toDouble(),
              showBackground: _isBackgroundVisible(),
              showVectors: _isVectorLayerVisible(),
              showNumbers: settings.printNumbers,
              showBorders: settings.printBorders,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handlePdfGeneration() async {
    final projectState =
        ref.read(projectStreamProvider(widget.projectId)).value;
    if (projectState == null) return;
    final project = projectState.project;
    final settings = ref.read(settingsServiceProvider);

    setState(() => _isSaving = true);

    PdfPageFormat pageFormat;
    if (settings.pageFormat == 'Custom') {
      final width = double.tryParse(_customPageWidthController.text) ?? 210;
      final height = double.tryParse(_customPageHeightController.text) ?? 297;
      pageFormat = PdfPageFormat(
        width * PdfPageFormat.mm,
        height * PdfPageFormat.mm,
      );
    } else {
      pageFormat = _pageFormats[settings.pageFormat]!;
    }

    final decodedObjects = jsonDecode(project.vectorObjects) as List;
    final displayObjects = decodedObjects
        .map((obj) =>
            DisplayVectorObject(obj['x'], obj['y'], Color(obj['color'] as int)))
        .toList();

    final pdfBytes = await generateVectorPdf(
      vectorObjects: displayObjects
          .map((e) => PdfVectorObject(x: e.x, y: e.y, color: e.color))
          .toList(),
      imageSize: Size(project.imageWidth ?? 0.0, project.imageHeight ?? 0.0),
      objectOutputSize: double.parse(_objectOutputSizeController.text),
      fontSize: double.parse(_outputFontSizeController.text),
      printCells: settings.printBackground,
      printBorders: settings.printBorders,
      printNumbers: settings.printNumbers,
      originalImageData: project.imageData,
      pageFormat: pageFormat,
    );
    if (mounted) {
      setState(() {
        _pdfData = pdfBytes;
        _isSaving = false;
      });
    }
  }

  void _showColorSettingsDialog() {
    final projectState =
        ref.read(projectStreamProvider(widget.projectId)).value;
    if (projectState == null) {
      // Handle case where project data isn't loaded yet
      return;
    }
    final project = projectState.project;
    if (!project.isConverted) {
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
      data: (projectState) {
        final project = projectState.project;
        // REMOVED old image decoding logic
        // if (!listEquals(_loadedImageData, project.imageData)) { ... }

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
                child: _buildCurrentView(project, projectState.decodedImage,
                    displayObjects, settings),
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
                            Icons.grid_on_outlined,
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
                            colorSeparationController:
                                _colorSeparationController,
                            klController: _klController,
                            kcController: _kcController,
                            khController: _khController,
                            onShowColorSettings: _showColorSettingsDialog,
                          ),
                          GridTabView(
                            project: project,
                            showVectors: _showVectors,
                            showBackground: _showBackground,
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
                            customPageWidthController:
                                _customPageWidthController,
                            customPageHeightController:
                                _customPageHeightController,
                            isSaving: _isSaving,
                            canGenerate: project.vectorObjects.isNotEmpty,
                            onGenerate: _handlePdfGeneration,
                            pageFormats: _pageFormats,
                            selectedPageFormat: settings.pageFormat,
                            onPageFormatChanged: (value) {
                              setState(() {
                                ref
                                    .read(settingsServiceProvider)
                                    .setPageFormat(value);
                              });
                            },
                            printCells: settings.printBackground,
                            onPrintCellsChanged: (value) {
                              setState(() {
                                ref
                                    .read(settingsServiceProvider)
                                    .setPrintBackground(value);
                              });
                            },
                            printBorders: settings.printBorders,
                            onPrintBordersChanged: (value) {
                              setState(() {
                                ref
                                    .read(settingsServiceProvider)
                                    .setPrintBorders(value);
                              });
                            },
                            printNumbers: settings.printNumbers,
                            onPrintNumbersChanged: (value) {
                              setState(() {
                                ref
                                    .read(settingsServiceProvider)
                                    .setPrintNumbers(value);
                              });
                            },
                            pdfController: _pdfController,
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
  final bool showBorders;

  VectorPainter({
    this.backgroundImage,
    required this.objects,
    required this.imageSize,
    required this.fontSize,
    required this.showNumbers,
    required this.showBackground,
    required this.showVectors,
    required this.showBorders,
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

        if (showBorders) {
          final borderPaint = Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawRect(rect, borderPaint);
        }

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
        oldDelegate.showVectors != showVectors ||
        oldDelegate.showBorders != showBorders;
  }
}
