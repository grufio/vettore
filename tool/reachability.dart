import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

/// Build a reachability graph from a given entry library by traversing
/// import/export/part directives. Reports lib/*.dart files that are not
/// reachable. Always keeps generated files (*.g.dart, *.freezed.dart) and
/// any files that declare `part of`.
Future<int> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('entry', help: 'Entry point path (e.g., lib/main.dart)')
    ..addOption('format', allowed: ['text', 'json'], defaultsTo: 'text')
    ..addFlag('widgets-unused',
        defaultsTo: false,
        help:
            'Additionally report lib/widgets/*.dart whose top-level class names are never referenced across lib');

  final results = parser.parse(args);
  final entryArg = results['entry'] as String?;
  final format = results['format'] as String;

  if (entryArg == null || entryArg.isEmpty) {
    stderr.writeln('Missing --entry (e.g., --entry lib/main.dart)');
    return 2;
  }

  final repoRoot = p.normalize(p.absolute(p.current));
  final libDir = p.join(repoRoot, 'lib');
  final entryPath = _toAbsoluteFromLibOrRelative(libDir, entryArg);

  if (!File(entryPath).existsSync()) {
    stderr.writeln('Entry file not found: $entryPath');
    return 2;
  }

  // Collect all dart files under lib.
  final allLibDartFiles = _listDartFiles(libDir);

  // Pre-parse to know which files are parts (contain `part of`). Keep these.
  final partOfFiles = <String>{};
  final fileToEdges =
      <String, Set<String>>{}; // absolute file -> referenced files (absolute)
  for (final file in allLibDartFiles) {
    final parsed = _safeParse(file);
    if (parsed == null) continue;

    // Detect `part of` declarations => never delete these.
    for (final d in parsed.directives) {
      if (d is PartOfDirective) {
        partOfFiles.add(file);
      }
    }

    // Collect edges for imports/exports/parts
    final edges = <String>{};

    for (final d in parsed.directives) {
      if (d is ImportDirective) {
        final uri = d.uri.stringValue;
        if (uri != null) {
          final resolved = _resolveUri(repoRoot, libDir, file, uri);
          if (resolved != null) edges.add(resolved);
        }
        // Include conditional import candidates as reachable
        for (final cfg in d.configurations) {
          final uri = cfg.uri.stringValue;
          if (uri != null) {
            final resolved = _resolveUri(repoRoot, libDir, file, uri);
            if (resolved != null) edges.add(resolved);
          }
        }
      } else if (d is ExportDirective) {
        final uri = d.uri.stringValue;
        if (uri != null) {
          final resolved = _resolveUri(repoRoot, libDir, file, uri);
          if (resolved != null) edges.add(resolved);
        }
      } else if (d is PartDirective) {
        final uri = d.uri.stringValue;
        if (uri != null) {
          final resolved = _resolveUri(repoRoot, libDir, file, uri);
          if (resolved != null) edges.add(resolved);
        }
      }
    }

    fileToEdges[file] = edges;
  }

  // Traverse from entry across imports/exports/parts
  final reachable = <String>{};
  final queue = <String>[entryPath];
  while (queue.isNotEmpty) {
    final cur = queue.removeLast();
    if (reachable.contains(cur)) continue;
    reachable.add(cur);
    final edges = fileToEdges[cur];
    if (edges == null) continue;
    for (final next in edges) {
      if (!reachable.contains(next)) {
        queue.add(next);
      }
    }
  }

  // Keep list: generated files and part-of files
  bool isGenerated(String path) =>
      path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

  final candidates = <String>[];
  for (final file in allLibDartFiles) {
    if (isGenerated(file)) continue; // always keep
    if (partOfFiles.contains(file)) continue; // always keep
    if (!reachable.contains(file)) {
      candidates.add(p.relative(file, from: repoRoot));
    }
  }

  candidates.sort();

  final output = <String, Object>{
    'entry': p.relative(entryPath, from: repoRoot),
    'unreachable': candidates,
  };

  if (results['widgets-unused'] == true) {
    final widgetDir = p.join(libDir, 'widgets');
    final widgetFiles = allLibDartFiles
        .where((f) => p.isWithin(widgetDir, f))
        .where((f) => !isGenerated(f) && !partOfFiles.contains(f))
        .toList();

    final libFilesForScan =
        allLibDartFiles.where((f) => !isGenerated(f)).toList(growable: false);

    final neverReferenced = <String>[];
    // Preload contents for simple word-boundary scans.
    final fileContents = <String, String>{
      for (final f in libFilesForScan) f: File(f).readAsStringSync()
    };

    for (final wf in widgetFiles) {
      final unit = _safeParse(wf);
      if (unit == null) continue;
      final names = _topLevelClassishNames(unit);
      if (names.isEmpty) continue;

      var referenced = false;
      for (final entry in fileContents.entries) {
        final otherPath = entry.key;
        if (otherPath == wf) continue;
        final content = entry.value;
        for (final name in names) {
          final pattern = RegExp('\\b' + RegExp.escape(name) + '\\b');
          if (pattern.hasMatch(content)) {
            referenced = true;
            break;
          }
        }
        if (referenced) break;
      }
      if (!referenced) {
        neverReferenced.add(p.relative(wf, from: repoRoot));
      }
    }

    neverReferenced.sort();
    output['widgets_never_referenced'] = neverReferenced;
  }

  if (format == 'json') {
    stdout.writeln(jsonEncode(output));
  } else {
    stdout.writeln('Entry: ${output['entry']}');
    stdout.writeln('Unreachable files (excluding generated and part-of):');
    for (final c in (output['unreachable'] as List)) {
      stdout.writeln(' - $c');
    }
    if (output.containsKey('widgets_never_referenced')) {
      stdout.writeln(
          'Widgets whose top-level class names are never referenced across lib:');
      for (final c in (output['widgets_never_referenced'] as List)) {
        stdout.writeln(' - $c');
      }
    }
  }

  return 0;
}

