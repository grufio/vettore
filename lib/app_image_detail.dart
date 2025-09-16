import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:typed_data';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/section_input.dart';
import 'package:vettore/widgets/button_app.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/data/database.dart';
import 'dart:async';
import 'package:vettore/widgets/input_value_type/width_row.dart';
import 'package:vettore/widgets/input_value_type/height_row.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';
import 'package:vettore/services/canvas_image_helpers.dart';
import 'package:vettore/services/coupling_guard.dart';
import 'package:vettore/services/dimensions_guard.dart';
import 'package:vettore/widgets/input_value_type/interpolation_selector.dart';
import 'package:vettore/widgets/input_value_type/resolution_selector.dart';
import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:file_picker/file_picker.dart';
import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/widgets/input_value_type/interpolation_map.dart';
import 'package:vettore/providers/navigation_providers.dart';
// PhotoView removed in favor of InteractiveViewer for infinite pasteboard

import 'package:vettore/widgets/snackbar_image.dart';

class AppImageDetailPage extends ConsumerStatefulWidget {
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  final int? projectId; // optional for now; when null we load/create first
  final ValueChanged<String>? onProjectTitleSaved;
  final ValueChanged<int>? onDeleteProject;
  const AppImageDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
    this.projectId,
    this.onProjectTitleSaved,
    this.onDeleteProject,
  });

  @override
  ConsumerState<AppImageDetailPage> createState() => _AppImageDetailPageState();
}

class _AppImageDetailPageState extends ConsumerState<AppImageDetailPage> {
  // Header handled by shell; these are no longer needed
  String _detailFilterId = 'project';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _singleInputController;
  late final TextEditingController _projectController;
  String _interp = 'nearest';
  int? _currentProjectId;
  double _rightPanelWidth = 320.0;
  bool _hasImage = false;
  late final FocusNode _projectTitleFocusNode;
  StreamSubscription<DbProject?>? _projectSub;
  // Link/unlink width/height
  bool _linkWH = false;
  // Units for image resize wiring
  String _widthUnit = 'px';
  String _heightUnit = 'px';
  // Original dimensions no longer tracked here; DimensionsRow manages aspect
  // Guard to avoid re-initializing dimensions on stream rebuilds
  int? _lastDimsImageId;
  bool _dimsInitialized = false;
  Uint8List? _lastImageBytes;
  int? _requestedDimsForImageId;
  // InteractiveViewer transform controller for pan/zoom
  final TransformationController _ivController = TransformationController();

  void _setHasImage(bool value) {
    if (!mounted) return;
    setState(() => _hasImage = value);
  }

  // Linking logic is handled inside DimensionsRow
  void _applyImageDims({int? width, int? height}) {
    final int? curW = int.tryParse(_inputValueController.text);
    final int? curH = int.tryParse(_inputValueController2.text);
    final bool should = DimensionsGuard.shouldApply(
      currentWidth: curW,
      currentHeight: curH,
      newWidth: width,
      newHeight: height,
      initialized: _dimsInitialized,
    );
    debugPrint(
        '[ImageDetail] _applyImageDims cur=${curW}x${curH} new=${width}x${height} init=${_dimsInitialized} should=$should');
    if (!should) return;
    DimensionsGuard.writeControllers(
      widthController: _inputValueController,
      heightController: _inputValueController2,
      width: width,
      height: height,
    );
    _dimsInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    _singleInputController = TextEditingController();
    _projectController = TextEditingController();
    // Default interpolation shown in the field
    _singleInputController.text = _interp;
    _projectTitleFocusNode = FocusNode();
    _projectTitleFocusNode.addListener(() {
      if (!_projectTitleFocusNode.hasFocus) {
        _saveProjectTitle();
      }
    });
    _initProject();
  }

  @override
  void dispose() {
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _singleInputController.dispose();
    _projectController.dispose();
    _projectTitleFocusNode.dispose();
    _projectSub?.cancel();
    super.dispose();
  }

