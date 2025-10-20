import 'dart:io' show File;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:typed_data';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/data/database.dart';
import 'dart:async';
// Replaced specific rows with unified DimensionRow (now used inside panel)
import 'package:vettore/providers/canvas_preview_provider.dart';
// dimensions_guard not used here any more
import 'package:flutter/foundation.dart'
    show compute, debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:file_picker/file_picker.dart';
import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/services/image_detail_service.dart';
import 'package:vettore/widgets/input_value_type/interpolation_map.dart';
import 'package:vettore/providers/navigation_providers.dart';
// PhotoView removed in favor of InteractiveViewer for infinite pasteboard

import 'package:vettore/widgets/image_preview.dart';
import 'package:vettore/services/image_detail_controller.dart';
// Dimension panel now wrapped by ImageDimensionsSection
import 'package:vettore/widgets/image_dimensions_section.dart';
import 'package:vettore/widgets/artboard_view.dart';
// removed unused image_resize_service import after inlining px computation

class AppImageDetailPage extends ConsumerStatefulWidget {
  const AppImageDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
    this.projectId,
    this.onProjectTitleSaved,
    this.onDeleteProject,
  });
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  final int? projectId; // optional for now; when null we load/create first
  final ValueChanged<String>? onProjectTitleSaved;
  final ValueChanged<int>? onDeleteProject;

  @override
  ConsumerState<AppImageDetailPage> createState() => _AppImageDetailPageState();
}

