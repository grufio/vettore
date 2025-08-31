import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/app_header_bar.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/input_value_type.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/section_input.dart';
import 'package:vettore/widgets/button_app.dart';
import 'package:vettore/widgets/image_upload_text.dart';

class AppProjectDetailPage extends StatefulWidget {
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  const AppProjectDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
  });

  @override
  State<AppProjectDetailPage> createState() => _AppProjectDetailPageState();
}

class _AppProjectDetailPageState extends State<AppProjectDetailPage> {
  static const double _kToolbarHeight = 40.0;

  late int _activeIndex;
  String _detailFilterId = 'image';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _singleInputController;
  double _rightPanelWidth = 260.0;
  final _tabs = <GrufioTabData>[
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Example'),
  ];

  void _onTabSelected(int i) {
    setState(() => _activeIndex = i);
    widget.onNavigateTab?.call(i);
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialActiveIndex;
    _inputValueController = TextEditingController(text: '1024');
    _inputValueController2 = TextEditingController();
    _singleInputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _singleInputController.dispose();
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

    return ColoredBox(
      color: kWhite,
      child: Column(
        children: [
          AppHeaderBar(
            tabs: _tabs,
            activeIndex: _activeIndex,
            onTabSelected: _onTabSelected,
            height: _kToolbarHeight,
            leftPaddingWhenWindowed: 72,
          ),
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
                FilterItem(id: 'image', label: 'Image'),
                FilterItem(id: 'conversion', label: 'Conversion'),
                FilterItem(id: 'grid', label: 'Grid'),
                FilterItem(id: 'output', label: 'Output'),
              ],
              activeId: _detailFilterId,
              onChanged: (id) => setState(() => _detailFilterId = id),
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
                    topPadding: 8.0,
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
                        _rightPanelWidth = 280.0;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionSidebar(
                          title: 'Title',
                          children: [
                            SectionInput(
                              left: InputValueType(
                                controller: _inputValueController,
                                placeholder: null,
                              ),
                              right: InputValueType(
                                controller: _inputValueController2,
                                placeholder: null,
                              ),
                              actionIconAsset: null,
                            ),
                            SectionInput(
                              left: InputValueType(
                                controller: _singleInputController,
                                placeholder: null,
                              ),
                              right: null,
                              actionIconAsset: null,
                            ),
                            SectionInput(
                              full: AddProjectButton(onTap: () {}),
                              actionIconAsset: null,
                            ),
                          ],
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

extension on _AppProjectDetailPageState {
  Widget _buildDetailBody() {
    return const ColoredBox(
      color: kGrey10,
      child: Center(
        child: ImageUploadText(),
      ),
    );
  }
}
