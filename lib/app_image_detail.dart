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
import 'package:vettore/data/database.dart';
import 'dart:async';
import 'package:vettore/widgets/input_value_type/width_row.dart';
import 'package:vettore/widgets/input_value_type/height_row.dart';
import 'package:vettore/services/dimensions_guard.dart';
import 'package:vettore/widgets/input_value_type/interpolation_selector.dart';
import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:file_picker/file_picker.dart';
import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/widgets/input_value_type/interpolation_map.dart';
import 'package:vettore/providers/navigation_providers.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vettore/providers/canvas_providers.dart';
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
  // Units and DPI state for resize wiring
  String _widthUnit = 'px';
  String _heightUnit = 'px';
  int _dpi = 96;
  // Original dimensions no longer tracked here; DimensionsRow manages aspect
  // Guard to avoid re-initializing dimensions on stream rebuilds
  int? _lastDimsImageId;
  bool _dimsInitialized = false;
  Uint8List? _lastImageBytes;
  // Removed: canvas/image-layer state; PhotoView handles navigation
  late final PhotoViewController _pvController;
  late final PhotoViewScaleStateController _pvScaleController;

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
    _pvController = PhotoViewController();
    _pvScaleController = PhotoViewScaleStateController();
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
        ? ref.watch(projectByIdProvider(_currentProjectId!)
            .select((p) => p.asData?.value?.imageId))
        : null;
    if (_currentProjectId != null) {
      ref.listen(projectByIdProvider(_currentProjectId!), (prev, next) {
        final int? nextImageId = next.asData?.value?.imageId;
        if (_lastDimsImageId != nextImageId) {
          _lastDimsImageId = nextImageId;
          _dimsInitialized = false;
        }
        if (nextImageId == null) {
          if (_inputValueController.text.isNotEmpty) {
            _inputValueController.text = '';
          }
          if (_inputValueController2.text.isNotEmpty) {
            _inputValueController2.text = '';
          }
        }
      });
    }
    if (_imageIdForListen != null) {
      ref.listen(imageDimensionsProvider(_imageIdForListen), (prev, next) {
        final dims = next.asData?.value;
        if (dims != null) {
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
                                  projectByIdProvider(_currentProjectId!)
                                      .select((p) => p.asData?.value?.imageId))
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
                              ),
                              HeightRow(
                                heightController: _inputValueController2,
                                enabled: hasImage,
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
                              // DPI selector removed: DPI is configured only on Project Detail (Canvas)
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
    int toPx(num v, String unit) {
      switch (unit) {
        case 'px':
          return v.round();
        case 'in':
          return (v * _dpi).round();
        case 'cm':
          return (v * (_dpi / 2.54)).round();
        case 'mm':
          return (v * (_dpi / 25.4)).round();
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
  }

  Future<void> _handleImageBytes(Uint8List bytes) async {
    if (_currentProjectId == null) return;
    debugPrint(
        '[ImageDetail] _handleImageBytes len=${bytes.length} pid=$_currentProjectId');
    // Decode to get dimensions in isolate
    final dims = await compute(ic.decodeDimensions, bytes);
    // Best effort DPI detection (to be wired to ResolutionSelector)
    // final int? dpi = await compute(ic.decodeDpi, bytes);
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
    debugPrint('[ImageDetail] image stored id=$imageId; updating controllers');
    // Update local UI controllers with dimensions
    _applyImageDims(width: width, height: height);
    // TODO: if DPI is detected, set ResolutionSelector initial value
    // This requires threading dpi into local state; for now, ignore if null
    _setHasImage(true);
  }

  // Dialog upload handled inside ImageUploadArea
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
        if (p.imageId != null) {
          await _loadImageDimensions(p.imageId!);
        } else {
          _inputValueController.text = '';
          _inputValueController2.text = '';
        }
        _subscribeToProject(_currentProjectId!);
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        if (p.imageId != null) {
          await _loadImageDimensions(p.imageId!);
        } else {
          _inputValueController.text = '';
          _inputValueController2.text = '';
        }
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
        _inputValueController.text = '';
        _inputValueController2.text = '';
        _setHasImage(false);
        return;
      }
      final nextHasImage = p.imageId != null;
      if (p.imageId != null) {
        _loadImageDimensions(p.imageId!);
      } else {
        _inputValueController.text = '';
        _inputValueController2.text = '';
      }
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

    // Always render canvas artboard; only show upload prompt when no imageId
    if (imageId == null) {
      return Center(
        child: ImageUploadText(
          onImageDropped: (b) => _handleImageBytes(b),
          onUploadTap: _pickViaDialog,
        ),
      );
    }

    // Canvas artboard + image, PhotoView handles pan/zoom; border scales
    final spec = ref.watch(canvasSpecProvider);
    final double canvasW = (spec.widthPx > 0) ? spec.widthPx : 100.0;
    final double canvasH = (spec.heightPx > 0) ? spec.heightPx : 100.0;
    return Center(
      child: Stack(
        children: [
          PhotoView.customChild(
            controller: _pvController,
            scaleStateController: _pvScaleController,
            backgroundDecoration: const BoxDecoration(color: kGrey10),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4.0,
            childSize: Size(canvasW, canvasH),
            child: Center(
              child: SizedBox(
                width: canvasW,
                height: canvasH,
                child: ClipRect(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(color: kWhite),
                      ),
                      if (bytes != null)
                        Center(
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.none,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.fromBorderSide(
                            BorderSide(color: kGrey100, width: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    final s = _pvController.scale ?? 1.0;
                    _pvController.scale = s + 0.25;
                  },
                  onZoomOut: () {
                    final s = _pvController.scale ?? 1.0;
                    _pvController.scale = (s - 0.25).clamp(0.25, 50.0);
                  },
                  onFitToScreen: () {
                    _pvScaleController.scaleState = PhotoViewScaleState.initial;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension _ImageDimensions on _AppImageDetailPageState {
  Future<void> _loadImageDimensions(int imageId) async {
    final db = ref.read(appDatabaseProvider);
    try {
      final row = await (db.select(db.images)
            ..where((t) => t.id.equals(imageId)))
          .getSingleOrNull();
      final int? width = row?.origWidth;
      final int? height = row?.origHeight;
      _applyImageDims(width: width, height: height);
    } catch (_) {
      // ignore read errors
    }
  }
}