  // Image viewer actions will be re-enabled once an image is present.

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Project Detail')),
        child: Center(child: Text('Project Detail')),
      );
    }

    // Ensure current project id provider is set for this view
    final projectIdFromProvider = ref.watch(currentProjectIdProvider);
    if (projectIdFromProvider != null &&
        projectIdFromProvider != _currentProjectId) {
      _currentProjectId = projectIdFromProvider;
    }
    // Image presence is determined via DB stream in the body below
    // Set up provider listeners at the start of build (required by Riverpod)
    final int? _imageIdForListen = (_currentProjectId != null)
        ? ref.watch(imageIdStableProvider(_currentProjectId!))
        : null;
    if (_currentProjectId != null) {
      ref.listen(projectByIdProvider(_currentProjectId!), (prev, next) {
        final int? nextImageId = next.asData?.value?.imageId;
        if (_lastDimsImageId != nextImageId) {
          _lastDimsImageId = nextImageId;
          _dimsInitialized = false;
        }
        // Do not clear fields when image becomes null; keep last known size
      });
    }
    if (_imageIdForListen != null) {
      ref.listen(imageDimensionsProvider(_imageIdForListen), (prev, next) {
        final dims = next.asData?.value;
        if (dims != null) {
          debugPrint('[ImageDetail] provider dims=${dims.$1}x${dims.$2}');
          _dimsInitialized =
              false; // always apply current working size on tab enter
          _applyImageDims(width: dims.$1, height: dims.$2);
        }
      });
      // Also listen to bytes and cache last non-null to avoid flicker on rebuilds
      ref.listen(imageBytesProvider(_imageIdForListen), (prev, next) {
        final b = next.asData?.value;
        if (b != null && mounted) {
          setState(() => _lastImageBytes = b);
        }
      });
    }

    return ColoredBox(
      color: kGrey10,
      child: Column(
        children: [
          // Header handled by shared shell; keep content only when embedded
          // Detail filter bar with bottom border
          Container(
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border(
                bottom: BorderSide(color: kBordersColor, width: 1.0),
              ),
            ),
            child: ContentFilterBar(
              items: const [
                FilterItem(id: 'project', label: 'Project'),
                FilterItem(id: 'image', label: 'Image'),
                FilterItem(id: 'conversion', label: 'Conversion'),
                FilterItem(id: 'grid', label: 'Grid'),
                FilterItem(id: 'output', label: 'Output'),
              ],
              activeId: (() {
                final page = ref.watch(currentPageProvider);
                if (page == PageId.image) return 'image';
                if (page == PageId.project) return 'project';
                return _detailFilterId;
              })(),
              onChanged: (id) {
                setState(() => _detailFilterId = id);
                if (id == 'project') {
                  ref.read(currentPageProvider.notifier).state = PageId.project;
                } else if (id == 'image') {
                  ref.read(currentPageProvider.notifier).state = PageId.image;
                }
              },
              height: 40.0,
              horizontalPadding: 24.0,
              gap: 4.0,
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: kGrey10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main detail area placeholder
                  Expanded(
                    child: _buildDetailBody(),
                  ),
                  // Right side panel (empty for now)
                  SidePanel(
                    side: SidePanelSide.right,
                    width: _rightPanelWidth,
                    topPadding: 0.0,
                    horizontalPadding: 16.0,
                    resizable: true,
                    minWidth: 200.0,
                    maxWidth: 400.0,
                    onResizeDelta: (delta) {
                      setState(() {
                        _rightPanelWidth =
                            (_rightPanelWidth + delta).clamp(200.0, 400.0);
                      });
                    },
                    onResetWidth: () {
                      setState(() {
                        _rightPanelWidth = 320.0;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Builder(builder: (context) {
                          final int? imageId = (_currentProjectId != null)
                              ? ref.watch(
                                  imageIdStableProvider(_currentProjectId!))
                              : null;
                          final bool hasImage = imageId != null;
                          return SectionSidebar(
                            title: 'Title',
                            children: [
                              WidthRow(
                                widthController: _inputValueController,
                                heightController: _inputValueController2,
                                enabled: hasImage,
                                initialLinked: _linkWH,
                                onLinkChanged: (v) => setState(() {
                                  _linkWH = v;
                                }),
                                onUnitChanged: (u) => _widthUnit = u,
                                dpiOverride: (imageId != null)
                                    ? (ref
                                            .watch(imageDpiProvider(imageId))
                                            .asData
                                            ?.value ??
                                        72)
                                    : 72,
                              ),
                              HeightRow(
                                heightController: _inputValueController2,
                                enabled: hasImage,
                                dpiOverride: (imageId != null)
                                    ? (ref
                                            .watch(imageDpiProvider(imageId))
                                            .asData
                                            ?.value ??
                                        72)
                                    : 72,
                                onUnitChanged: (u) => _heightUnit = u,
                              ),
                              InterpolationSelector(
                                value: _interp,
                                onChanged: (v) => setState(() {
                                  _interp = v;
                                  _singleInputController.text = v;
                                }),
                                enabled: hasImage,
                              ),
                              Builder(builder: (context) {
                                final int? imgId = (_currentProjectId != null)
                                    ? ref.watch(imageIdStableProvider(
                                        _currentProjectId!))
                                    : null;
                                final dpiAsync = (imgId != null)
                                    ? ref.watch(imageDpiProvider(imgId))
                                    : const AsyncValue<int?>.data(null);
                                final currentDpi = dpiAsync.asData?.value ?? 72;
                                return ResolutionSelector(
                                  value: currentDpi,
                                  enabled: hasImage,
                                  onChanged: (newDpi) async {
                                    if (imgId == null) return;
                                    final db = ref.read(appDatabaseProvider);
                                    await db.customStatement(
                                      'UPDATE images SET dpi = ? WHERE id = ?',
                                      [newDpi, imgId],
                                    );
                                    ref.invalidate(imageDpiProvider(imgId));
                                  },
                                );
                              }),
                              SectionInput(
                                full: OutlinedActionButton(
                                  label: 'Resize',
                                  onTap: _onResizeTap,
                                ),
                              ),
                            ],
                          );
                        }),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _AppImageDetailPageState {
  void _onResizeTap() async {
    if (_currentProjectId == null) return;
    final int? wVal = int.tryParse(_inputValueController.text.trim());
    final int? hVal = int.tryParse(_inputValueController2.text.trim());
    if (wVal == null || hVal == null) return;
    // Convert to pixels based on selected units and current DPI
    // Resolve current imageId and DPI
    final int? imageId = (_currentProjectId != null)
        ? ref.read(imageIdStableProvider(_currentProjectId!))
        : null;
    final int dpi = (imageId != null)
        ? (ref.read(imageDpiProvider(imageId)).asData?.value ?? 72)
        : 72;

    int toPx(num v, String unit) {
      switch (unit) {
        case 'px':
          return v.round();
        case 'in':
          return (v * dpi).round();
        case 'cm':
          return (v * (dpi / 2.54)).round();
        case 'mm':
          return (v * (dpi / 25.4)).round();
        default:
          return v.round();
      }
    }

    final int targetW = toPx(wVal, _widthUnit);
    final int targetH = toPx(hVal, _heightUnit);
    // Map interpolation string to a suitable name for cv script
    final String interp = kInterpolationToCvName[_interp] ?? 'linear';
    await ref
        .read(projectLogicProvider(_currentProjectId!))
        .resizeToCv(targetW, targetH, interp);
    // Keep showing original bytes per baseline; no session flip
  }

  Future<void> _handleImageBytes(Uint8List bytes) async {
    if (_currentProjectId == null) return;
    debugPrint(
        '[ImageDetail] _handleImageBytes len=${bytes.length} pid=$_currentProjectId');
    // Decode to get dimensions in isolate
    final dims = await compute(ic.decodeDimensions, bytes);
    // Detect DPI from metadata (must exist per spec)
    final int? decodedDpi = await compute(ic.decodeDpi, bytes);
    final int? width = dims.width;
    final int? height = dims.height;
    final imagesDao = ref.read(appDatabaseProvider);
    // Insert image row
    final imageId = await imagesDao.into(imagesDao.images).insert(
          ImagesCompanion.insert(
            origSrc: Value(bytes),
            origBytes: Value(bytes.length),
            origWidth: width != null ? Value(width) : const Value.absent(),
            origHeight: height != null ? Value(height) : const Value.absent(),
            // unique colors unknown here
            thumbnail: const Value.absent(),
            mimeType: const Value('image'),
            convSrc: const Value.absent(),
            convBytes: const Value.absent(),
            convWidth: const Value.absent(),
            convHeight: const Value.absent(),
            convUniqueColors: const Value.absent(),
            origUniqueColors: const Value.absent(),
          ),
        );
    // Persist DPI (schema v22+): write both orig_dpi and dpi
    final int resolvedDpi =
        (decodedDpi != null && decodedDpi > 0) ? decodedDpi : 72;
    await imagesDao.customStatement(
      'UPDATE images SET orig_dpi = ?, dpi = ? WHERE id = ?',
      [resolvedDpi, resolvedDpi, imageId],
    );
    // Point project to this image
    final repo = ref.read(projectRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.update(
      ProjectsCompanion(
        id: Value(_currentProjectId!),
        imageId: Value(imageId),
        updatedAt: Value(now),
      ),
    );
    // Ensure project has a valid canvas size (safety): backfill 100x100 if <=0
    try {
      await imagesDao.customStatement(
        'UPDATE projects SET canvas_width_px = COALESCE(NULLIF(canvas_width_px, 0), 100), canvas_height_px = COALESCE(NULLIF(canvas_height_px, 0), 100) WHERE id = ?',
        [_currentProjectId!],
      );
    } catch (_) {}
    debugPrint('[ImageDetail] image stored id=$imageId; updating controllers');
    // Ensure the new image dimensions overwrite any previous values in fields
    _lastDimsImageId = imageId;
    _dimsInitialized = false;
    _applyImageDims(width: width, height: height);
    // TODO: if DPI is detected, set ResolutionSelector initial value
    // This requires threading dpi into local state; for now, ignore if null
    _setHasImage(true);
  }

  // Dialog upload handled inside ImageUploadArea
  // Dialog upload for ImageUploadText
  Future<void> _pickViaDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    final file = result?.files.first;
    if (file?.bytes != null) {
      await _handleImageBytes(file!.bytes!);
    }
  }

  Future<void> _initProject() async {
    // Determine project to load: prefer explicit id, else load first project if any
    final repo = ref.read(projectRepositoryProvider);
    try {
      if (widget.projectId != null) {
        _currentProjectId = widget.projectId;
        final p = await repo.getById(widget.projectId!);
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        // Do not clear Width/Height on rebuilds
        _subscribeToProject(_currentProjectId!);
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        // Do not clear Width/Height on rebuilds
        _subscribeToProject(_currentProjectId!);
      }
    } catch (_) {
      // Ignore load errors for now; keep empty controller
    }
  }

  Future<void> _saveProjectTitle() async {
    if (_currentProjectId == null) return;
    final repo = ref.read(projectRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final companion = ProjectsCompanion(
      id: Value(_currentProjectId!),
      title: Value(_projectController.text),
      updatedAt: Value(now),
    );
    await repo.update(companion);
    // Notify shell to update tab label
    widget.onProjectTitleSaved?.call(_projectController.text);
  }

  void _subscribeToProject(int projectId) {
    _projectSub?.cancel();
    _projectSub =
        ref.read(projectRepositoryProvider).watchById(projectId).listen((p) {
      if (!mounted) return;
      if (p == null) {
        _setHasImage(false);
        return;
      }
      final nextHasImage = p.imageId != null;
      // Do not clear Width/Height on rebuilds
      if (nextHasImage != _hasImage) _setHasImage(nextHasImage);
    });
  }

  Widget _buildDetailBody() {
    // Prefer explicit widget.projectId, then local state, then provider
    final int? pid = widget.projectId ??
        _currentProjectId ??
        ref.watch(currentProjectIdProvider);
    final int? imageId =
        (pid != null) ? ref.watch(imageIdStableProvider(pid)) : null;
    final Uint8List? bytes = (imageId != null)
        ? (ref.watch(imageBytesProvider(imageId)).asData?.value ??
            _lastImageBytes)
        : _lastImageBytes;

    debugPrint(
        '[ImageDetail] build pid=$pid imageId=$imageId bytes=${bytes?.length ?? 0}');

    // Decide if upload overlay should be shown
    final bool showUpload = (imageId == null);

    // If entering Image tab and fields are empty, fetch dims once and apply
    if (imageId != null &&
        (_inputValueController.text.isEmpty ||
            _inputValueController2.text.isEmpty) &&
        _requestedDimsForImageId != imageId) {
      _requestedDimsForImageId = imageId;
      ref.read(imageDimensionsProvider(imageId).future).then((dims) {
        if (!mounted) return;
        _dimsInitialized = false;
        _applyImageDims(width: dims.$1, height: dims.$2);
      });
    }

    // Canvas size comes from project (independent of image)
    final projectAsync = (pid != null)
        ? ref.watch(projectByIdProvider(pid))
        : const AsyncValue<DbProject?>.data(null);
    final project = projectAsync.asData?.value;
    if (project == null) {
      const double placeholderW = 100.0;
      const double placeholderH = 100.0;
      return Center(
        child: SizedBox(
          width: placeholderW,
          height: placeholderH,
          child: Stack(
            children: [
              const DecoratedBox(decoration: BoxDecoration(color: kWhite)),
              CustomPaint(painter: _HairlineCanvasBorderPainter()),
            ],
          ),
        ),
      );
    }
    // Convert canvas value+unit to px for on-screen preview at 96 dpi
    const int previewDpi = 96;
    debugPrint(
        '[ImageDetail] canvas units: ${project.canvasWidthValue} ${project.canvasWidthUnit} x ${project.canvasHeightValue} ${project.canvasHeightUnit}');
    CouplingGuard.enterCanvasSizing();
    final Size canvasPx = getCanvasPreviewPx(
      widthValue: project.canvasWidthValue,
      widthUnit: project.canvasWidthUnit,
      heightValue: project.canvasHeightValue,
      heightUnit: project.canvasHeightUnit,
      previewDpi: previewDpi,
    );
    CouplingGuard.leaveCanvasSizing();
    debugPrint(
        '[ImageDetail] canvas preview px: ${canvasPx.width.toStringAsFixed(2)} x ${canvasPx.height.toStringAsFixed(2)}');
    if (canvasPx.width <= 0 || canvasPx.height <= 0) {
      const double placeholderW = 100.0;
      const double placeholderH = 100.0;
      return Center(
        child: SizedBox(
          width: placeholderW,
          height: placeholderH,
          child: Stack(
            children: [
              const DecoratedBox(decoration: BoxDecoration(color: kWhite)),
              CustomPaint(painter: _HairlineCanvasBorderPainter()),
            ],
          ),
        ),
      );
    }
    // project is non-null; use converted px for preview only
    final double canvasW = canvasPx.width;
    final double canvasH = canvasPx.height;
    // Compute content extents (pasteboard) from canvas and image sizes
    final dims = (imageId != null)
        ? ref.watch(imageDimensionsProvider(imageId)).asData?.value
        : null;
    final double imgW = (dims?.$1 ?? canvasW.toInt()).toDouble();
    final double imgH = (dims?.$2 ?? canvasH.toInt()).toDouble();
    final double boardW = (imgW > canvasW ? imgW : canvasW) + 200.0;
    final double boardH = (imgH > canvasH ? imgH : canvasH) + 200.0;
    if (showUpload) {
      return Center(
        child: ImageUploadText(
          onImageDropped: (b) => _handleImageBytes(b),
          onUploadTap: _pickViaDialog,
        ),
      );
    }
    return Center(
      child: Stack(
        children: [
          ClipRect(
            child: InteractiveViewer(
              transformationController: _ivController,
              minScale: 0.25,
              maxScale: 8.0,
              child: SizedBox(
                width: boardW,
                height: boardH,
                child: Stack(
                  children: [
                    // Canvas (artboard) centered on pasteboard
                    Positioned(
                      left: (boardW - canvasW) / 2,
                      top: (boardH - canvasH) / 2,
                      width: canvasW,
                      height: canvasH,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const DecoratedBox(
                            decoration: BoxDecoration(color: kWhite),
                          ),
                          // Image centered relative to pasteboard, not clipped by canvas
                          if (bytes != null)
                            Positioned.fill(
                              child: Center(
                                child: Image.memory(
                                  bytes,
                                  fit: BoxFit.none,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                            ),
                          // Constant hairline border over image
                          LayoutBuilder(builder: (context, constraints) {
                            final double s =
                                _ivController.value.getMaxScaleOnAxis();
                            return IgnorePointer(
                              child: CustomPaint(
                                painter: _HairlineBorderPainter(scale: s),
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (bytes != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.0,
              child: Center(
                child: SnackbarImage(
                  onZoomIn: () {
                    final double cur = _ivController.value.getMaxScaleOnAxis();
                    final double next = (cur * 1.25).clamp(0.25, 8.0);
                    final Matrix4 m = _ivController.value.clone();
                    final double factor = next / cur;
                    _ivController.value = m..scale(factor);
                  },
                  onZoomOut: () {
                    final double cur = _ivController.value.getMaxScaleOnAxis();
                    final double next = (cur / 1.25).clamp(0.25, 8.0);
                    final Matrix4 m = _ivController.value.clone();
                    final double factor = next / cur;
                    _ivController.value = m..scale(factor);
                  },
                  onFitToScreen: () {
                    _ivController.value = Matrix4.identity();
                  },
                ),
              ),
            ),
          // If no image, show only the upload prompt (no canvas under it)
          if (showUpload)
            const Positioned.fill(
              child: Center(
                child: SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HairlineCanvasBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = kGrey100
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HairlineBorderPainter extends CustomPainter {
  final double scale;
  const _HairlineBorderPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final double hair = scale == 0 ? 1.0 : (1.0 / scale);
    final Paint p = Paint()
      ..color = kGrey100
      ..strokeWidth = hair
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(covariant _HairlineBorderPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

// _loadImageDimensions removed; dimensions are provided exclusively by imageDimensionsProvider