List<String> _listDartFiles(String libDir) {
  final out = <String>[];
  final root = Directory(libDir);
  if (!root.existsSync()) return out;
  for (final ent in root.listSync(recursive: true, followLinks: false)) {
    if (ent is File && ent.path.endsWith('.dart')) {
      out.add(p.normalize(ent.absolute.path));
    }
  }
  return out;
}

CompilationUnit? _safeParse(String filePath) {
  try {
    final content = File(filePath).readAsStringSync();
    final res = parseString(content: content, path: filePath);
    return res.unit;
  } catch (_) {
    return null;
  }
}

List<String> _topLevelClassishNames(CompilationUnit unit) {
  final names = <String>[];
  for (final decl in unit.declarations) {
    if (decl is ClassDeclaration) {
      names.add(decl.name.lexeme);
    } else if (decl is EnumDeclaration) {
      names.add(decl.name.lexeme);
    } else if (decl is MixinDeclaration) {
      names.add(decl.name.lexeme);
    } else if (decl is FunctionDeclaration) {
      if (decl.name.lexeme.isNotEmpty) names.add(decl.name.lexeme);
    } else if (decl is TypeAlias) {
      names.add(decl.name.lexeme);
    }
  }
  return names;
}

String _toAbsoluteFromLibOrRelative(String libDir, String input) {
  final normalized = p.normalize(input);
  if (p.isAbsolute(normalized)) return normalized;
  if (normalized.startsWith('lib${p.separator}')) {
    return p.normalize(p.join(p.dirname(libDir), normalized));
  }
  return p.normalize(p.join(libDir, p.relative(normalized, from: 'lib')));
}

String? _resolveUri(
    String repoRoot, String libDir, String fromFile, String uri) {
  if (uri.startsWith('dart:')) return null; // SDK
  if (uri.startsWith('package:')) {
    final pkg = 'package:vettore/';
    if (!uri.startsWith(pkg)) return null; // other packages
    final rel = uri.substring(pkg.length);
    final abs = p.normalize(p.join(libDir, rel));
    return File(abs).existsSync() ? abs : null;
  }
  // Relative path
  final abs = p.normalize(p.join(p.dirname(fromFile), uri));
  return File(abs).existsSync() ? abs : null;
}
