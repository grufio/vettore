import 'package:flutter/widgets.dart';
import 'package:grufio/widgets/constants/input_constants.dart';
import 'package:grufio/widgets/input_value_type/input_value_type.dart';
import 'package:grufio/widgets/section_sidebar.dart' show SectionInput;

class InterpolationSelector extends StatefulWidget {
  const InterpolationSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.readOnlyView = false,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool readOnlyView;

  @override
  State<InterpolationSelector> createState() => _InterpolationSelectorState();
}

class _InterpolationSelectorState extends State<InterpolationSelector> {
  static const List<String> _items = kInterpolations;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InterpolationSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionInput(
      full: InputValueType(
        controller: _controller,
        prefixIconAsset: 'help',
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        prefixIconWidth: 16.0,
        prefixIconHeight: 16.0,
        enableSelection: false,
        dropdownItems: _items,
        variant: InputVariant.dropdown,
        readOnly: true,
        readOnlyView: widget.readOnlyView,
        onItemSelected: (v) => widget.onChanged(v),
      ),
    );
  }
}
