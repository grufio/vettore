import 'package:flutter/widgets.dart';

class InputDropdownController {
  late VoidCallback _open;
  late VoidCallback _close;
  late VoidCallback _toggle;
  late VoidCallback _next;
  late VoidCallback _prev;
  late VoidCallback _confirm;

  void attach(
    VoidCallback open,
    VoidCallback close,
    VoidCallback toggle,
    VoidCallback next,
    VoidCallback prev,
    VoidCallback confirm,
  ) {
    _open = open;
    _close = close;
    _toggle = toggle;
    _next = next;
    _prev = prev;
    _confirm = confirm;
  }

  void open() => _open();
  void close() => _close();
  void toggle() => _toggle();
  void highlightNext() => _next();
  void highlightPrev() => _prev();
  void confirm() => _confirm();
}
