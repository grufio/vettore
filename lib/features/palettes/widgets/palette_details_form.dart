import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/providers/palette_provider.dart';

class PaletteDetailsForm extends ConsumerStatefulWidget {
  final Palette palette;
  final int paletteKey;
  final GlobalKey<FormState> formKey;
  const PaletteDetailsForm({
    super.key,
    required this.palette,
    required this.paletteKey,
    required this.formKey,
  });

  @override
  ConsumerState<PaletteDetailsForm> createState() => _PaletteDetailsFormState();
}

class _PaletteDetailsFormState extends ConsumerState<PaletteDetailsForm> {
  late final TextEditingController _sizeController;
  late final TextEditingController _factorController;

  @override
  void initState() {
    super.initState();
    _sizeController = TextEditingController(
      text: widget.palette.sizeInMl.toString(),
    );
    _factorController = TextEditingController(
      text: widget.palette.factor.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant PaletteDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.palette.sizeInMl != widget.palette.sizeInMl) {
      _sizeController.text = widget.palette.sizeInMl.toString();
    }
    if (oldWidget.palette.factor != widget.palette.factor) {
      _factorController.text = widget.palette.factor.toString();
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _factorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size in ml',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (value) {
                  // This value is saved to the controller,
                  // the next onSaved will trigger the update.
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a size.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _factorController,
                decoration: const InputDecoration(
                  labelText: 'Factor',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (value) {
                  ref
                      .read(paletteProvider(widget.paletteKey).notifier)
                      .updateDetails(
                        name: widget.palette.name,
                        size: double.tryParse(_sizeController.text) ?? 60.0,
                        factor: double.tryParse(value!) ?? 1.5,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Palette saved!')),
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a factor.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