class _AppImageDetailPageState extends ConsumerState<AppImageDetailPage>
    with AutomaticKeepAliveClientMixin {
  static final Map<int, Matrix4> _savedTransforms = <int, Matrix4>{};
  bool _transformAppliedForProject = false;
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
  // Units are controlled by ImageDetailController
  // Original dimensions no longer tracked here; DimensionsRow manages aspect
  // Guard to avoid re-initializing dimensions on stream rebuilds
  // moved to controller
  // Removed one-time init gate; we now apply dims whenever they change
  // Removed fallback image bytes; we render directly from provider for stability
  int? _requestedDimsForImageId;
  int? _lastProjectId;
  int? _lastImageId;
  // moved to controller
  // InteractiveViewer transform controller for pan/zoom
  final TransformationController _ivController = TransformationController();
  // Viewport key to compute center for zoom focus
  final GlobalKey _viewportKey = GlobalKey();
  // Central controller (wraps UnitValueControllers)
  ImageDetailController? _imgCtrl;
  // Removed last-phys trackers; commit-on-resize policy
  @override
  bool get wantKeepAlive => true;
  // Apply 48px padding only on first open of the Image tab
  // Removed first-frame padding; use initial matrix translation instead

  void _setHasImage(bool value) {
    if (!mounted) return;
    setState(() => _hasImage = value);
  }

  // Linking logic is handled inside DimensionsRow

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    _projectController = TextEditingController();
    // Transform will be restored once when project id is known
    _initProject();
    // Initialize controller and link internal VCs
    _imgCtrl = ImageDetailController();
    // Commit-on-resize policy: do not persist phys during typing
  }

  // didChangeDependencies no longer hosts ref.listen; listeners are set in build

  @override
  void dispose() {
    // Persist current transform to survive tab switches
    if (_currentProjectId != null) {
      _savedTransforms[_currentProjectId!] = _ivController.value.clone();
    }
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
      _transformAppliedForProject = false;
    }

    // Guarded listeners (allowed in build)
    if (_currentProjectId != null && _currentProjectId != _lastProjectId) {
      _lastProjectId = _currentProjectId;
      // No longer listen here; controller will listen to image dimensions when we know imageId
    }

    final int? imgIdForBuild = (_currentProjectId != null)
        ? ref.watch(imageIdStableProvider(_currentProjectId!))
        : null;
    if (imgIdForBuild != null && imgIdForBuild != _lastImageId) {
      _lastImageId = imgIdForBuild;
      // Listen to physical pixel floats and seed controllers
      _imgCtrl?.listenImagePhysPx(
        ref: ref,
        imageId: imgIdForBuild,
        onDims: (wPx, hPx) =>
            _imgCtrl?.applyRemotePx(widthPx: wPx, heightPx: hPx),
      );
      // Sync controller DPI to the image DPI on image change
      ref.read(imageDpiProvider(imgIdForBuild).future).then((dpiVal) {
        if (!mounted) return;
        if (dpiVal != null && dpiVal > 0) {
          _imgCtrl?.setUiDpi(dpiVal);
        }
      });
    }

    // Restore per-project transform once when project id is ready
    if (!_transformAppliedForProject && _currentProjectId != null) {
      final Matrix4? saved = _savedTransforms[_currentProjectId!];
      if (saved != null) {
        _ivController.value = saved.clone();
      }
      _transformAppliedForProject = true;
    }

    // Image presence determined via providers; listeners are registered in didChangeDependencies

    return ColoredBox(
      color: kGrey10,
      child: Column(
        children: [
          // Header handled by shared shell; keep content only when embedded
          // Detail filter bar with bottom border
          DecoratedBox(
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border(
                bottom: BorderSide(color: kBordersColor),
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
                    resizable: true,
                    minWidth: 200.0,
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
                        ImageDimensionsSection(
                          projectId: _currentProjectId!,
                          widthTextController: _inputValueController,
                          heightTextController: _inputValueController2,
                          imgCtrl: _imgCtrl!,
                          linkWH: _linkWH,
                          onLinkChanged: (v) => setState(() => _linkWH = v),
                          interpolation: _interp,
                          onInterpolationChanged: (v) => setState(() {
                            _interp = v;
                          }),
                          onResizeTap: _onResizeTap,
                        ),
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
    String trimDot(String s) {
      final String t = s.trim();
      return t.endsWith('.') ? t.substring(0, t.length - 1) : t;
    }

    final String wText = trimDot(_inputValueController.text);
    final String hText = trimDot(_inputValueController2.text);
    final double? wVal = double.tryParse(wText);
    final double? hVal = double.tryParse(hText);
    // Resolve image id and DPI
    final int? imgId = ref.read(imageIdStableProvider(_currentProjectId!));
    if (imgId == null) return;
    final int dpi = (await ref.read(imageDpiProvider(imgId).future)) ?? 96;
    final String wUnit = _imgCtrl?.widthVC.unit ?? 'px';
    final String hUnit = _imgCtrl?.heightVC.unit ?? 'px';
    final service = ref.read(imageDetailServiceProvider);
    // Load current physical float dims (single source of truth for size)
    final (double?, double?) phys =
        await ref.read(imagePhysPixelsProvider(imgId).future);
    final double curPhysW = phys.$1 ?? 0.0;
    final double curPhysH = phys.$2 ?? 0.0;
    // Compute target physical floats via service
    final (double targetPhysW, double targetPhysH) = service.computeTargetPhys(
      typedW: wVal,
      wUnit: wUnit,
      typedH: hVal,
      hUnit: hUnit,
      dpi: dpi,
      curPhysW: curPhysW,
      curPhysH: curPhysH,
      linked: _linkWH,
    );
    if (targetPhysW <= 0 || targetPhysH <= 0) return;
    // Persist phys floats regardless of raster no-op
    await service.persistPhys(ref, imgId, targetPhysW, targetPhysH);
    // Compute raster targets by rounding phys floats
    final (int targetW, int targetH) =
        service.rasterFromPhys(targetPhysW, targetPhysH);
    // Always perform raster resize (no no-op skip)
    // Perform resize directly via project logic
    try {
      await service.performResize(ref,
          projectId: _currentProjectId!,
          targetW: targetW,
          targetH: targetH,
          interpolationName: kInterpolationToCvName[_interp] ?? 'linear');
    } catch (e, st) {
      debugPrint('[ImageDetail] Resize failed: $e');
      debugPrint(st.toString());
      return;
    }
    // Refresh controllers from physical floats (maintain logical source)
    if (mounted) {
      _imgCtrl?.applyRemotePx(widthPx: targetPhysW, heightPx: targetPhysH);
    }
  }

  Future<void> _handleImageBytes(Uint8List bytes) async {
    if (_currentProjectId == null) return;
    assert(() {
      debugPrint(
          '[ImageDetail] _handleImageBytes len=${bytes.length} pid=$_currentProjectId');
      return true;
    }());
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
            mimeType: Value(mime),
          ),
        );
    // Persist DPI (schema v22+): write both orig_dpi and dpi
    final int resolvedDpi =
        (decodedDpi != null && decodedDpi > 0) ? decodedDpi : 96;
    await imagesDao.customStatement(
      'UPDATE images SET orig_dpi = ?, dpi = ? WHERE id = ?',
      [resolvedDpi, resolvedDpi, imageId],
    );
    // Point project to this image via ProjectService (batched writes)
    final projectService = ref.read(projectServiceProvider);
    await projectService.batchUpdate(
      ref,
      _currentProjectId!,
      imageId: imageId,
    );
    // Do not modify project canvas from Image upload path (strict decoupling)
    debugPrint('[ImageDetail] image stored id=$imageId; updating controllers');
    // Seed physical pixel floats from original dimensions
    await imagesDao.customStatement(
      'UPDATE images SET phys_width_px4 = ?, phys_height_px4 = ? WHERE id = ?',
      [width?.toDouble(), height?.toDouble(), imageId],
    );
    // Update controllers from physical floats
    _imgCtrl?.applyRemotePx(
        widthPx: width?.toDouble(), heightPx: height?.toDouble());
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
        ? ref.watch(
            imageBytesProvider(imageId).select((a) => a.asData?.value),
          )
        : null;

    assert(() {
      debugPrint(
          '[ImageDetail] build pid=$pid imageId=$imageId bytes=${bytes?.length ?? 0}');
      return true;
    }());

    final bool showUpload = (imageId == null);

    if (imageId != null &&
        (_inputValueController.text.isEmpty ||
            _inputValueController2.text.isEmpty) &&
        _requestedDimsForImageId != imageId) {
      _requestedDimsForImageId = imageId;
      ref.read(imagePhysPixelsProvider(imageId).future).then((dims) {
        if (!mounted) return;
        _imgCtrl?.applyRemotePx(widthPx: dims.$1, heightPx: dims.$2);
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
              CustomPaint(painter: HairlineCanvasBorderPainter()),
            ],
          ),
        ),
      );
    }
    final Size canvasPx = ref.watch(
          canvasPreviewPxProvider(pid).select((a) => a.asData?.value),
        ) ??
        const Size(100.0, 100.0);
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
              CustomPaint(painter: HairlineCanvasBorderPainter()),
            ],
          ),
        ),
      );
    }

    final double canvasW = canvasPx.width;
    final double canvasH = canvasPx.height;
    final dims = (imageId != null)
        ? ref.watch(
            imageDimensionsProvider(imageId).select((a) => a.asData?.value),
          )
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

    // no local pad; styles handled in child widgets
    return ColoredBox(
      color: kGrey70,
      child: ImagePreview(
        controller: _ivController,
        boardW: boardW,
        boardH: boardH,
        canvasW: canvasW,
        canvasH: canvasH,
        bytes: bytes,
        viewportKey: _viewportKey,
      ),
    );
  }
}

// _loadImageDimensions removed; dimensions are provided exclusively by imageDimensionsProvider
