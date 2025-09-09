import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/constants/input_constants.dart';

class InterpolationSelector extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const InterpolationSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

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
      left: InputValueType(
        controller: _controller,
        placeholder: null,
        enableSelection: false,
        dropdownItems: _items,
        selectedItem: null,
        variant: InputVariant.dropdown,
        readOnly: false,
        onChanged: (t) {
          if (t != widget.value) {
            _controller.text = widget.value;
          }
        },
        onItemSelected: (v) {
          _controller.text = v;
          widget.onChanged(v);
        },
      ),
      right: null,
      actionIconAsset: null,
    );
  }
}
