import 'package:flutter/widgets.dart';
// ignore_for_file: always_use_package_imports
import 'grufio_icons.dart';

// Central deterministic registry mapping stable IDs to IconData.
const Map<String, IconData> grufioById = <String, IconData>{
  'home': Grufio.home,
  'color-palette': Grufio.colorPalette,
  'add': Grufio.add,
  'close': Grufio.close,
  'document-blank': Grufio.documentBlank,
  'width': Grufio.width,
  'height': Grufio.height,
  'help': Grufio.help,
  'chevron-down': Grufio.chevronDown,
  'link': Grufio.link,
  'unlink': Grufio.unlink,
  'zoom-in': Grufio.zoomIn,
  'zoom-out': Grufio.zoomOut,
  'zoom-fit': Grufio.zoomFit,
};
