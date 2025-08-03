import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_window_utils/macos/ns_window_button_type.dart';
import 'package:vettore/app_overview.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
// Note: I'm leaving the other imports commented out for now
// as they are not used by the preview page, but we will need them back later.
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vettore/features/projects/project_overview_page.dart';
// import 'package:vettore/services/settings_service.dart';
// import 'package:vettore/data/database.dart';
// import 'package:vettore/services/seeding_service.dart';
// import 'package:vettore/providers/application_providers.dart';
// import 'package:vettore/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is required to be able to manipulate the window.
  await WindowManipulator.initialize();

  // Make the title bar transparent.
  await WindowManipulator.makeTitlebarTransparent();

  // Enable the full-size content view to allow our Flutter app to draw
  // underneath the title bar.
  await WindowManipulator.enableFullSizeContentView();

  // Use a Toolbar to get the traffic light buttons.
  await WindowManipulator.addToolbar();
  await WindowManipulator.hideTitle();

  // Set the toolbar style to unified to make it appear in the title bar.
  await WindowManipulator.setToolbarStyle(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );

  runApp(const MyApp());

  // After the app has started, we can reposition the window controls.
  // We add a small delay to ensure the window is ready.
  Future.delayed(const Duration(milliseconds: 100), () async {
    const double customToolbarHeight = 40.0;

    // Get the rect of the close button to calculate its height and original x-position.
    final closeButtonRect =
        await WindowManipulator.getStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.closeButton,
    );

    if (closeButtonRect == null) {
      return;
    }

    final buttonHeight = closeButtonRect.height;
    // Calculate the Y offset to center the button in our custom toolbar.
    final yOffset = (customToolbarHeight - buttonHeight) / 2.0;

    // Get the original x-coordinates for the other buttons.
    final miniaturizeButtonRect =
        await WindowManipulator.getStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.miniaturizeButton,
    );
    final zoomButtonRect =
        await WindowManipulator.getStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.zoomButton,
    );

    // Apply the new positions.
    // We use the original 'left' (x-coordinate) and apply our new 'yOffset'.
    WindowManipulator.overrideStandardWindowButtonPosition(
      buttonType: NSWindowButtonType.closeButton,
      offset: Offset(closeButtonRect.left, yOffset),
    );

    if (miniaturizeButtonRect != null) {
      WindowManipulator.overrideStandardWindowButtonPosition(
        buttonType: NSWindowButtonType.miniaturizeButton,
        offset: Offset(miniaturizeButtonRect.left, yOffset),
      );
    }

    if (zoomButtonRect != null) {
      WindowManipulator.overrideStandardWindowButtonPosition(
        buttonType: NSWindowButtonType.zoomButton,
        offset: Offset(zoomButtonRect.left, yOffset),
      );
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AppOverviewPage(),
    );
  }
}
