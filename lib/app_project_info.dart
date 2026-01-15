import 'package:flutter/widgets.dart';

// ignore_for_file: always_use_package_imports
import 'theme/app_theme_colors.dart';
import 'widgets/button_app.dart';
import 'widgets/content_filter_bar.dart';
import 'widgets/content_toolbar.dart';
import 'widgets/overview/asset_gallery.dart';
import 'widgets/side_menu_left.dart';
import 'widgets/side_menu_navigation.dart' show ProjectNavigation;
import 'widgets/side_panel.dart';

/// Project Info page shell: renders top tabs, a 33px side menu, and a side filters panel.
class AppProjectInfoPage extends StatefulWidget {
  const AppProjectInfoPage({super.key, this.projectId});

  final int? projectId;

  @override
  State<AppProjectInfoPage> createState() => _AppProjectInfoPageState();
}

class _AppProjectInfoPageState extends State<AppProjectInfoPage> {
  // Side menu selection: 0=SVG, 1=Images, 2=Color Styles
  int _menuIndex = 0;
  final bool _menuOn =
      true; // when false → off style (black bg, white icons, no border)
  // No embedded context menu state here
  double _leftPanelWidth = 240.0;
  String _activeFilterId = 'completed';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SideMenu33(
            enabled: _menuOn,
            selectedIndex: _menuIndex,
            onSelect: (i) => setState(() => _menuIndex = i),
          ),
          // Side filters placeholder (width adjustable later)
          SidePanel(
            side: SidePanelSide.left,
            width: _leftPanelWidth,
            resizable: true,
            minWidth: 200.0,
            maxWidth: 400.0,
            onResizeDelta: (dx) => setState(() {
              _leftPanelWidth = (_leftPanelWidth + dx).clamp(200.0, 400.0);
            }),
            onResetWidth: () => setState(() {
              _leftPanelWidth = 240.0;
            }),
            child: ProjectNavigation(
              onTap: (_) {},
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ContentToolbar(
                  title: 'Project Info',
                  trailing: [
                    AddProjectButton(onTap: () {}),
                  ],
                ),
                ContentFilterBar(
                  items: const [
                    FilterItem(id: 'completed', label: 'Completed'),
                    FilterItem(id: 'all', label: 'All'),
                  ],
                  activeId: _activeFilterId,
                  onChanged: (id) => setState(() => _activeFilterId = id),
                ),
                const Expanded(
                  child: ColoredBox(
                    color: kWhite,
                    child: AssetGallery(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Filters now use MenuSection (ContextMenu style)

// _BorderLine not used anymore

/// 33px full-height side menu with spec styles.
// SideMenu33 now extracted to widgets/side_menu_33.dart
