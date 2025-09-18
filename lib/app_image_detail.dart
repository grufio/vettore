import 'dart:io' show File;

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
import 'package:vettore/providers/canvas_preview_provider.dart';
import 'package:vettore/services/dimensions_guard.dart';
import 'package:vettore/widgets/input_value_type/interpolation_selector.dart';
import 'package:vettore/widgets/input_value_type/resolution_selector.dart';
import 'package:flutter/foundation.dart'
    show compute, debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/rendering.dart' show MatrixUtils;
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

class _AppImageDetailPageState extends ConsumerState<AppImageDetailPage>
    with AutomaticKeepAliveClientMixin {
  static Matrix4? _savedTransform;
  // Header handled by shell; these are no longer needed
  String _detailFilterId = 'project';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _projectController;
  String _interp = 'nearest';
  int? _currentProjectId;
  double _rightPanelWidth = 320.0;
  bool _hasImage = false;
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
  // Removed fallback image bytes; we render directly from provider for stability
  int? _requestedDimsForImageId;
  int? _lastProjectId;
  int? _lastImageId;
  // InteractiveViewer transform controller for pan/zoom
  final TransformationController _ivController = TransformationController();
  // Viewport key to compute center for zoom focus
  final GlobalKey _viewportKey = GlobalKey();
  @override
  bool get wantKeepAlive => true;
  // Apply 48px padding only on first open of the Image tab
  // Removed first-frame padding; use initial matrix translation instead

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
    // Do not auto-convert user units. Only populate when both fields are 'px'.
    if (_widthUnit == 'px' && _heightUnit == 'px') {
      DimensionsGuard.writeControllers(
        widthController: _inputValueController,
        heightController: _inputValueController2,
        width: width,
        height: height,
      );
    }
    _dimsInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    _projectController = TextEditingController();
    // Restore last pan/zoom state if available; avoid auto-centering
    if (_savedTransform != null) {
      _ivController.value = _savedTransform!.clone();
    }
    _initProject();
  }

  // didChangeDependencies no longer hosts ref.listen; listeners are set in build

  @override
  void dispose() {
    // Persist current transform to survive tab switches
    _savedTransform = _ivController.value.clone();
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _projectController.dispose();
    _projectSub?.cancel();
    _ivController.dispose();
    super.dispose();
  }

  // Image viewer actions will be re-enabled once an image is present.

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    if (!isMac) {
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

    // Guarded listeners (allowed in build)
    if (_currentProjectId != null && _currentProjectId != _lastProjectId) {
      _lastProjectId = _currentProjectId;
      ref.listen(projectByIdProvider(_currentProjectId!), (prev, next) {
        final int? nextImageId = next.asData?.value?.imageId;
        if (_lastDimsImageId != nextImageId) {
          _lastDimsImageId = nextImageId;
          _dimsInitialized = false;
        }
      });
    }

    final int? imgIdForBuild = (_currentProjectId != null)
        ? ref.watch(imageIdStableProvider(_currentProjectId!))
        : null;
    if (imgIdForBuild != null && imgIdForBuild != _lastImageId) {
      _lastImageId = imgIdForBuild;
      ref.listen(imageDimensionsProvider(imgIdForBuild), (prev, next) {
        final dims = next.asData?.value;
        if (dims != null && !_dimsInitialized) {
          _applyImageDims(width: dims.$1, height: dims.$2);
        }
      });
    }

    // Image presence determined via providers; listeners are registered in didChangeDependencies

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
    final double? wVal = double.tryParse(_inputValueController.text.trim());
    final double? hVal = double.tryParse(_inputValueController2.text.trim());
    if (wVal == null || hVal == null) return;
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
        case 'pt':
          return (v * (dpi / 72.0)).round();
        default:
          return v.round();
      }
    }

    final int targetW = toPx(wVal, _widthUnit);
    final int targetH = toPx(hVal, _heightUnit);
    if (targetW <= 0 || targetH <= 0) return;
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
    final String mime = ic.detectMimeType(bytes);
    final imageId = await imagesDao.into(imagesDao.images).insert(
          ImagesCompanion.insert(
            origSrc: Value(bytes),
            origBytes: Value(bytes.length),
            origWidth: width != null ? Value(width) : const Value.absent(),
            origHeight: height != null ? Value(height) : const Value.absent(),
            // unique colors unknown here
            thumbnail: const Value.absent(),
            mimeType: Value(mime),
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
    // Do not modify project canvas from Image upload path (strict decoupling)
    debugPrint('[ImageDetail] image stored id=$imageId; updating controllers');
    // Ensure the new image dimensions overwrite any previous values in fields
    _lastDimsImageId = imageId;
    _dimsInitialized = false;
    _applyImageDims(width: width, height: height);
    _setHasImage(true);
  }

  Future<void> _pickViaDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'PNG', 'JPG', 'JPEG'],
    );
    final file = result?.files.first;
    if (file?.path != null) {
      final bytes = await File(file!.path!).readAsBytes();
      await _handleImageBytes(bytes);
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
        _subscribeToProject(_currentProjectId!);
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        _subscribeToProject(_currentProjectId!);
      }
    } catch (_) {
      // Ignore load errors for now; keep empty controller
    }
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
        ? ref.watch(imageBytesProvider(imageId)).asData?.value
        : null;

    debugPrint(
        '[ImageDetail] build pid=$pid imageId=$imageId bytes=${bytes?.length ?? 0}');

    final bool showUpload = (imageId == null);

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

    // Canvas via project fields (decoupled) — fallback placeholder when missing
    if (pid == null) {
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
    final canvasAsync = ref.watch(canvasPreviewPxProvider(pid));
    final Size canvasPx = canvasAsync.asData?.value ?? const Size(100.0, 100.0);
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

    final double canvasW = canvasPx.width;
    final double canvasH = canvasPx.height;
    final dims = (imageId != null)
        ? ref.watch(imageDimensionsProvider(imageId)).asData?.value
        : null;
    final double imgW = (dims?.$1 ?? canvasW.toInt()).toDouble();
    final double imgH = (dims?.$2 ?? canvasH.toInt()).toDouble();
    final double maxContentW = imgW > canvasW ? imgW : canvasW;
    final double maxContentH = imgH > canvasH ? imgH : canvasH;
    final double margin = (0.1 * (maxContentW)).clamp(120.0, 480.0);
    final double boardW = maxContentW + margin;
    final double boardH = maxContentH + margin;

    if (showUpload) {
      return Center(
        child: ImageUploadText(
          onImageDropped: (b) => _handleImageBytes(b),
          onUploadTap: _pickViaDialog,
        ),
      );
    }

    const double pad = 0.0;
    return Stack(
      children: [
        _ArtboardView(
          controller: _ivController,
          boardW: boardW,
          boardH: boardH,
          canvasW: canvasW,
          canvasH: canvasH,
          bytes: bytes,
          outerPad: pad,
          viewportKey: _viewportKey,
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
                  final double factor = next / cur;
                  final RenderBox? box = _viewportKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  final Size vp = box?.size ?? const Size(0, 0);
                  if (vp.width == 0 || vp.height == 0) {
                    final Matrix4 m = _ivController.value.clone();
                    _ivController.value = m..scale(factor);
                    return;
                  }
                  final Offset viewportCenter =
                      Offset(vp.width / 2, vp.height / 2);
                  final Matrix4 inv =
                      Matrix4.inverted(_ivController.value.clone());
                  final Offset sceneFocal =
                      MatrixUtils.transformPoint(inv, viewportCenter);
                  final Matrix4 m = _ivController.value.clone()
                    ..translate(sceneFocal.dx, sceneFocal.dy)
                    ..scale(factor)
                    ..translate(-sceneFocal.dx, -sceneFocal.dy);
                  _ivController.value = m;
                },
                onZoomOut: () {
                  final double cur = _ivController.value.getMaxScaleOnAxis();
                  final double next = (cur / 1.25).clamp(0.25, 8.0);
                  final double factor = next / cur;
                  final RenderBox? box = _viewportKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  final Size vp = box?.size ?? const Size(0, 0);
                  if (vp.width == 0 || vp.height == 0) {
                    final Matrix4 m = _ivController.value.clone();
                    _ivController.value = m..scale(factor);
                    return;
                  }
                  final Offset viewportCenter =
                      Offset(vp.width / 2, vp.height / 2);
                  final Matrix4 inv =
                      Matrix4.inverted(_ivController.value.clone());
                  final Offset sceneFocal =
                      MatrixUtils.transformPoint(inv, viewportCenter);
                  final Matrix4 m = _ivController.value.clone()
                    ..translate(sceneFocal.dx, sceneFocal.dy)
                    ..scale(factor)
                    ..translate(-sceneFocal.dx, -sceneFocal.dy);
                  _ivController.value = m;
                },
                onFitToScreen: () {
                  _ivController.value = Matrix4.identity();
                },
              ),
            ),
          ),
        if (showUpload)
          const Positioned.fill(
            child: Center(
              child: SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

class _ArtboardView extends StatelessWidget {
  final TransformationController controller;
  final double boardW;
  final double boardH;
  final double canvasW;
  final double canvasH;
  final Uint8List? bytes;
  final double outerPad;
  final Key? viewportKey;
  const _ArtboardView({
    required this.controller,
    required this.boardW,
    required this.boardH,
    required this.canvasW,
    required this.canvasH,
    required this.bytes,
    this.outerPad = 0.0,
    this.viewportKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRect(
        child: InteractiveViewer(
          key: viewportKey,
          transformationController: controller,
          minScale: 0.25,
          maxScale: 8.0,
          scaleEnabled: true,
          panEnabled: true,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(100000),
          child: RepaintBoundary(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(outerPad),
                child: SizedBox(
                  width: boardW,
                  height: boardH,
                  child: Stack(
                    children: [
                      Positioned(
                        left: (boardW - canvasW) / 2,
                        top: (boardH - canvasH) / 2,
                        width: canvasW,
                        height: canvasH,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Positioned.fill(
                              child: ColoredBox(color: kWhite),
                            ),
                            if (bytes != null)
                              Center(
                                child: OverflowBox(
                                  minWidth: 0,
                                  minHeight: 0,
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                  child: Image.memory(
                                    bytes!,
                                    fit: BoxFit.none,
                                    alignment: Alignment.center,
                                    filterQuality: FilterQuality.none,
                                    cacheWidth: canvasW.ceil(),
                                    cacheHeight: canvasH.ceil(),
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                            LayoutBuilder(builder: (context, constraints) {
                              final double s =
                                  controller.value.getMaxScaleOnAxis();
                              final double dpr =
                                  MediaQuery.of(context).devicePixelRatio;
                              return IgnorePointer(
                                child: CustomPaint(
                                  painter: _HairlineBorderPainter(
                                      scale: s, dpr: dpr),
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
          ),
        ),
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
  final double dpr;
  const _HairlineBorderPainter({required this.scale, required this.dpr});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a crisp hairline (1 physical pixel) regardless of zoom/DPR.
    // Use strokeWidth=0.0 (Flutter hairline) and snap the rect to the
    // device pixel grid in the transformed space by insetting by
    // 0.5/(dpr*scale) on all sides to avoid antialias broadening.
    final double s = scale <= 0 ? 1.0 : scale;
    final double ratio = dpr <= 0 ? 1.0 : dpr;
    final double inset = 0.5 / (ratio * s);
    final Rect rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2.0,
      size.height - inset * 2.0,
    );

    final Paint p = Paint()
      ..color = kGrey100
      ..strokeWidth = 0.0 // true hairline
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _HairlineBorderPainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.dpr != dpr;
}

// _loadImageDimensions removed; dimensions are provided exclusively by imageDimensionsProvider
