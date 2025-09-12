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
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/data/database.dart';
import 'dart:async';
import 'package:vettore/widgets/input_value_type/width_row.dart';
import 'package:vettore/widgets/input_value_type/height_row.dart';
import 'package:vettore/services/dimensions_guard.dart';
// import 'package:flutter/foundation.dart' show compute;
// import 'package:vettore/services/image_compute.dart' as ic;
import 'package:vettore/widgets/input_value_type/interpolation_map.dart';
import 'package:vettore/providers/navigation_providers.dart';
import 'package:vettore/widgets/input_value_type/input_value_type.dart';

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
  late final TextEditingController _modelController;
  late final TextEditingController _typeController;
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
    _modelController = TextEditingController();
    _typeController = TextEditingController();
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
    _modelController.dispose();
    _typeController.dispose();
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
    }

    return ColoredBox(
      color: kWhite,
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
              color: kWhite,
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
                        // Section: Model (placed directly below 'Projekt')
                        SectionSidebar(
                          title: 'Model',
                          children: [
                            SectionInput(
                              full: InputValueType(
                                controller: _modelController,
                                placeholder: 'Select model',
                                variant: InputVariant.dropdown,
                                dropdownItems: const ['Bricks', 'Colors'],
                                onItemSelected: (value) {
                                  _modelController.text = value;
                                  // Update default Type when Model changes
                                  if (value == 'Bricks') {
                                    _typeController.text = 'Lego';
                                  } else if (value == 'Colors') {
                                    _typeController.text = 'Schmincke';
                                  } else {
                                    _typeController.text = '';
                                  }
                                  _persistModelAndVendorForLabels(
                                      modelLabel: value,
                                      typeLabel: _typeController.text);
                                },
                              ),
                            ),
                            // Type input moved into the Model section
                            SectionInput(
                              full: InputValueType(
                                controller: _typeController,
                                placeholder: 'Select type',
                                variant: InputVariant.dropdown,
                                dropdownItems: _modelController.text == 'Bricks'
                                    ? const ['Lego']
                                    : _modelController.text == 'Colors'
                                        ? const ['Schmincke']
                                        : const ['Lego', 'Schmincke'],
                                onItemSelected: (value) {
                                  _typeController.text = value;
                                  _persistModelAndVendorForLabels(
                                    modelLabel: _modelController.text,
                                    typeLabel: value,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Builder(builder: (context) {
                          final int? imageId = (_currentProjectId != null)
                              ? ref.watch(
                                  projectByIdProvider(_currentProjectId!)
                                      .select((p) => p.asData?.value?.imageId))
                              : null;
                          final bool hasImage = imageId != null;
                          return SectionSidebar(
                            title: 'Dimensions',
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

extension on _AppProjectDetailPageState {
  Future<void> _persistModelAndVendorForLabels({
    required String modelLabel,
    required String typeLabel,
  }) async {
    if (_currentProjectId == null) return;
    final db = ref.read(appDatabaseProvider);
    // Map UI labels to DB values
    final String modelValue =
        modelLabel.toLowerCase() == 'bricks' ? 'bricks' : 'colors';
    final String vendorBrand = typeLabel.toLowerCase().startsWith('lego')
        ? 'Lego'
        : 'Norma professional';
    try {
      // Lookup vendor id by brand (safe: controlled values; escape quotes)
      final safeBrand = vendorBrand.replaceAll("'", "''");
      final vendorRow = await db
          .customSelect(
              "SELECT id FROM vendors WHERE vendor_brand = '$safeBrand' LIMIT 1")
          .getSingleOrNull();
      final int? vendorId = vendorRow?.data['id'] as int?;

      final safeModel = modelValue.replaceAll("'", "''");
      final projId = _currentProjectId!;
      // Persist model and vendor_id
      await db.customStatement(
          "UPDATE projects SET model = '$safeModel', vendor_id = ${vendorId ?? 'NULL'} WHERE id = $projId");
    } catch (_) {
      // Silent fail for now
    }
  }

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
        // Initialize Model/Type from DB if present
        try {
          final db = ref.read(appDatabaseProvider);
          final String? model = (p as dynamic).model as String?; // nullable
          if (model != null) {
            _modelController.text = model == 'bricks' ? 'Bricks' : 'Colors';
          }
          final int? vId = (p as dynamic).vendorId as int?;
          if (vId != null) {
            final vrow = await db
                .customSelect(
                    'SELECT vendor_brand FROM vendors WHERE id = $vId LIMIT 1')
                .getSingleOrNull();
            final brand = vrow?.data['vendor_brand'] as String?;
            if (brand != null) {
              _typeController.text = brand == 'Lego' ? 'Lego' : 'Schmincke';
            }
          }
        } catch (_) {}
        if (p.imageId != null) {
          await _loadImageDimensions(p.imageId!);
        } else {
          _inputValueController.text = '';
          _inputValueController2.text = '';
        }
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
        // Initialize Model/Type from DB if present
        try {
          final db = ref.read(appDatabaseProvider);
          final String? model = (p as dynamic).model as String?; // nullable
          if (model != null) {
            _modelController.text = model == 'bricks' ? 'Bricks' : 'Colors';
          }
          final int? vId = (p as dynamic).vendorId as int?;
          if (vId != null) {
            final vrow = await db
                .customSelect(
                    'SELECT vendor_brand FROM vendors WHERE id = $vId LIMIT 1')
                .getSingleOrNull();
            final brand = vrow?.data['vendor_brand'] as String?;
            if (brand != null) {
              _typeController.text = brand == 'Lego' ? 'Lego' : 'Schmincke';
            }
          }
        } catch (_) {}
        if (p.imageId != null) {
          await _loadImageDimensions(p.imageId!);
        } else {
          _inputValueController.text = '';
          _inputValueController2.text = '';
        }
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
    // Image upload/view moved to Image Detail; keep this area empty.
    return const ColoredBox(color: kGrey10, child: SizedBox.expand());
  }
}

extension _ImageDimensions on _AppProjectDetailPageState {
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
