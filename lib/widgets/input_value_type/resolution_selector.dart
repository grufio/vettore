import 'package:flutter/widgets.dart';
import 'package:grufio/widgets/input_value_type/input_value_type.dart';
import 'package:grufio/widgets/section_sidebar.dart' show SectionInput;

class ResolutionSelector extends StatefulWidget {
  const ResolutionSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.readOnlyView = false,
  });
  final int value; // dpi
  final ValueChanged<int> onChanged;
  final bool enabled;
  final bool readOnlyView;

  @override
  State<ResolutionSelector> createState() => _ResolutionSelectorState();
}

class _ResolutionSelectorState extends State<ResolutionSelector> {
  static const List<int> _dpiItems = [72, 96, 144];
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant ResolutionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _dpiItems.map((d) => '$d').toList(growable: false);
    return SectionInput(
      full: InputValueType(
        controller: _controller,
        prefixIconAsset: 'help',
        prefixIconWidth: 16.0,
        prefixIconHeight: 16.0,
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        enableSelection: false,
        dropdownItems: items,
        selectedItem: '${widget.value}',
        suffixText: 'dpi',
        variant: InputVariant.dropdown,
        readOnly: !widget.enabled,
        readOnlyView: widget.readOnlyView || !widget.enabled,
        suffixKey: const ValueKey('dpi-suffix'),
        onItemSelected: (label) {
          final parsed = int.tryParse(label);
          if (parsed != null) {
            _controller.text = '$parsed';
            widget.onChanged(parsed);
          }
        },
      ),
    );
  }
}
