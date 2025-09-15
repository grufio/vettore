import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/section_input.dart';
import 'package:vettore/widgets/button_app.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
// import 'package:vettore/widgets/image_upload_area.dart';
import 'package:vettore/widgets/input_value_type/text_default.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/data/database.dart';
import 'dart:async';
import 'package:vettore/widgets/input_value_type/width_row.dart';
import 'package:vettore/widgets/input_value_type/height_row.dart';
// import 'package:vettore/services/dimensions_guard.dart';
// import 'package:flutter/foundation.dart' show compute;
// import 'package:vettore/services/image_compute.dart' as ic;

import 'package:vettore/providers/navigation_providers.dart';
// import removed: DPI control moved to Image Detail
import 'package:vettore/providers/canvas_providers.dart';

class AppProjectDetailPage extends ConsumerStatefulWidget {
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  final int? projectId; // optional for now; when null we load/create first
  final ValueChanged<String>? onProjectTitleSaved;
  final ValueChanged<int>? onDeleteProject;
  const AppProjectDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
    this.projectId,
    this.onProjectTitleSaved,
    this.onDeleteProject,
  });

  @override
  ConsumerState<AppProjectDetailPage> createState() =>
      _AppProjectDetailPageState();
}

class _AppProjectDetailPageState extends ConsumerState<AppProjectDetailPage> {
  // Header handled by shell; these are no longer needed
  String _detailFilterId = 'project';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _singleInputController;
  late final TextEditingController _projectController;
  // No interpolation in canvas page
  int? _currentProjectId;
  double _rightPanelWidth = 320.0;
  bool _hasImage = false;
  late final FocusNode _projectTitleFocusNode;
  StreamSubscription<DbProject?>? _projectSub;
  // Link/unlink width/height
  bool _linkWH = false;
  // Canvas uses px only; no units or DPI
  // Canvas preview (pixels), updated on "Update Canvas"
  double? _canvasPxW;
  double? _canvasPxH;
  // Original dimensions no longer tracked here; DimensionsRow manages aspect
  // Guard to avoid re-initializing dimensions on stream rebuilds
  // Removed: last image id tracking; canvas decoupled
  // Canvas no longer auto-initializes from image

  void _setHasImage(bool value) {
    if (!mounted) return;
    setState(() => _hasImage = value);
  }

  void _recomputeCanvasFromInputs() {
    double? parseValue(String s) => double.tryParse(s.trim());
    final double? w = parseValue(_inputValueController.text);
    final double? h = parseValue(_inputValueController2.text);
    if (w == null || h == null || w <= 0 || h <= 0) {
      setState(() {
        _canvasPxW = null;
        _canvasPxH = null;
      });
      return;
    }
    // Canvas strictly uses px values from fields
    final double pxW = w.clamp(1.0, 20000.0);
    final double pxH = h.clamp(1.0, 20000.0);
    setState(() {
      _canvasPxW = pxW;
      _canvasPxH = pxH;
    });
  }

