// import 'dart:convert';
// import 'dart:io';
import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:equatable/equatable.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/foundation.dart' show compute;
// import 'package:vettore/services/image_compute.dart' as ic;
// import 'package:path_provider/path_provider.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
// import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/services/image_processing_service.dart';
// import 'package:vettore/services/settings_service.dart';
import 'package:vettore/services/logger.dart';

// Image bytes provider: render converted (working) bytes when present, else original
// Minimal one-time logging to verify source selection
// removed one-time logs
// moved to image_providers.dart

// Image dimensions provider: show converted size when a working image exists,
// otherwise show original size. Minimal one-time logging to verify source.
// removed one-time logs
// moved to image_providers.dart

// Image DPI provider: returns the mutable image DPI (images.dpi)
// moved to image_providers.dart

// Projects list provider (stream)
final projectsStreamProvider =
    StreamProvider.autoDispose<List<DbProject>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchAll();
});

// Aggregated vendor colors with sizes as comma-separated list
class VendorColorAggregated {
  VendorColorAggregated({
    required this.color,
    required this.sizes,
    this.rgbHex,
    this.startYear,
    this.endYear,
  });
  final VendorColor color;
  final String sizes; // e.g., "35,120,250"
  final String? rgbHex;
  final int? startYear;
  final int? endYear;

  VendorColorAggregated copyWith({
    VendorColor? color,
    String? sizes,
    String? rgbHex,
    int? startYear,
    int? endYear,
  }) {
    return VendorColorAggregated(
      color: color ?? this.color,
      sizes: sizes ?? this.sizes,
      rgbHex: rgbHex ?? this.rgbHex,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
    );
  }
}

final _vendorFilterProvider = StateProvider.autoDispose<String>((ref) => 'all');

// Debounced filter stream
final _debouncedFilterProvider =
    StreamProvider.autoDispose<String>((ref) async* {
  final controller = StreamController<String>();
  Timer? timer;
  void emit(String value) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 200), () {
      controller.add(value);
    });
  }

  final sub = ref.listen<String>(_vendorFilterProvider, (prev, next) {
    emit(next);
  });
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
    sub.close();
  });
  emit(ref.read(_vendorFilterProvider));
  yield* controller.stream;
});

final vendorColorsAggregatedProvider = StreamProvider.autoDispose
    .family<List<VendorColorAggregated>, int>((ref, vendorId) async* {
  final db = ref.watch(appDatabaseProvider);
  await for (final _ in ref.watch(_debouncedFilterProvider.stream)) {
    final rowsStream = db.customSelect(
      'SELECT vc.id, vc.vendor_id, vc.name, vc.code, vc.image_url, vc.weight_in_grams, vc.color_density, '
      'lc.rgb_hex, lc.start_year, lc.end_year, '
      'GROUP_CONCAT(vcv.size) AS sizes '
      'FROM vendor_colors vc '
      'LEFT JOIN vendor_color_variants vcv ON vcv.vendor_color_id = vc.id '
      'LEFT JOIN lego_colors lc ON lc.bl_color_id = CAST(vc.code AS INTEGER) '
      'WHERE vc.vendor_id = ? '
      'GROUP BY vc.id '
      'ORDER BY vc.name ASC',
      variables: [Variable.withInt(vendorId)],
      readsFrom: {db.vendorColors, db.vendorColorVariants},
    ).watch();
    await for (final result in rowsStream) {
      final list = result.map((row) {
        final color = VendorColor(
          id: row.read<int>('id'),
          vendorId: row.read<int?>('vendor_id'),
          name: row.read<String>('name'),
          code: row.read<String>('code'),
          imageUrl: row.read<String>('image_url'),
          weightInGrams: row.read<double?>('weight_in_grams'),
          colorDensity: row.read<double?>('color_density'),
        );
        final sizes = row.read<String?>('sizes') ?? '';
        // attach rgb for UI via an extension map entry on VendorColorAggregated using lines composition
        final rgbHex = row.read<String?>('rgb_hex');
        final sy = row.read<int?>('start_year');
        final ey = row.read<int?>('end_year');
        final extra = VendorColorAggregated(color: color, sizes: sizes);
        // temporarily stash in color.code formatting if needed by UI; main use is in overview widget below
        return extra.copyWith(rgbHex: rgbHex, startYear: sy, endYear: ey);
      }).toList();
      yield list;
    }
  }
});

