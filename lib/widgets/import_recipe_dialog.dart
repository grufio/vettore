import 'dart:async'; // Added for Completer

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ImportRecipeDialog extends StatefulWidget {
  const ImportRecipeDialog({super.key, required this.onImageImported});
  final Future<void> Function(Uint8List) onImageImported;

  @override
  State<ImportRecipeDialog> createState() => _ImportRecipeDialogState();
}

enum _ImportState { idle, importing, done, error }

class _ImportRecipeDialogState extends State<ImportRecipeDialog> {
  bool _isDragging = false;
  _ImportState _state = _ImportState.idle;
  String _errorMessage = '';

  void _onDragEntered(DropEventDetails details) {
    setState(() => _isDragging = true);
  }

  void _onDragExited(DropEventDetails details) {
    setState(() => _isDragging = false);
  }

  Future<void> _importImage(Future<Uint8List?> Function() getImage) async {
    setState(() => _state = _ImportState.importing);
    assert(() {
      debugPrint('[ImportDialog] State changed to: importing');
      return true;
    }());
    try {
      final imageData = await getImage();
      if (imageData != null) {
        assert(() {
          debugPrint('[ImportDialog] Image data received, processing...');
          return true;
        }());
        await widget.onImageImported(imageData);
        if (mounted) setState(() => _state = _ImportState.done);
        assert(() {
          debugPrint('[ImportDialog] State changed to: done');
          return true;
        }());
      } else {
        assert(() {
          debugPrint(
              '[ImportDialog] No image data received, returning to idle.');
          return true;
        }());
        if (mounted) setState(() => _state = _ImportState.idle);
      }
    } catch (e) {
      assert(() {
        debugPrint('[ImportDialog] Error during import: $e');
        return true;
      }());
      if (mounted) {
        setState(() {
          _state = _ImportState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onDragDone(DropDoneDetails details) async {
    _importImage(() async => await details.files.first.readAsBytes());
  }

  void _onPaste() {
    assert(() {
      debugPrint('[ImportDialog] _onPaste called.');
      return true;
    }());
    _importImage(() async {
      final reader = await SystemClipboard.instance?.read();
      if (reader == null) return null;

      final imageFormats = [
        Formats.png,
        Formats.jpeg,
        Formats.gif,
        Formats.tiff,
      ];
      // Find the first available format that is a FileFormat
      final available = reader.getFormats(imageFormats);
      final format = available.whereType<FileFormat>().firstOrNull;

      if (format != null) {
        assert(() {
          debugPrint('[ImportDialog] Found image format: ${format.toString()}');
          return true;
        }());
        final Completer<Uint8List?> completer = Completer();
        reader.getFile(format, (file) async {
          assert(() {
            debugPrint('[ImportDialog] Reading image from clipboard...');
            return true;
          }());
          completer.complete(await file.readAll());
        });
        return completer.future;
      }

      assert(() {
        debugPrint(
            '[ImportDialog] No supported image format found on clipboard.');
        return true;
      }());
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Recipe'),
      content: SizedBox(width: 300, height: 220, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _ImportState.importing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('AI in progress...'),
            ],
          ),
        );
      case _ImportState.done:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text('Import Complete'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Finish'),
            ),
          ],
        );
      case _ImportState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Import Failed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _state = _ImportState.idle),
              child: const Text('Try Again'),
            ),
          ],
        );
      case _ImportState.idle:
        return Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV):
                const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
                const ActivateIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  assert(() {
                    debugPrint(
                        '[ImportDialog] ActivateIntent (paste) invoked.');
                    return true;
                  }());
                  _onPaste();
                  return null;
                },
              ),
            },
            child: Focus(
              autofocus: true,
              child: DropTarget(
                onDragDone: _onDragDone,
                onDragEntered: _onDragEntered,
                onDragExited: _onDragExited,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isDragging ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 48),
                      SizedBox(height: 16),
                      Text('Drag & drop, paste (Cmd/Ctrl+V),'),
                      Text('or click to select a file.'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: null, // Will be handled by parent
                        child: Text('Select File'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