  // No image-dimension application in Project Detail; canvas is independent

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    _singleInputController = TextEditingController();
    _projectController = TextEditingController();
    // Default Canvas: 100 x 100 @ 72dpi
    _inputValueController.text = '100';
    _inputValueController2.text = '100';
    // Default interpolation shown in the field
    _singleInputController.text = '';
    _projectTitleFocusNode = FocusNode();
    _projectTitleFocusNode.addListener(() {
      if (!_projectTitleFocusNode.hasFocus) {
        _saveProjectTitle();
      }
    });
    // Initialize canvas preview to the default 100×100 @ 72 dpi
    _recomputeCanvasFromInputs();
    // Seed global canvas spec with default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_canvasPxW != null && _canvasPxH != null) {
        ref
            .read(canvasSpecProvider.notifier)
            .setSpec(CanvasSpec(widthPx: _canvasPxW!, heightPx: _canvasPxH!));
      }
    });
    _initProject();
    // Canvas preview updates only when tapping "Update Canvas"
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
    // No image dimension listening for Canvas size
    // Clear canvas fields if project loses image
    // Do not clear canvas fields when project has no image; keep default canvas
    // Canvas fields should not auto-fill from image dimensions
    // (no-op)

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
              activeId: _detailFilterId,
              onChanged: (id) {
                setState(() => _detailFilterId = id);
                if (id == 'image') {
                  ref.read(currentPageProvider.notifier).state = PageId.image;
                } else if (id == 'project') {
                  ref.read(currentPageProvider.notifier).state = PageId.project;
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
                        SectionSidebar(
                          title: 'Projekt',
                          children: [
                            TextDefaultInput(
                              controller: _projectController,
                              focusNode: _projectTitleFocusNode,
                              placeholder: null,
                              suffixText: null,
                              onActionTap: null,
                              onSubmitted: (_) => _saveProjectTitle(),
                            ),
                          ],
                        ),
                        // Model section removed as requested
                        Builder(builder: (context) {
                          // imageId not used for canvas; keep watch minimal
                          return SectionSidebar(
                            title: 'Dimensions',
                            children: [
                              WidthRow(
                                widthController: _inputValueController,
                                heightController: _inputValueController2,
                                enabled: true,
                                initialLinked: _linkWH,
                                onLinkChanged: (v) => setState(() {
                                  _linkWH = v;
                                }),
                                units: const ['px'],
                              ),
                              HeightRow(
                                heightController: _inputValueController2,
                                enabled: true,
                                units: const ['px'],
                              ),
                              SectionInput(
                                full: OutlinedActionButton(
                                  label: 'Update Canvas',
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

extension on _AppProjectDetailPageState {
  void _onResizeTap() async {
    if (_currentProjectId == null) return;
    final int? wVal = int.tryParse(_inputValueController.text.trim());
    final int? hVal = int.tryParse(_inputValueController2.text.trim());
    if (wVal == null || hVal == null) return;
    // Update Canvas preview now
    _recomputeCanvasFromInputs();
    if (_canvasPxW != null && _canvasPxH != null) {
      ref
          .read(canvasSpecProvider.notifier)
          .setSpec(CanvasSpec(widthPx: _canvasPxW!, heightPx: _canvasPxH!));
    }
    // Canvas values are entered in px
    final int targetW = wVal;
    final int targetH = hVal;
    // Persist canvas spec to DB (pixels + dpi)
    try {
      final db = ref.read(appDatabaseProvider);
      await db.customStatement(
          'UPDATE projects SET canvas_width_px=$targetW, canvas_height_px=$targetH WHERE id=${_currentProjectId!}');
    } catch (_) {
      // ignore persistence errors in UI
    }
    // Do not resize image here; canvas is independent
  }

  // _handleImageBytes removed; upload handled on Image Detail page

  // Dialog upload handled inside ImageUploadArea

  Future<void> _initProject() async {
    // Determine project to load: prefer explicit id, else load first project if any
    final repo = ref.read(projectRepositoryProvider);
    try {
      if (widget.projectId != null) {
        _currentProjectId = widget.projectId;
        final p = await repo.getById(widget.projectId!);
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        // Load saved canvas spec if present
        try {
          final db = ref.read(appDatabaseProvider);
          final row = await db
              .customSelect(
                  'SELECT canvas_width_px, canvas_height_px FROM projects WHERE id = ${_currentProjectId!} LIMIT 1')
              .getSingleOrNull();
          if (row != null) {
            final int? cw = row.data['canvas_width_px'] as int?;
            final int? ch = row.data['canvas_height_px'] as int?;
            if (cw != null && ch != null && cw > 0 && ch > 0) {
              _inputValueController.text = cw.toString();
              _inputValueController2.text = ch.toString();
              _recomputeCanvasFromInputs();
              ref.read(canvasSpecProvider.notifier).setSpec(
                  CanvasSpec(widthPx: cw.toDouble(), heightPx: ch.toDouble()));
            }
          }
        } catch (_) {}
        // Model/Type initialization removed
        // Do not read image dimensions here; canvas is independent
        _subscribeToProject(_currentProjectId!);
        if (mounted) setState(() {});
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        // Load saved canvas spec if present
        try {
          final db = ref.read(appDatabaseProvider);
          final row = await db
              .customSelect(
                  'SELECT canvas_width_px, canvas_height_px FROM projects WHERE id = ${_currentProjectId!} LIMIT 1')
              .getSingleOrNull();
          if (row != null) {
            final int? cw = row.data['canvas_width_px'] as int?;
            final int? ch = row.data['canvas_height_px'] as int?;
            if (cw != null && ch != null && cw > 0 && ch > 0) {
              _inputValueController.text = cw.toString();
              _inputValueController2.text = ch.toString();
              _recomputeCanvasFromInputs();
              ref.read(canvasSpecProvider.notifier).setSpec(
                  CanvasSpec(widthPx: cw.toDouble(), heightPx: ch.toDouble()));
            }
          }
        } catch (_) {}
        // Model/Type initialization removed
        // Do not read image dimensions here; canvas is independent
        _subscribeToProject(_currentProjectId!);
        if (mounted) setState(() {});
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
      if (p.imageId != null) {
        // Do not read image dimensions here; canvas is independent
      }
      if (nextHasImage != _hasImage) _setHasImage(nextHasImage);
    });
  }

  Widget _buildDetailBody() {
    // Live Canvas preview: fit computed pixel size into a max box
    const double maxPreviewW = 480.0;
    const double maxPreviewH = 360.0;
    final double? pxW = _canvasPxW;
    final double? pxH = _canvasPxH;
    if (pxW == null || pxH == null || pxW <= 0 || pxH <= 0) {
      // Show default canvas preview when not computed yet: 100×100 @ 72 dpi
      const double defW = 100.0;
      const double defH = 100.0;
      final double scale = (maxPreviewW / defW)
          .clamp(0.0, double.infinity)
          .clamp(0.0, (maxPreviewH / defH));
      final double previewW = (defW * scale).clamp(1.0, maxPreviewW);
      final double previewH = (defH * scale).clamp(1.0, maxPreviewH);
      return ColoredBox(
        color: kGrey10,
        child: Center(
          child: SizedBox(
            width: previewW,
            height: previewH,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: kWhite,
                border: Border.fromBorderSide(
                    BorderSide(color: kBordersColor, width: 1.0)),
              ),
            ),
          ),
        ),
      );
    }
    final double scale = (pxW > 0 && pxH > 0)
        ? (maxPreviewW / pxW)
            .clamp(0.0, double.infinity)
            .clamp(0.0, (maxPreviewH / pxH))
        : 1.0;
    final double previewW = (pxW * scale).clamp(1.0, maxPreviewW);
    final double previewH = (pxH * scale).clamp(1.0, maxPreviewH);
    return ColoredBox(
      color: kGrey10,
      child: Center(
        child: SizedBox(
          width: previewW,
          height: previewH,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: kWhite,
              border: Border.fromBorderSide(
                  BorderSide(color: kBordersColor, width: 1.0)),
            ),
          ),
        ),
      ),
    );
  }
}

// Intentionally no image-dimension helpers in Project Detail; canvas is independent