// A simple data class for vector objects that can be sent to isolates.
class IsolateVectorObject {
  IsolateVectorObject(this.x, this.y, this.color);
  final int x, y;
  final int color;

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'color': color};
}

// A state class to hold the project data and its decoded image.
class ProjectState extends Equatable {
  const ProjectState({required this.project, this.decodedImage});
  final DbProject project;
  final Image? decodedImage;

  @override
  List<Object?> get props => [project, decodedImage];
}

// Provides a stream of a single project for the editor page.
final projectStreamProvider =
    StreamProvider.autoDispose.family<ProjectState, int>((ref, projectId) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final db = ref.watch(appDatabaseProvider);

  // Return a new stream that transforms the DbProject stream into a ProjectState stream
  return projectRepository.watchById(projectId).asyncMap((project) async {
    if (project == null) {
      return ProjectState(
        project: await projectRepository.getById(projectId),
        decodedImage: null,
      );
    }
    Image? decodedImage;
    if (project.imageId != null) {
      try {
        final row = await (db.select(db.images)
              ..where((t) => t.id.equals(project.imageId!)))
            .getSingleOrNull();
        final bytes = row?.convSrc ?? row?.origSrc;
        if (bytes != null && bytes.isNotEmpty) {
          final codec = await instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          decodedImage = frame.image;
        }
      } catch (e, st) {
        logWarn('Failed to decode image for project ${project.id}', e, st);
      }
    }
    return ProjectState(project: project, decodedImage: decodedImage);
  });
});

/// Stream provider for a single project row (DbProject?) by id.
final projectByIdProvider =
    StreamProvider.autoDispose.family<DbProject?, int>((ref, projectId) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchById(projectId);
});

// Stable imageId provider: caches last non-null imageId to avoid flicker
final _imageIdCacheProvider =
    StateProvider.family<int?, int>((ref, projectId) => null);

final imageIdStableProvider = Provider.family<int?, int>((ref, projectId) {
  // Write to cache in a listener (outside of provider build) to avoid init writes
  ref.listen(projectByIdProvider(projectId), (prev, next) {
    final v = next.asData?.value?.imageId;
    if (v != null) {
      ref.read(_imageIdCacheProvider(projectId).notifier).state = v;
    }
  });
  final current = ref.watch(projectByIdProvider(projectId)).asData?.value;
  final cached = ref.watch(_imageIdCacheProvider(projectId));
  return current?.imageId ?? cached;
});

// A provider for the business logic of the project editor.
final projectLogicProvider =
    Provider.autoDispose.family<ProjectLogic, int>((ref, projectId) {
  return ProjectLogic(ref, projectId);
});

class ProjectLogic {
  ProjectLogic(this.ref, this.projectId);
  final Ref ref;
  final int projectId;

  /// Runs image quantization using the external Python script via service.
  Future<void> quantizeImage() async {
    await ref
        .read(imageProcessingServiceProvider)
        .quantizeImage(ref as WidgetRef, projectId);
  }

  /// Generates the vector grid from the currently converted image data.
  /// This should only be called after `quantizeImage` has been successfully run.
  Future<void> generateGrid() async {
    // Not supported with current schema; no persistent vector storage.
    return;
  }

  Future<void> updateImage(
      double scalePercent, FilterQuality filterQuality) async {
    await ref.read(imageProcessingServiceProvider).updateImage(
          ref as WidgetRef,
          projectId: projectId,
          scalePercent: scalePercent,
          filterQuality: filterQuality,
        );
  }

  /// Resize using OpenCV with an explicit interpolation name via service
  Future<void> resizeToCv(
      int targetWidth, int targetHeight, String interpolationName) async {
    await ref.read(imageProcessingServiceProvider).resizeToCv(
          ref as WidgetRef,
          projectId: projectId,
          targetW: targetWidth,
          targetH: targetHeight,
          interpolationName: interpolationName,
        );
  }

  Future<void> resetImage() async {
    await ref
        .read(imageProcessingServiceProvider)
        .resetImage(ref as WidgetRef, projectId);
  }
}
