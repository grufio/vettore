# Fullscreen Toolbar Fix Plan

This document outlines the correct, documentation-based approach to fix the layout issues with the application's custom tab bar, specifically concerning its behavior in fullscreen mode.

## Problem Summary

The application's custom tab bar (`GrufioToolBar`) was not displaying correctly when transitioning between normal and fullscreen window modes. The key issues were:
1.  Incorrect spacing in normal mode, causing the tabs to overlap with the macOS window controls (traffic-light buttons).
2.  Incorrect layout and visibility of tabs in fullscreen mode.

Previous attempts to solve this with manual state tracking (`_isFullscreen` flag) and conditional padding (`SizedBox`) were incorrect, as they did not use the library's intended features.

## The Correct Solution: `TitlebarSafeArea`

The `macos_window_utils` package, a dependency of `macos_ui`, provides a dedicated widget for this exact scenario: `TitlebarSafeArea`.

The official documentation states:
> "When you ... enable the full-size content view to allow our Flutter app to draw underneath the title bar ... it is recommended to wrap your application (or parts of it) in a `TitlebarSafeArea` widget ... **This ensures that your app is not covered by the window's title bar.**"

This widget is the standard, declarative solution. It automatically handles the necessary padding to avoid the window controls in the standard windowed mode and correctly adjusts the layout when the application enters fullscreen, removing the padding as needed.

## Implementation Plan

The fix will be implemented with the following steps:

1.  **Remove Manual Fullscreen Logic**: All code added to `lib/app_overview.dart` for manually tracking the fullscreen state (e.g., `_MyDelegate`, the `_isFullscreen` variable, `initState`, and `dispose` methods) will be removed as it represents an incorrect, imperative approach.

2.  **Simplify the Custom Toolbar**: The `GrufioToolBar` widget in `lib/widgets/grufio_tabs_app.dart` will be simplified by removing the `isFullscreen` parameter and the associated conditional logic (`if (!isFullscreen) ...`).

3.  **Implement `TitlebarSafeArea`**: The `Row` widget containing the tabs within `GrufioToolBar` will be wrapped with the `TitlebarSafeArea` widget. This is the core of the fix.

4.  **Ensure Adaptive Width**: The hardcoded `titleWidth` property will be removed from `GrufioToolB`ar to allow `TitlebarSafeArea` and the `ToolBar` to manage the layout and width adaptively.

This approach aligns the application with the documented best practices of the `macos_ui` library, leading to a simpler, more robust, and correct implementation.
