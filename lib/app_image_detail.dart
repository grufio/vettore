import 'dart:async';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
// dimensions_guard not used here any more
import 'package:flutter/foundation.dart'
    show compute, debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/providers/application_providers.dart';
// Replaced specific rows with unified DimensionRow (now used inside panel)
import 'package:vettore/providers/canvas_preview_provider.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/navigation_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/image_actions.dart';
import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/services/image_detail_controller.dart';
// import 'package:vettore/services/image_detail_service.dart';
import 'package:vettore/services/image_upload_service.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/artboard_view.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/image_detail/image_detail_header_bar.dart';
import 'package:vettore/widgets/image_detail/image_detail_right_panel.dart';
// Dimension panel now wrapped by ImageDimensionsSection
import 'package:vettore/widgets/image_dimensions_section.dart';
// removed unused image_resize_service import after inlining px computation
import 'package:vettore/widgets/image_listeners.dart';
// PhotoView removed in favor of InteractiveViewer for infinite pasteboard

import 'package:vettore/widgets/image_preview.dart';
import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/widgets/input_value_type/dimension_compare_utils.dart';
import 'package:vettore/widgets/input_value_type/interpolation_map.dart';
// side_panel moved into ImageDetailRightPanel

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
  // int? _lastImageId; // not used
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

    // Trigger provider resolution (unused local)
    ref.watch(imageIdStableProvider(_currentProjectId ?? -1));

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
          if (_currentProjectId != null && _imgCtrl != null)
            ImageListeners(
              projectId: _currentProjectId!,
              controller: _imgCtrl!,
            ),
          // Header handled by shared shell; keep content only when embedded
          // Detail filter bar with bottom border
          ImageDetailHeaderBar(
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
                  ImageDetailRightPanel(
                    width: _rightPanelWidth,
                    onResize: (delta) {
                      setState(() {
                        _rightPanelWidth =
                            (_rightPanelWidth + delta).clamp(200.0, 400.0);
                      });
                    },
                    onReset: () {
                      setState(() {
                        _rightPanelWidth = 320.0;
                      });
                    },
                    child: ImageDetailDimensions(
                      projectId: _currentProjectId!,
                      widthController: _inputValueController,
                      heightController: _inputValueController2,
                      controller: _imgCtrl!,
                      linkWH: _linkWH,
                      onLinkChanged: (v) => setState(() => _linkWH = v),
                      interpolation: _interp,
                      onInterpolationChanged: (v) => setState(() {
                        _interp = v;
                      }),
                      onResizeTap: () async {
                        if (_currentProjectId == null) return;
                        final String wText =
                            trimTrailingDot(_inputValueController.text);
                        final String hText =
                            trimTrailingDot(_inputValueController2.text);
                        final double? wVal = double.tryParse(wText);
                        final double? hVal = double.tryParse(hText);
                        final int? imgId =
                            ref.read(imageIdStableProvider(_currentProjectId!));
                        if (imgId == null) return;
                        final int dpi =
                            (await ref.read(imageDpiProvider(imgId).future)) ??
                                96;
                        final String wUnit = _imgCtrl?.widthVC.unit ?? 'px';
                        final String hUnit = _imgCtrl?.heightVC.unit ?? 'px';
                        final (double?, double?) phys = await ref
                            .read(imagePhysPixelsProvider(imgId).future);
                        final double curPhysW = phys.$1 ?? 0.0;
                        final double curPhysH = phys.$2 ?? 0.0;
                        await ref.read(imageActionsProvider).resizeCommit(
                          ref,
                          projectId: _currentProjectId!,
                          imageId: imgId,
                          interpName:
                              kInterpolationToCvName[_interp] ?? 'linear',
                          curPhysW: curPhysW,
                          curPhysH: curPhysH,
                          typedW: wVal,
                          wUnit: wUnit,
                          typedH: hVal,
                          hUnit: hUnit,
                          dpi: dpi,
                          onPhysCommitted: (wPx, hPx) {
                            if (mounted) {
                              _imgCtrl?.applyRemotePx(
                                  widthPx: wPx, heightPx: hPx);
                            }
                          },
                        );
                      },
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
    // Invalidate phys-pixels provider so any listeners refresh
    ref.invalidate(imagePhysPixelsProvider(imageId));
    // Update controllers from physical floats
    _imgCtrl?.applyRemotePx(
        widthPx: width?.toDouble(), heightPx: height?.toDouble());
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
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
      }
    } catch (_) {
      // Ignore load errors for now; keep empty controller
    }
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
    // Derive preview size from image bytes or fallback to canvas size
    final double imgW = canvasW;
    final double imgH = canvasH;
    final double maxContentW = imgW > canvasW ? imgW : canvasW;
    final double maxContentH = imgH > canvasH ? imgH : canvasH;
    final double margin = (0.1 * (maxContentW)).clamp(120.0, 480.0);
    final double boardW = maxContentW + margin;
    final double boardH = maxContentH + margin;

    if (showUpload) {
      return Center(
        child: ImageUploadText(
          onImageDropped: (b) async {
            final r = await ref
                .read(imageUploadServiceProvider)
                .insertImageAndMetadata(ref, b);
            await ref.read(projectServiceProvider).batchUpdate(
                  ref,
                  _currentProjectId!,
                  imageId: r.imageId,
                );
            _imgCtrl?.applyRemotePx(
                widthPx: r.width?.toDouble(), heightPx: r.height?.toDouble());
          },
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
