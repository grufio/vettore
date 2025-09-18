/// Runtime guard to detect accidental coupling between canvas and image logic.
class CouplingGuard {
  static bool _inCanvasSizing = false;

  static void enterCanvasSizing() {
    _inCanvasSizing = true;
  }

  static void leaveCanvasSizing() {
    _inCanvasSizing = false;
  }

  static void checkImageAccess(String label) {
    if (_inCanvasSizing) {
      // ignore: avoid_print
      print('[CouplingGuard] WARNING: Image access during canvas sizing at $label');
    }
  }
}
