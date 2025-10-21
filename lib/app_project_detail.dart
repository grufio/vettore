// Platform check should be web-safe; avoid dart:io on web

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'package:drift/drift.dart' show Variable;
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/button_app.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
// import 'package:vettore/widgets/image_upload_area.dart';
import 'package:vettore/widgets/input_value_type/text_default.dart';
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/data/database.dart';
import 'dart:async';
import 'package:vettore/widgets/input_value_type/dimension_row.dart';
import 'package:vettore/widgets/input_value_type/unit_value_controller.dart';
import 'package:vettore/widgets/constants/input_constants.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';
// import 'package:vettore/services/dimensions_guard.dart';
// import 'package:flutter/foundation.dart' show compute;
// import 'package:vettore/services/image_compute.dart' as ic;

import 'package:vettore/providers/navigation_providers.dart';
// import removed: DPI control moved to Image Detail
import 'package:vettore/providers/canvas_providers.dart';

class AppProjectDetailPage extends ConsumerStatefulWidget {
  const AppProjectDetailPage({
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
  ConsumerState<AppProjectDetailPage> createState() =>
      _AppProjectDetailPageState();
}

class _AppProjectDetailPageState extends ConsumerState<AppProjectDetailPage>
    with AutomaticKeepAliveClientMixin {
  static const int kCanvasPreviewPpi = 96;
  // Header handled by shell; these are no longer needed
  String _detailFilterId = 'project';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _singleInputController;
  late final TextEditingController _projectController;
  Timer? _titleDebounceTimer;
  static const Duration _titleDebounceDelay = Duration(milliseconds: 400);
  Timer? _recomputeDebounceTimer;
  static const Duration _recomputeDebounceDelay = Duration(milliseconds: 60);
  late final VoidCallback _dimsListener;
  // No interpolation in canvas page
  int? _currentProjectId;
  double _rightPanelWidth = 320.0;
  String _lastSavedTitle = '';
  late final FocusNode _projectTitleFocusNode;
  StreamSubscription<DbProject?>? _projectSub;
  // Scoped rebuild: notify preview only when px size changes
  final ValueNotifier<Size?> _canvasPxNotifier = ValueNotifier<Size?>(null);
  // Link/unlink width/height
  bool _linkWH = false;
  // Canvas uses px only; no units or DPI
  // Canvas preview (pixels), updated on "Update Canvas"
  double? _canvasPxW;
  double? _canvasPxH;
  String _canvasWUnit = 'mm';
  String _canvasHUnit = 'mm';
  // Enum-typed units (authoritative for logic/DB)
  Unit _canvasWUnitE = Unit.millimeter;
  Unit _canvasHUnitE = Unit.millimeter;
  // Persisted spec (value + unit) to detect dirty state
  double? _persistWVal;
  double? _persistHVal;
  Unit _persistWUnitE = Unit.millimeter;
  Unit _persistHUnitE = Unit.millimeter;
  // Removed entrance animation; fixed padding used
  // Grid controls (cell size)
  late final TextEditingController _gridWController;
  late final TextEditingController _gridHController;
  String _gridWUnit = 'mm';
  String _gridHUnit = 'mm';
  Unit _gridWUnitE = Unit.millimeter;
  Unit _gridHUnitE = Unit.millimeter;
  double? _gridCellPxW;
  double? _gridCellPxH;
  bool _showGrid = true;
  // Unified unit-value controllers for width/height
  UnitValueController? _widthVC;
  UnitValueController? _heightVC;
  @override
  bool get wantKeepAlive => true;
  // Safely call setState from helpers/extensions
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  // Original dimensions no longer tracked here; DimensionsRow manages aspect
  // Guard to avoid re-initializing dimensions on stream rebuilds
  // Removed: last image id tracking; canvas decoupled
  // Canvas no longer auto-initializes from image

  // _hasImage and visual usage removed; Project Detail is canvas-only

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
    // Convert according to selected units for preview (consistent with onResizeTap)
    final double pxW = convertUnitTyped(
            value: w,
            from: _canvasWUnitE,
            to: Unit.px,
            dpi: _AppProjectDetailPageState.kCanvasPreviewPpi)
        .clamp(1.0, 20000.0);
    final double pxH = convertUnitTyped(
            value: h,
            from: _canvasHUnitE,
            to: Unit.px,
            dpi: _AppProjectDetailPageState.kCanvasPreviewPpi)
        .clamp(1.0, 20000.0);

    _canvasPxW = pxW;
    _canvasPxH = pxH;
    _canvasPxNotifier.value = Size(pxW, pxH);
    // Sync value controllers in px and units
    _widthVC?.setDpi(kCanvasPreviewPpi);
    _heightVC?.setDpi(kCanvasPreviewPpi);
    _widthVC?.setUnit(_canvasWUnit);
    _heightVC?.setUnit(_canvasHUnit);
    _widthVC?.setValuePx(pxW);
    _heightVC?.setValuePx(pxH);
  }

  void _recomputeGridFromInputs() {
    double? parseValue(String s) => double.tryParse(s.trim());
    final double? gw = parseValue(_gridWController.text);
    final double? gh = parseValue(_gridHController.text);
    if (gw == null || gw <= 0 || gh == null || gh <= 0) {
      _gridCellPxW = null;
      _gridCellPxH = null;
      return;
    }
    _gridCellPxW = convertUnitTyped(
        value: gw, from: _gridWUnitE, to: Unit.px, dpi: kCanvasPreviewPpi);
    _gridCellPxH = convertUnitTyped(
        value: gh, from: _gridHUnitE, to: Unit.px, dpi: kCanvasPreviewPpi);
  }

  // No image-dimension application in Project Detail; canvas is independent

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    // Initialize UnitValueControllers with default units and preview dpi
    _widthVC = UnitValueController(unit: _canvasWUnit);
    _heightVC = UnitValueController(unit: _canvasHUnit);
    // Do not link by default; linking should be enabled explicitly via UI
    _singleInputController = TextEditingController();
    _projectController = TextEditingController();
    _gridWController = TextEditingController(text: '');
    _gridHController = TextEditingController(text: '');
    // Default Canvas: 100 x 100 @ 72dpi
    _inputValueController.text = '100';
    _inputValueController2.text = '100';
    // Initialize persisted spec defaults (until DB load)
    _persistWVal = 100;
    _persistHVal = 100;
    _persistWUnitE = _canvasWUnitE;
    _persistHUnitE = _canvasHUnitE;
    // Default interpolation shown in the field
    _singleInputController.text = '';
    _projectTitleFocusNode = FocusNode();
    _projectTitleFocusNode.addListener(() {
      if (!_projectTitleFocusNode.hasFocus) {
        _saveProjectTitle();
      }
    });
    _projectController.addListener(_onTitleChangedDebounced);
    // Recompute only grid preview on input change; canvas updates on button tap
    _dimsListener = () {
      _recomputeDebounceTimer?.cancel();
      _recomputeDebounceTimer = Timer(_recomputeDebounceDelay, () {
        _recomputeGridFromInputs();
        // No full setState here; preview listens via _canvasPxNotifier
      });
    };
    _inputValueController.addListener(_dimsListener);
    _inputValueController2.addListener(_dimsListener);
    _gridWController.addListener(_dimsListener);
    _gridHController.addListener(_dimsListener);
    // Initialize canvas preview to the default 100×100 @ 72 dpi
    _recomputeCanvasFromInputs();
    // Seed global canvas spec with default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_canvasPxW != null && _canvasPxH != null) {
        final current = ref.read(canvasSpecProvider);
        final spec = CanvasSpec(widthPx: _canvasPxW!, heightPx: _canvasPxH!);
        if (current.widthPx != spec.widthPx ||
            current.heightPx != spec.heightPx) {
          ref.read(canvasSpecProvider.notifier).setSpec(spec);
        }
      }
    });
    _initProject();
    // Canvas preview updates only when tapping "Update Canvas"
  }

  @override
  void dispose() {
    _inputValueController.removeListener(_dimsListener);
    _inputValueController2.removeListener(_dimsListener);
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _singleInputController.dispose();
    _projectController.dispose();
    _gridWController.removeListener(_dimsListener);
    _gridHController.removeListener(_dimsListener);
    _gridWController.dispose();
    _gridHController.dispose();

    _titleDebounceTimer?.cancel();
    _recomputeDebounceTimer?.cancel();
    _projectTitleFocusNode.dispose();
    _projectSub?.cancel();
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
    final projectIdFromProvider =
        ref.watch(currentProjectIdProvider.select((id) => id));
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
              activeId: _detailFilterId,
              onChanged: (id) {
                setState(() => _detailFilterId = id);
                if (id == 'image') {
                  ref.read(currentPageProvider.notifier).state = PageId.image;
                } else if (id == 'project') {
                  ref.read(currentPageProvider.notifier).state = PageId.project;
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
                        _buildProjectTitleSection(),
                        _buildDimensionsSection(),
                        _buildGridSection(),
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

extension _Sections on _AppProjectDetailPageState {
  Widget _buildProjectTitleSection() {
    return SectionSidebar(
      title: 'Projekt',
      children: [
        TextDefaultInput(
          controller: _projectController,
          focusNode: _projectTitleFocusNode,
          onSubmitted: (_) => _saveProjectTitle(),
        ),
      ],
    );
  }

  Widget _buildDimensionsSection() {
    return SectionSidebar(
      title: 'Dimensions',
      children: [
        DimensionRow(
          primaryController: _inputValueController,
          partnerController: _inputValueController2,
          valueController: _widthVC,
          enabled: true,
          isWidth: true,
          showLinkToggle: true,
          initialLinked: _linkWH,
          onLinkChanged: (v) => _safeSetState(() {
            _linkWH = v;
          }),
          dpiOverride: _AppProjectDetailPageState.kCanvasPreviewPpi,
          units: kUnits,
          initialUnit: _canvasWUnit,
          onUnitChanged: (u) {
            _safeSetState(() {
              _canvasWUnit = u;
              _canvasWUnitE = parseUnit(u);
            });
            _recomputeCanvasFromInputs();
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
          ],
          clampPxMin: 1.0,
          clampPxMax: 20000.0,
          clampDpi: _AppProjectDetailPageState.kCanvasPreviewPpi,
        ),
        DimensionRow(
          primaryController: _inputValueController2,
          partnerController: _inputValueController,
          valueController: _heightVC,
          enabled: true,
          isWidth: false,
          units: kUnits,
          initialUnit: _canvasHUnit,
          onUnitChanged: (u) {
            _safeSetState(() {
              _canvasHUnit = u;
              _canvasHUnitE = parseUnit(u);
            });
            _recomputeCanvasFromInputs();
          },
          dpiOverride: _AppProjectDetailPageState.kCanvasPreviewPpi,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
          ],
          clampPxMin: 1.0,
          clampPxMax: 20000.0,
          clampDpi: _AppProjectDetailPageState.kCanvasPreviewPpi,
        ),
        SectionInput(
          full: AnimatedBuilder(
            animation: Listenable.merge([
              _inputValueController,
              _inputValueController2,
            ]),
            builder: (context, _) {
              final enabled = _isInputsDirty();
              return OutlinedActionButton(
                label: 'Update Canvas',
                onTap: _onUpdateCanvasTap,
                enabled: enabled,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridSection() {
    return SectionSidebar(
      title: 'Grid',
      showTitleToggle: true,
      titleToggleOn: _showGrid,
      onTitleToggle: (v) => _safeSetState(() => _showGrid = v),
      children: [
        SectionInput(
          full: InputValueType(
            key: const ValueKey('grid_cell_width'),
            controller: _gridWController,
            placeholder: 'Cell width',
            prefixIconAsset: 'assets/icons/16/width.svg',
            prefixIconFit: BoxFit.none,
            prefixIconAlignment: Alignment.centerLeft,
            dropdownItems: kUnits,
            selectedItem: _gridWUnit,
            suffixText: _gridWUnit,
            variant: InputVariant.selector,
            onChanged: (raw) {
              final sanitized = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
              if (sanitized != raw) {
                _gridWController.text = sanitized;
                _gridWController.selection =
                    TextSelection.collapsed(offset: sanitized.length);
              }
            },
            onItemSelected: (u) {
              _safeSetState(() {
                _gridWUnit = u;
                _gridWUnitE = parseUnit(u);
              });
              _recomputeGridFromInputs();
            },
          ),
        ),
        SectionInput(
          full: InputValueType(
            key: const ValueKey('grid_cell_height'),
            controller: _gridHController,
            placeholder: 'Cell height',
            prefixIconAsset: 'assets/icons/16/height.svg',
            prefixIconFit: BoxFit.none,
            prefixIconAlignment: Alignment.centerLeft,
            dropdownItems: kUnits,
            selectedItem: _gridHUnit,
            suffixText: _gridHUnit,
            variant: InputVariant.selector,
            onChanged: (raw) {
              final sanitized = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
              if (sanitized != raw) {
                _gridHController.text = sanitized;
                _gridHController.selection =
                    TextSelection.collapsed(offset: sanitized.length);
              }
            },
            onItemSelected: (u) {
              _safeSetState(() {
                _gridHUnit = u;
                _gridHUnitE = parseUnit(u);
              });
              _recomputeGridFromInputs();
            },
          ),
        ),
        SectionInput(
          full: AnimatedBuilder(
            animation: Listenable.merge([
              _gridWController,
              _gridHController,
            ]),
            builder: (context, _) {
              final gw = double.tryParse(_gridWController.text.trim());
              final gh = double.tryParse(_gridHController.text.trim());
              final bool e = (gw != null && gw > 0 && gh != null && gh > 0);
              return OutlinedActionButton(
                label: 'Update Grid',
                enabled: e,
                onTap: _onUpdateGridTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

extension on _AppProjectDetailPageState {
  Future<void> _onUpdateCanvasTap() async {
    final double? wVal = double.tryParse(_inputValueController.text.trim());
    final double? hVal = double.tryParse(_inputValueController2.text.trim());
    if (wVal == null || hVal == null || wVal <= 0 || hVal <= 0) return;
    // Convert to px and update preview/canvas spec
    final double wPx = convertUnitTyped(
        value: wVal,
        from: _canvasWUnitE,
        to: Unit.px,
        dpi: _AppProjectDetailPageState.kCanvasPreviewPpi);
    final double hPx = convertUnitTyped(
        value: hVal,
        from: _canvasHUnitE,
        to: Unit.px,
        dpi: _AppProjectDetailPageState.kCanvasPreviewPpi);
    _canvasPxW = wPx;
    _canvasPxH = hPx;
    _canvasPxNotifier.value = Size(wPx, hPx);
    // Sync controllers
    _widthVC?.setDpi(_AppProjectDetailPageState.kCanvasPreviewPpi);
    _heightVC?.setDpi(_AppProjectDetailPageState.kCanvasPreviewPpi);
    _widthVC?.setUnit(_canvasWUnit);
    _heightVC?.setUnit(_canvasHUnit);
    _widthVC?.setValuePx(wPx);
    _heightVC?.setValuePx(hPx);
    // Persist canvas value + unit to DB
    if (_currentProjectId != null) {
      try {
        final svc = ref.read(projectServiceProvider);
        await svc.updateCanvasSpec(
          ref,
          _currentProjectId!,
          widthValue: wVal,
          widthUnit: _canvasWUnit,
          heightValue: hVal,
          heightUnit: _canvasHUnit,
        );
        // Update persisted spec baselines so dirty check resets
        _persistWVal = wVal;
        _persistHVal = hVal;
        _persistWUnitE = _canvasWUnitE;
        _persistHUnitE = _canvasHUnitE;
      } catch (_) {
        // ignore persistence errors in UI
      }
    }
  }

  bool _isInputsDirty() {
    final double? wVal = double.tryParse(_inputValueController.text.trim());
    final double? hVal = double.tryParse(_inputValueController2.text.trim());
    if (wVal == null || hVal == null) return false;
    final bool unitChanged =
        (_canvasWUnitE != _persistWUnitE) || (_canvasHUnitE != _persistHUnitE);
    bool valueChanged = false;
    if (_persistWVal == null || _persistHVal == null) {
      valueChanged = true;
    } else {
      const double eps = 1e-9;
      valueChanged = (wVal - _persistWVal!).abs() > eps ||
          (hVal - _persistHVal!).abs() > eps;
    }
    return unitChanged || valueChanged;
  }

  // _onResizeTap removed; Update Canvas handled by _onUpdateCanvasTap

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
        // image presence not used on this page
        await _loadCanvasSpecFromDb(_currentProjectId!);
        // Model/Type initialization removed
        // Do not read image dimensions here; canvas is independent
        _subscribeToProject(_currentProjectId!);
        _safeSetState(() {});
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
        // image presence not used on this page
        await _loadCanvasSpecFromDb(_currentProjectId!);
        // Model/Type initialization removed
        // Do not read image dimensions here; canvas is independent
        _subscribeToProject(_currentProjectId!);
        _safeSetState(() {});
      }
    } catch (_) {
      // Ignore load errors for now; keep empty controller
    }
  }

  Future<void> _saveProjectTitle() async {
    if (_currentProjectId == null) return;
    final text = _projectController.text.trim();
    if (text == _lastSavedTitle) return;
    final svc = ref.read(projectServiceProvider);
    await svc.updateTitle(ref, _currentProjectId!, text);
    _lastSavedTitle = text;
    widget.onProjectTitleSaved?.call(text);
  }

  void _onTitleChangedDebounced() {
    final String text = _projectController.text.trim();
    // Skip scheduling if same as last saved and not focused to avoid churn
    if (text == _lastSavedTitle) {
      _titleDebounceTimer?.cancel();
      return;
    }
    _titleDebounceTimer?.cancel();
    _titleDebounceTimer =
        Timer(_AppProjectDetailPageState._titleDebounceDelay, () {
      if (!mounted) return;
      _saveProjectTitle();
    });
  }

  void _subscribeToProject(int projectId) {
    _projectSub?.cancel();
    _projectSub =
        ref.read(projectRepositoryProvider).watchById(projectId).listen((p) {
      if (!mounted) return;
      if (p == null) {
        return;
      }
      // If project canvas spec changed elsewhere, sync inputs and preview
      final double newWVal = p.canvasWidthValue;
      final double newHVal = p.canvasHeightValue;
      final String newWUnit = p.canvasWidthUnit;
      final String newHUnit = p.canvasHeightUnit;

      final bool specChanged = (_persistWVal != newWVal) ||
          (_persistHVal != newHVal) ||
          (_canvasWUnit != newWUnit) ||
          (_canvasHUnit != newHUnit);

      if (specChanged) {
        _canvasWUnit = newWUnit;
        _canvasHUnit = newHUnit;
        _canvasWUnitE = parseUnit(_canvasWUnit);
        _canvasHUnitE = parseUnit(_canvasHUnit);
        _persistWUnitE = _canvasWUnitE;
        _persistHUnitE = _canvasHUnitE;
        _persistWVal = newWVal;
        _persistHVal = newHVal;
        _inputValueController.text = newWVal.toString();
        _inputValueController2.text = newHVal.toString();
        // Do not recompute canvas here; wait for explicit Update Canvas
      }
    });
  }

  Future<void> _loadCanvasSpecFromDb(int projectId) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final row = await db.customSelect(
        'SELECT canvas_width_value, canvas_width_unit, canvas_height_value, canvas_height_unit, '
        'grid_cell_width_value, grid_cell_width_unit, grid_cell_height_value, grid_cell_height_unit '
        'FROM projects WHERE id = ? LIMIT 1',
        variables: [Variable.withInt(projectId)],
      ).getSingleOrNull();
      if (row == null) return;
      final data = row.data;
      final num? cwRaw = data['canvas_width_value'] as num?;
      final num? chRaw = data['canvas_height_value'] as num?;
      final String? cuw = data['canvas_width_unit'] as String?;
      final String? cuh = data['canvas_height_unit'] as String?;
      final num? gcwRaw = data['grid_cell_width_value'] as num?;
      final num? gchRaw = data['grid_cell_height_value'] as num?;
      final String? gcwu = data['grid_cell_width_unit'] as String?;
      final String? gchu = data['grid_cell_height_unit'] as String?;
      _canvasWUnit = cuw ?? 'mm';
      _canvasHUnit = cuh ?? 'mm';
      _canvasWUnitE = parseUnit(_canvasWUnit);
      _canvasHUnitE = parseUnit(_canvasHUnit);
      _persistWUnitE = _canvasWUnitE;
      _persistHUnitE = _canvasHUnitE;
      _inputValueController.text = (cwRaw ?? 100).toString();
      _inputValueController2.text = (chRaw ?? 100).toString();
      _persistWVal = (cwRaw ?? 100).toDouble();
      _persistHVal = (chRaw ?? 100).toDouble();
      // Seed grid controllers/units
      _gridWUnit = gcwu ?? 'mm';
      _gridHUnit = gchu ?? 'mm';
      _gridWUnitE = parseUnit(_gridWUnit);
      _gridHUnitE = parseUnit(_gridHUnit);
      _gridWController.text = (gcwRaw ?? 10).toString();
      _gridHController.text = (gchRaw ?? 10).toString();
      _recomputeGridFromInputs();
      final double wPx = convertUnitTyped(
          value: (cwRaw ?? 100).toDouble(),
          from: _canvasWUnitE,
          to: Unit.px,
          dpi: _AppProjectDetailPageState.kCanvasPreviewPpi);
      final double hPx = convertUnitTyped(
          value: (chRaw ?? 100).toDouble(),
          from: _canvasHUnitE,
          to: Unit.px,
          dpi: _AppProjectDetailPageState.kCanvasPreviewPpi);
      if (!mounted) return;
      _safeSetState(() {
        _canvasPxW = wPx;
        _canvasPxH = hPx;
      });
      _canvasPxNotifier.value = Size(wPx, hPx);
      // Sync controllers with DB units and px
      _widthVC?.setDpi(_AppProjectDetailPageState.kCanvasPreviewPpi);
      _heightVC?.setDpi(_AppProjectDetailPageState.kCanvasPreviewPpi);
      _widthVC?.setUnit(_canvasWUnit);
      _heightVC?.setUnit(_canvasHUnit);
      _widthVC?.setValuePx(wPx);
      _heightVC?.setValuePx(hPx);
      final current = ref.read(canvasSpecProvider);
      final spec = CanvasSpec(widthPx: wPx, heightPx: hPx);
      if (current.widthPx != spec.widthPx ||
          current.heightPx != spec.heightPx) {
        ref.read(canvasSpecProvider.notifier).setSpec(spec);
      }
    } catch (_) {}
  }

  Widget _buildDetailBody() {
    // Working area (entire grey space) with canvas centered
    final double? pxW = _canvasPxW;
    final double? pxH = _canvasPxH;
    return ColoredBox(
      color: kGrey10,
      child: ValueListenableBuilder<Size?>(
        valueListenable: _canvasPxNotifier,
        builder: (context, size, _) {
          final double? pxWv = size?.width ?? pxW;
          final double? pxHv = size?.height ?? pxH;
          return LayoutBuilder(builder: (context, c) {
            // Fixed padding; no entrance animation
            final double w = (pxWv == null || pxWv <= 0) ? 100.0 : pxWv;
            final double h = (pxHv == null || pxHv <= 0) ? 100.0 : pxHv;
            // No scaling: draw at 1:1 pixels. Clip when larger than viewport.
            final double drawW = w.clamp(1.0, double.infinity);
            final double drawH = h.clamp(1.0, double.infinity);
            // Mirror Image tab artboard behavior: fixed canvas inside unconstrained board
            final double maxContentW = drawW;
            final double maxContentH = drawH;
            final double margin = (0.1 * (maxContentW)).clamp(120.0, 480.0);
            final double boardW = maxContentW + margin;
            final double boardH = maxContentH + margin;
            return _ProjectArtboardView(
              boardW: boardW,
              boardH: boardH,
              canvasW: drawW,
              canvasH: drawH,
              gridCellW: _gridCellPxW,
              gridCellH: _gridCellPxH,
            );
          });
        },
      ),
    );
  }
}

extension on _AppProjectDetailPageState {
  Future<void> _onUpdateGridTap() async {
    final double? gwVal = double.tryParse(_gridWController.text.trim());
    final double? ghVal = double.tryParse(_gridHController.text.trim());
    if (gwVal == null || ghVal == null || gwVal <= 0 || ghVal <= 0) return;
    _recomputeGridFromInputs();
    _safeSetState(() {});
    if (_currentProjectId == null) return;
    try {
      final svc = ref.read(projectServiceProvider);
      await svc.updateGridSpec(
        ref,
        _currentProjectId!,
        cellWidthValue: gwVal,
        cellWidthUnit: _gridWUnitE.asDbString,
        cellHeightValue: ghVal,
        cellHeightUnit: _gridHUnitE.asDbString,
      );
    } catch (_) {
      // ignore persistence errors in UI
    }
  }
}

// Intentionally no image-dimension helpers in Project Detail; canvas is independent

class _ProjectHairlineBorder extends StatelessWidget {
  const _ProjectHairlineBorder();
  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    return CustomPaint(
      painter: _StaticHairlinePainter(dpr: dpr),
    );
  }
}

class _StaticHairlinePainter extends CustomPainter {
  const _StaticHairlinePainter({required this.dpr});
  final double dpr;

  @override
  void paint(Canvas canvas, Size size) {
    final double ratio = dpr <= 0 ? 1.0 : dpr;
    final double inset = 0.5 / ratio;
    final Rect rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2.0,
      size.height - inset * 2.0,
    );
    final Paint p = Paint()
      ..color = kGrey100
      ..strokeWidth = 0.0
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _StaticHairlinePainter old) => old.dpr != dpr;
}

class _GridPainter extends CustomPainter {
  const _GridPainter(
      {required this.cellW, required this.cellH, required this.color});
  final double cellW;
  final double cellH;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (cellW <= 0 || cellH <= 0) return;
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Vertical lines
    for (double x = 0; x <= size.width; x += cellW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    // Horizontal lines
    for (double y = 0; y <= size.height; y += cellH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.cellW != cellW ||
        oldDelegate.cellH != cellH ||
        oldDelegate.color != color;
  }
}

class _ProjectArtboardView extends StatelessWidget {
  const _ProjectArtboardView({
    required this.boardW,
    required this.boardH,
    required this.canvasW,
    required this.canvasH,
    this.gridCellW,
    this.gridCellH,
  });
  final double boardW;
  final double boardH;
  final double canvasW;
  final double canvasH;
  final double? gridCellW;
  final double? gridCellH;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kGrey70,
      child: Stack(
        children: [
          SizedBox.expand(
            child: LayoutBuilder(builder: (context, constraints) {
              final double maxSide =
                  constraints.maxWidth > constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
              final EdgeInsets margin = EdgeInsets.all(maxSide * 2);
              return ClipRect(
                child: InteractiveViewer(
                  transformationController: TransformationController(),
                  minScale: 0.25,
                  maxScale: 8.0,
                  constrained: false,
                  boundaryMargin: margin,
                  child: RepaintBoundary(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.zero,
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
                                  children: [
                                    const Positioned.fill(
                                        child: ColoredBox(color: kWhite)),
                                    if (gridCellW != null && gridCellH != null)
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _GridPainter(
                                            cellW: gridCellW!,
                                            cellH: gridCellH!,
                                            color: kGrey20,
                                          ),
                                        ),
                                      ),
                                    const Positioned.fill(
                                      child: _ProjectHairlineBorder(),
                                    ),
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
              );
            }),
          ),
        ],
      ),
    );
  }
}
