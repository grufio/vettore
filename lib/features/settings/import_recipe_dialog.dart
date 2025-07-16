import 'dart:io';
import 'dart:typed_data';
import 'dart:async'; // Added for Completer

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ImportRecipeDialog extends StatefulWidget {
  final Future<void> Function(Uint8List) onImageImported;

  const ImportRecipeDialog({super.key, required this.onImageImported});

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
    debugPrint('[ImportDialog] State changed to: importing');
    try {
      final imageData = await getImage();
      if (imageData != null) {
        debugPrint('[ImportDialog] Image data received, processing...');
        await widget.onImageImported(imageData);
        if (mounted) setState(() => _state = _ImportState.done);
        debugPrint('[ImportDialog] State changed to: done');
      } else {
        debugPrint('[ImportDialog] No image data received, returning to idle.');
        if (mounted) setState(() => _state = _ImportState.idle);
      }
    } catch (e) {
      debugPrint('[ImportDialog] Error during import: $e');
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

  void _onUpload() {
    _importImage(() async {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        final file = File(result.files.single.path!);
        return await file.readAsBytes();
      }
      return null;
    });
  }

  void _onPaste() {
    debugPrint('[ImportDialog] _onPaste called.');
    _importImage(() async {
      debugPrint('[ImportDialog] Checking clipboard for image...');
      final reader = await ClipboardReader.readClipboard();

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
        debugPrint('[ImportDialog] Found image format: ${format.toString()}');
        final Completer<Uint8List?> completer = Completer();
        reader.getFile(format, (file) async {
          debugPrint('[ImportDialog] Reading image from clipboard...');
          completer.complete(await file.readAll());
        });
        return completer.future;
      }

      debugPrint(
        '[ImportDialog] No supported image format found on clipboard.',
      );
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
      default:
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
                  debugPrint('[ImportDialog] ActivateIntent (paste) invoked.');
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
                child: Container(
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
