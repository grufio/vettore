// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PalettesTable extends Palettes with TableInfo<$PalettesTable, Palette> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PalettesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sizeInMlMeta =
      const VerificationMeta('sizeInMl');
  @override
  late final GeneratedColumn<double> sizeInMl = GeneratedColumn<double>(
      'size_in_ml', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(60.0));
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<double> factor = GeneratedColumn<double>(
      'factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.5));
  static const VerificationMeta _thumbnailMeta =
      const VerificationMeta('thumbnail');
  @override
  late final GeneratedColumn<Uint8List> thumbnail = GeneratedColumn<Uint8List>(
      'thumbnail', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _isPredefinedMeta =
      const VerificationMeta('isPredefined');
  @override
  late final GeneratedColumn<bool> isPredefined = GeneratedColumn<bool>(
      'is_predefined', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_predefined" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, sizeInMl, factor, thumbnail, isPredefined];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'palettes';
  @override
  VerificationContext validateIntegrity(Insertable<Palette> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('size_in_ml')) {
      context.handle(_sizeInMlMeta,
          sizeInMl.isAcceptableOrUnknown(data['size_in_ml']!, _sizeInMlMeta));
    }
    if (data.containsKey('factor')) {
      context.handle(_factorMeta,
          factor.isAcceptableOrUnknown(data['factor']!, _factorMeta));
    }
    if (data.containsKey('thumbnail')) {
      context.handle(_thumbnailMeta,
          thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta));
    }
    if (data.containsKey('is_predefined')) {
      context.handle(
          _isPredefinedMeta,
          isPredefined.isAcceptableOrUnknown(
              data['is_predefined']!, _isPredefinedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Palette map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Palette(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sizeInMl: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}size_in_ml'])!,
      factor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}factor'])!,
      thumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}thumbnail']),
      isPredefined: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_predefined'])!,
    );
  }

  @override
  $PalettesTable createAlias(String alias) {
    return $PalettesTable(attachedDatabase, alias);
  }
}

class Palette extends DataClass implements Insertable<Palette> {
  final int id;
  final String name;
  final String? description;
  final double sizeInMl;
  final double factor;
  final Uint8List? thumbnail;
  final bool isPredefined;
  const Palette(
      {required this.id,
      required this.name,
      this.description,
      required this.sizeInMl,
      required this.factor,
      this.thumbnail,
      required this.isPredefined});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['size_in_ml'] = Variable<double>(sizeInMl);
    map['factor'] = Variable<double>(factor);
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail);
    }
    map['is_predefined'] = Variable<bool>(isPredefined);
    return map;
  }

  PalettesCompanion toCompanion(bool nullToAbsent) {
    return PalettesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sizeInMl: Value(sizeInMl),
      factor: Value(factor),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      isPredefined: Value(isPredefined),
    );
  }

  factory Palette.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Palette(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sizeInMl: serializer.fromJson<double>(json['sizeInMl']),
      factor: serializer.fromJson<double>(json['factor']),
      thumbnail: serializer.fromJson<Uint8List?>(json['thumbnail']),
      isPredefined: serializer.fromJson<bool>(json['isPredefined']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sizeInMl': serializer.toJson<double>(sizeInMl),
      'factor': serializer.toJson<double>(factor),
      'thumbnail': serializer.toJson<Uint8List?>(thumbnail),
      'isPredefined': serializer.toJson<bool>(isPredefined),
    };
  }

  Palette copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? sizeInMl,
          double? factor,
          Value<Uint8List?> thumbnail = const Value.absent(),
          bool? isPredefined}) =>
      Palette(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        sizeInMl: sizeInMl ?? this.sizeInMl,
        factor: factor ?? this.factor,
        thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
        isPredefined: isPredefined ?? this.isPredefined,
      );
  Palette copyWithCompanion(PalettesCompanion data) {
    return Palette(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      sizeInMl: data.sizeInMl.present ? data.sizeInMl.value : this.sizeInMl,
      factor: data.factor.present ? data.factor.value : this.factor,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      isPredefined: data.isPredefined.present
          ? data.isPredefined.value
          : this.isPredefined,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Palette(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sizeInMl: $sizeInMl, ')
          ..write('factor: $factor, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('isPredefined: $isPredefined')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, sizeInMl, factor,
      $driftBlobEquality.hash(thumbnail), isPredefined);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Palette &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sizeInMl == this.sizeInMl &&
          other.factor == this.factor &&
          $driftBlobEquality.equals(other.thumbnail, this.thumbnail) &&
          other.isPredefined == this.isPredefined);
}

class PalettesCompanion extends UpdateCompanion<Palette> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> sizeInMl;
  final Value<double> factor;
  final Value<Uint8List?> thumbnail;
  final Value<bool> isPredefined;
  const PalettesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sizeInMl = const Value.absent(),
    this.factor = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.isPredefined = const Value.absent(),
  });
  PalettesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.sizeInMl = const Value.absent(),
    this.factor = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.isPredefined = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Palette> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? sizeInMl,
    Expression<double>? factor,
    Expression<Uint8List>? thumbnail,
    Expression<bool>? isPredefined,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sizeInMl != null) 'size_in_ml': sizeInMl,
      if (factor != null) 'factor': factor,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (isPredefined != null) 'is_predefined': isPredefined,
    });
  }

  PalettesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? sizeInMl,
      Value<double>? factor,
      Value<Uint8List?>? thumbnail,
      Value<bool>? isPredefined}) {
    return PalettesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sizeInMl: sizeInMl ?? this.sizeInMl,
      factor: factor ?? this.factor,
      thumbnail: thumbnail ?? this.thumbnail,
      isPredefined: isPredefined ?? this.isPredefined,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sizeInMl.present) {
      map['size_in_ml'] = Variable<double>(sizeInMl.value);
    }
    if (factor.present) {
      map['factor'] = Variable<double>(factor.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail.value);
    }
    if (isPredefined.present) {
      map['is_predefined'] = Variable<bool>(isPredefined.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PalettesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sizeInMl: $sizeInMl, ')
          ..write('factor: $factor, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('isPredefined: $isPredefined')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageDataMeta =
      const VerificationMeta('imageData');
  @override
  late final GeneratedColumn<Uint8List> imageData = GeneratedColumn<Uint8List>(
      'image_data', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailDataMeta =
      const VerificationMeta('thumbnailData');
  @override
  late final GeneratedColumn<Uint8List> thumbnailData =
      GeneratedColumn<Uint8List>('thumbnail_data', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _isConvertedMeta =
      const VerificationMeta('isConverted');
  @override
  late final GeneratedColumn<bool> isConverted = GeneratedColumn<bool>(
      'is_converted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_converted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _vectorObjectsMeta =
      const VerificationMeta('vectorObjects');
  @override
  late final GeneratedColumn<String> vectorObjects = GeneratedColumn<String>(
      'vector_objects', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _imageWidthMeta =
      const VerificationMeta('imageWidth');
  @override
  late final GeneratedColumn<double> imageWidth = GeneratedColumn<double>(
      'image_width', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _imageHeightMeta =
      const VerificationMeta('imageHeight');
  @override
  late final GeneratedColumn<double> imageHeight = GeneratedColumn<double>(
      'image_height', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _uniqueColorCountMeta =
      const VerificationMeta('uniqueColorCount');
  @override
  late final GeneratedColumn<int> uniqueColorCount = GeneratedColumn<int>(
      'unique_color_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originalImageDataMeta =
      const VerificationMeta('originalImageData');
  @override
  late final GeneratedColumn<Uint8List> originalImageData =
      GeneratedColumn<Uint8List>('original_image_data', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _resizedImageDataMeta =
      const VerificationMeta('resizedImageData');
  @override
  late final GeneratedColumn<Uint8List> resizedImageData =
      GeneratedColumn<Uint8List>('resized_image_data', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _originalImageWidthMeta =
      const VerificationMeta('originalImageWidth');
  @override
  late final GeneratedColumn<double> originalImageWidth =
      GeneratedColumn<double>('original_image_width', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _originalImageHeightMeta =
      const VerificationMeta('originalImageHeight');
  @override
  late final GeneratedColumn<double> originalImageHeight =
      GeneratedColumn<double>('original_image_height', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _filterQualityIndexMeta =
      const VerificationMeta('filterQualityIndex');
  @override
  late final GeneratedColumn<int> filterQualityIndex = GeneratedColumn<int>(
      'filter_quality_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _paletteIdMeta =
      const VerificationMeta('paletteId');
  @override
  late final GeneratedColumn<int> paletteId = GeneratedColumn<int>(
      'palette_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES palettes (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        imageData,
        thumbnailData,
        isConverted,
        vectorObjects,
        imageWidth,
        imageHeight,
        uniqueColorCount,
        originalImageData,
        resizedImageData,
        originalImageWidth,
        originalImageHeight,
        filterQualityIndex,
        paletteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_data')) {
      context.handle(_imageDataMeta,
          imageData.isAcceptableOrUnknown(data['image_data']!, _imageDataMeta));
    } else if (isInserting) {
      context.missing(_imageDataMeta);
    }
    if (data.containsKey('thumbnail_data')) {
      context.handle(
          _thumbnailDataMeta,
          thumbnailData.isAcceptableOrUnknown(
              data['thumbnail_data']!, _thumbnailDataMeta));
    } else if (isInserting) {
      context.missing(_thumbnailDataMeta);
    }
    if (data.containsKey('is_converted')) {
      context.handle(
          _isConvertedMeta,
          isConverted.isAcceptableOrUnknown(
              data['is_converted']!, _isConvertedMeta));
    }
    if (data.containsKey('vector_objects')) {
      context.handle(
          _vectorObjectsMeta,
          vectorObjects.isAcceptableOrUnknown(
              data['vector_objects']!, _vectorObjectsMeta));
    }
    if (data.containsKey('image_width')) {
      context.handle(
          _imageWidthMeta,
          imageWidth.isAcceptableOrUnknown(
              data['image_width']!, _imageWidthMeta));
    }
    if (data.containsKey('image_height')) {
      context.handle(
          _imageHeightMeta,
          imageHeight.isAcceptableOrUnknown(
              data['image_height']!, _imageHeightMeta));
    }
    if (data.containsKey('unique_color_count')) {
      context.handle(
          _uniqueColorCountMeta,
          uniqueColorCount.isAcceptableOrUnknown(
              data['unique_color_count']!, _uniqueColorCountMeta));
    }
    if (data.containsKey('original_image_data')) {
      context.handle(
          _originalImageDataMeta,
          originalImageData.isAcceptableOrUnknown(
              data['original_image_data']!, _originalImageDataMeta));
    }
    if (data.containsKey('resized_image_data')) {
      context.handle(
          _resizedImageDataMeta,
          resizedImageData.isAcceptableOrUnknown(
              data['resized_image_data']!, _resizedImageDataMeta));
    }
    if (data.containsKey('original_image_width')) {
      context.handle(
          _originalImageWidthMeta,
          originalImageWidth.isAcceptableOrUnknown(
              data['original_image_width']!, _originalImageWidthMeta));
    }
    if (data.containsKey('original_image_height')) {
      context.handle(
          _originalImageHeightMeta,
          originalImageHeight.isAcceptableOrUnknown(
              data['original_image_height']!, _originalImageHeightMeta));
    }
    if (data.containsKey('filter_quality_index')) {
      context.handle(
          _filterQualityIndexMeta,
          filterQualityIndex.isAcceptableOrUnknown(
              data['filter_quality_index']!, _filterQualityIndexMeta));
    }
    if (data.containsKey('palette_id')) {
      context.handle(_paletteIdMeta,
          paletteId.isAcceptableOrUnknown(data['palette_id']!, _paletteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      imageData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}image_data'])!,
      thumbnailData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}thumbnail_data'])!,
      isConverted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_converted'])!,
      vectorObjects: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vector_objects'])!,
      imageWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}image_width']),
      imageHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}image_height']),
      uniqueColorCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unique_color_count']),
      originalImageData: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}original_image_data']),
      resizedImageData: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}resized_image_data']),
      originalImageWidth: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}original_image_width']),
      originalImageHeight: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}original_image_height']),
      filterQualityIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}filter_quality_index'])!,
      paletteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}palette_id']),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final Uint8List imageData;
  final Uint8List thumbnailData;
  final bool isConverted;
  final String vectorObjects;
  final double? imageWidth;
  final double? imageHeight;
  final int? uniqueColorCount;
  final Uint8List? originalImageData;
  final Uint8List? resizedImageData;
  final double? originalImageWidth;
  final double? originalImageHeight;
  final int filterQualityIndex;
  final int? paletteId;
  const Project(
      {required this.id,
      required this.name,
      required this.imageData,
      required this.thumbnailData,
      required this.isConverted,
      required this.vectorObjects,
      this.imageWidth,
      this.imageHeight,
      this.uniqueColorCount,
      this.originalImageData,
      this.resizedImageData,
      this.originalImageWidth,
      this.originalImageHeight,
      required this.filterQualityIndex,
      this.paletteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['image_data'] = Variable<Uint8List>(imageData);
    map['thumbnail_data'] = Variable<Uint8List>(thumbnailData);
    map['is_converted'] = Variable<bool>(isConverted);
    map['vector_objects'] = Variable<String>(vectorObjects);
    if (!nullToAbsent || imageWidth != null) {
      map['image_width'] = Variable<double>(imageWidth);
    }
    if (!nullToAbsent || imageHeight != null) {
      map['image_height'] = Variable<double>(imageHeight);
    }
    if (!nullToAbsent || uniqueColorCount != null) {
      map['unique_color_count'] = Variable<int>(uniqueColorCount);
    }
    if (!nullToAbsent || originalImageData != null) {
      map['original_image_data'] = Variable<Uint8List>(originalImageData);
    }
    if (!nullToAbsent || resizedImageData != null) {
      map['resized_image_data'] = Variable<Uint8List>(resizedImageData);
    }
    if (!nullToAbsent || originalImageWidth != null) {
      map['original_image_width'] = Variable<double>(originalImageWidth);
    }
    if (!nullToAbsent || originalImageHeight != null) {
      map['original_image_height'] = Variable<double>(originalImageHeight);
    }
    map['filter_quality_index'] = Variable<int>(filterQualityIndex);
    if (!nullToAbsent || paletteId != null) {
      map['palette_id'] = Variable<int>(paletteId);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      imageData: Value(imageData),
      thumbnailData: Value(thumbnailData),
      isConverted: Value(isConverted),
      vectorObjects: Value(vectorObjects),
      imageWidth: imageWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(imageWidth),
      imageHeight: imageHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(imageHeight),
      uniqueColorCount: uniqueColorCount == null && nullToAbsent
          ? const Value.absent()
          : Value(uniqueColorCount),
      originalImageData: originalImageData == null && nullToAbsent
          ? const Value.absent()
          : Value(originalImageData),
      resizedImageData: resizedImageData == null && nullToAbsent
          ? const Value.absent()
          : Value(resizedImageData),
      originalImageWidth: originalImageWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(originalImageWidth),
      originalImageHeight: originalImageHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(originalImageHeight),
      filterQualityIndex: Value(filterQualityIndex),
      paletteId: paletteId == null && nullToAbsent
          ? const Value.absent()
          : Value(paletteId),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageData: serializer.fromJson<Uint8List>(json['imageData']),
      thumbnailData: serializer.fromJson<Uint8List>(json['thumbnailData']),
      isConverted: serializer.fromJson<bool>(json['isConverted']),
      vectorObjects: serializer.fromJson<String>(json['vectorObjects']),
      imageWidth: serializer.fromJson<double?>(json['imageWidth']),
      imageHeight: serializer.fromJson<double?>(json['imageHeight']),
      uniqueColorCount: serializer.fromJson<int?>(json['uniqueColorCount']),
      originalImageData:
          serializer.fromJson<Uint8List?>(json['originalImageData']),
      resizedImageData:
          serializer.fromJson<Uint8List?>(json['resizedImageData']),
      originalImageWidth:
          serializer.fromJson<double?>(json['originalImageWidth']),
      originalImageHeight:
          serializer.fromJson<double?>(json['originalImageHeight']),
      filterQualityIndex: serializer.fromJson<int>(json['filterQualityIndex']),
      paletteId: serializer.fromJson<int?>(json['paletteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageData': serializer.toJson<Uint8List>(imageData),
      'thumbnailData': serializer.toJson<Uint8List>(thumbnailData),
      'isConverted': serializer.toJson<bool>(isConverted),
      'vectorObjects': serializer.toJson<String>(vectorObjects),
      'imageWidth': serializer.toJson<double?>(imageWidth),
      'imageHeight': serializer.toJson<double?>(imageHeight),
      'uniqueColorCount': serializer.toJson<int?>(uniqueColorCount),
      'originalImageData': serializer.toJson<Uint8List?>(originalImageData),
      'resizedImageData': serializer.toJson<Uint8List?>(resizedImageData),
      'originalImageWidth': serializer.toJson<double?>(originalImageWidth),
      'originalImageHeight': serializer.toJson<double?>(originalImageHeight),
      'filterQualityIndex': serializer.toJson<int>(filterQualityIndex),
      'paletteId': serializer.toJson<int?>(paletteId),
    };
  }

  Project copyWith(
          {int? id,
          String? name,
          Uint8List? imageData,
          Uint8List? thumbnailData,
          bool? isConverted,
          String? vectorObjects,
          Value<double?> imageWidth = const Value.absent(),
          Value<double?> imageHeight = const Value.absent(),
          Value<int?> uniqueColorCount = const Value.absent(),
          Value<Uint8List?> originalImageData = const Value.absent(),
          Value<Uint8List?> resizedImageData = const Value.absent(),
          Value<double?> originalImageWidth = const Value.absent(),
          Value<double?> originalImageHeight = const Value.absent(),
          int? filterQualityIndex,
          Value<int?> paletteId = const Value.absent()}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        imageData: imageData ?? this.imageData,
        thumbnailData: thumbnailData ?? this.thumbnailData,
        isConverted: isConverted ?? this.isConverted,
        vectorObjects: vectorObjects ?? this.vectorObjects,
        imageWidth: imageWidth.present ? imageWidth.value : this.imageWidth,
        imageHeight: imageHeight.present ? imageHeight.value : this.imageHeight,
        uniqueColorCount: uniqueColorCount.present
            ? uniqueColorCount.value
            : this.uniqueColorCount,
        originalImageData: originalImageData.present
            ? originalImageData.value
            : this.originalImageData,
        resizedImageData: resizedImageData.present
            ? resizedImageData.value
            : this.resizedImageData,
        originalImageWidth: originalImageWidth.present
            ? originalImageWidth.value
            : this.originalImageWidth,
        originalImageHeight: originalImageHeight.present
            ? originalImageHeight.value
            : this.originalImageHeight,
        filterQualityIndex: filterQualityIndex ?? this.filterQualityIndex,
        paletteId: paletteId.present ? paletteId.value : this.paletteId,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageData: data.imageData.present ? data.imageData.value : this.imageData,
      thumbnailData: data.thumbnailData.present
          ? data.thumbnailData.value
          : this.thumbnailData,
      isConverted:
          data.isConverted.present ? data.isConverted.value : this.isConverted,
      vectorObjects: data.vectorObjects.present
          ? data.vectorObjects.value
          : this.vectorObjects,
      imageWidth:
          data.imageWidth.present ? data.imageWidth.value : this.imageWidth,
      imageHeight:
          data.imageHeight.present ? data.imageHeight.value : this.imageHeight,
      uniqueColorCount: data.uniqueColorCount.present
          ? data.uniqueColorCount.value
          : this.uniqueColorCount,
      originalImageData: data.originalImageData.present
          ? data.originalImageData.value
          : this.originalImageData,
      resizedImageData: data.resizedImageData.present
          ? data.resizedImageData.value
          : this.resizedImageData,
      originalImageWidth: data.originalImageWidth.present
          ? data.originalImageWidth.value
          : this.originalImageWidth,
      originalImageHeight: data.originalImageHeight.present
          ? data.originalImageHeight.value
          : this.originalImageHeight,
      filterQualityIndex: data.filterQualityIndex.present
          ? data.filterQualityIndex.value
          : this.filterQualityIndex,
      paletteId: data.paletteId.present ? data.paletteId.value : this.paletteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageData: $imageData, ')
          ..write('thumbnailData: $thumbnailData, ')
          ..write('isConverted: $isConverted, ')
          ..write('vectorObjects: $vectorObjects, ')
          ..write('imageWidth: $imageWidth, ')
          ..write('imageHeight: $imageHeight, ')
          ..write('uniqueColorCount: $uniqueColorCount, ')
          ..write('originalImageData: $originalImageData, ')
          ..write('resizedImageData: $resizedImageData, ')
          ..write('originalImageWidth: $originalImageWidth, ')
          ..write('originalImageHeight: $originalImageHeight, ')
          ..write('filterQualityIndex: $filterQualityIndex, ')
          ..write('paletteId: $paletteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      $driftBlobEquality.hash(imageData),
      $driftBlobEquality.hash(thumbnailData),
      isConverted,
      vectorObjects,
      imageWidth,
      imageHeight,
      uniqueColorCount,
      $driftBlobEquality.hash(originalImageData),
      $driftBlobEquality.hash(resizedImageData),
      originalImageWidth,
      originalImageHeight,
      filterQualityIndex,
      paletteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.imageData, this.imageData) &&
          $driftBlobEquality.equals(other.thumbnailData, this.thumbnailData) &&
          other.isConverted == this.isConverted &&
          other.vectorObjects == this.vectorObjects &&
          other.imageWidth == this.imageWidth &&
          other.imageHeight == this.imageHeight &&
          other.uniqueColorCount == this.uniqueColorCount &&
          $driftBlobEquality.equals(
              other.originalImageData, this.originalImageData) &&
          $driftBlobEquality.equals(
              other.resizedImageData, this.resizedImageData) &&
          other.originalImageWidth == this.originalImageWidth &&
          other.originalImageHeight == this.originalImageHeight &&
          other.filterQualityIndex == this.filterQualityIndex &&
          other.paletteId == this.paletteId);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<Uint8List> imageData;
  final Value<Uint8List> thumbnailData;
  final Value<bool> isConverted;
  final Value<String> vectorObjects;
  final Value<double?> imageWidth;
  final Value<double?> imageHeight;
  final Value<int?> uniqueColorCount;
  final Value<Uint8List?> originalImageData;
  final Value<Uint8List?> resizedImageData;
  final Value<double?> originalImageWidth;
  final Value<double?> originalImageHeight;
  final Value<int> filterQualityIndex;
  final Value<int?> paletteId;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageData = const Value.absent(),
    this.thumbnailData = const Value.absent(),
    this.isConverted = const Value.absent(),
    this.vectorObjects = const Value.absent(),
    this.imageWidth = const Value.absent(),
    this.imageHeight = const Value.absent(),
    this.uniqueColorCount = const Value.absent(),
    this.originalImageData = const Value.absent(),
    this.resizedImageData = const Value.absent(),
    this.originalImageWidth = const Value.absent(),
    this.originalImageHeight = const Value.absent(),
    this.filterQualityIndex = const Value.absent(),
    this.paletteId = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Uint8List imageData,
    required Uint8List thumbnailData,
    this.isConverted = const Value.absent(),
    this.vectorObjects = const Value.absent(),
    this.imageWidth = const Value.absent(),
    this.imageHeight = const Value.absent(),
    this.uniqueColorCount = const Value.absent(),
    this.originalImageData = const Value.absent(),
    this.resizedImageData = const Value.absent(),
    this.originalImageWidth = const Value.absent(),
    this.originalImageHeight = const Value.absent(),
    this.filterQualityIndex = const Value.absent(),
    this.paletteId = const Value.absent(),
  })  : name = Value(name),
        imageData = Value(imageData),
        thumbnailData = Value(thumbnailData);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<Uint8List>? imageData,
    Expression<Uint8List>? thumbnailData,
    Expression<bool>? isConverted,
    Expression<String>? vectorObjects,
    Expression<double>? imageWidth,
    Expression<double>? imageHeight,
    Expression<int>? uniqueColorCount,
    Expression<Uint8List>? originalImageData,
    Expression<Uint8List>? resizedImageData,
    Expression<double>? originalImageWidth,
    Expression<double>? originalImageHeight,
    Expression<int>? filterQualityIndex,
    Expression<int>? paletteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageData != null) 'image_data': imageData,
      if (thumbnailData != null) 'thumbnail_data': thumbnailData,
      if (isConverted != null) 'is_converted': isConverted,
      if (vectorObjects != null) 'vector_objects': vectorObjects,
      if (imageWidth != null) 'image_width': imageWidth,
      if (imageHeight != null) 'image_height': imageHeight,
      if (uniqueColorCount != null) 'unique_color_count': uniqueColorCount,
      if (originalImageData != null) 'original_image_data': originalImageData,
      if (resizedImageData != null) 'resized_image_data': resizedImageData,
      if (originalImageWidth != null)
        'original_image_width': originalImageWidth,
      if (originalImageHeight != null)
        'original_image_height': originalImageHeight,
      if (filterQualityIndex != null)
        'filter_quality_index': filterQualityIndex,
      if (paletteId != null) 'palette_id': paletteId,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<Uint8List>? imageData,
      Value<Uint8List>? thumbnailData,
      Value<bool>? isConverted,
      Value<String>? vectorObjects,
      Value<double?>? imageWidth,
      Value<double?>? imageHeight,
      Value<int?>? uniqueColorCount,
      Value<Uint8List?>? originalImageData,
      Value<Uint8List?>? resizedImageData,
      Value<double?>? originalImageWidth,
      Value<double?>? originalImageHeight,
      Value<int>? filterQualityIndex,
      Value<int?>? paletteId}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageData: imageData ?? this.imageData,
      thumbnailData: thumbnailData ?? this.thumbnailData,
      isConverted: isConverted ?? this.isConverted,
      vectorObjects: vectorObjects ?? this.vectorObjects,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      uniqueColorCount: uniqueColorCount ?? this.uniqueColorCount,
      originalImageData: originalImageData ?? this.originalImageData,
      resizedImageData: resizedImageData ?? this.resizedImageData,
      originalImageWidth: originalImageWidth ?? this.originalImageWidth,
      originalImageHeight: originalImageHeight ?? this.originalImageHeight,
      filterQualityIndex: filterQualityIndex ?? this.filterQualityIndex,
      paletteId: paletteId ?? this.paletteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageData.present) {
      map['image_data'] = Variable<Uint8List>(imageData.value);
    }
    if (thumbnailData.present) {
      map['thumbnail_data'] = Variable<Uint8List>(thumbnailData.value);
    }
    if (isConverted.present) {
      map['is_converted'] = Variable<bool>(isConverted.value);
    }
    if (vectorObjects.present) {
      map['vector_objects'] = Variable<String>(vectorObjects.value);
    }
    if (imageWidth.present) {
      map['image_width'] = Variable<double>(imageWidth.value);
    }
    if (imageHeight.present) {
      map['image_height'] = Variable<double>(imageHeight.value);
    }
    if (uniqueColorCount.present) {
      map['unique_color_count'] = Variable<int>(uniqueColorCount.value);
    }
    if (originalImageData.present) {
      map['original_image_data'] = Variable<Uint8List>(originalImageData.value);
    }
    if (resizedImageData.present) {
      map['resized_image_data'] = Variable<Uint8List>(resizedImageData.value);
    }
    if (originalImageWidth.present) {
      map['original_image_width'] = Variable<double>(originalImageWidth.value);
    }
    if (originalImageHeight.present) {
      map['original_image_height'] =
          Variable<double>(originalImageHeight.value);
    }
    if (filterQualityIndex.present) {
      map['filter_quality_index'] = Variable<int>(filterQualityIndex.value);
    }
    if (paletteId.present) {
      map['palette_id'] = Variable<int>(paletteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageData: $imageData, ')
          ..write('thumbnailData: $thumbnailData, ')
          ..write('isConverted: $isConverted, ')
          ..write('vectorObjects: $vectorObjects, ')
          ..write('imageWidth: $imageWidth, ')
          ..write('imageHeight: $imageHeight, ')
          ..write('uniqueColorCount: $uniqueColorCount, ')
          ..write('originalImageData: $originalImageData, ')
          ..write('resizedImageData: $resizedImageData, ')
          ..write('originalImageWidth: $originalImageWidth, ')
          ..write('originalImageHeight: $originalImageHeight, ')
          ..write('filterQualityIndex: $filterQualityIndex, ')
          ..write('paletteId: $paletteId')
          ..write(')'))
        .toString();
  }
}

class $PaletteColorsTable extends PaletteColors
    with TableInfo<$PaletteColorsTable, PaletteColor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaletteColorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _paletteIdMeta =
      const VerificationMeta('paletteId');
  @override
  late final GeneratedColumn<int> paletteId = GeneratedColumn<int>(
      'palette_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES palettes (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, paletteId, title, color, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'palette_colors';
  @override
  VerificationContext validateIntegrity(Insertable<PaletteColor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('palette_id')) {
      context.handle(_paletteIdMeta,
          paletteId.isAcceptableOrUnknown(data['palette_id']!, _paletteIdMeta));
    } else if (isInserting) {
      context.missing(_paletteIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaletteColor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaletteColor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      paletteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}palette_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $PaletteColorsTable createAlias(String alias) {
    return $PaletteColorsTable(attachedDatabase, alias);
  }
}

class PaletteColor extends DataClass implements Insertable<PaletteColor> {
  final int id;
  final int paletteId;
  final String title;
  final int color;
  final String status;
  const PaletteColor(
      {required this.id,
      required this.paletteId,
      required this.title,
      required this.color,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['palette_id'] = Variable<int>(paletteId);
    map['title'] = Variable<String>(title);
    map['color'] = Variable<int>(color);
    map['status'] = Variable<String>(status);
    return map;
  }

  PaletteColorsCompanion toCompanion(bool nullToAbsent) {
    return PaletteColorsCompanion(
      id: Value(id),
      paletteId: Value(paletteId),
      title: Value(title),
      color: Value(color),
      status: Value(status),
    );
  }

  factory PaletteColor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaletteColor(
      id: serializer.fromJson<int>(json['id']),
      paletteId: serializer.fromJson<int>(json['paletteId']),
      title: serializer.fromJson<String>(json['title']),
      color: serializer.fromJson<int>(json['color']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paletteId': serializer.toJson<int>(paletteId),
      'title': serializer.toJson<String>(title),
      'color': serializer.toJson<int>(color),
      'status': serializer.toJson<String>(status),
    };
  }

  PaletteColor copyWith(
          {int? id,
          int? paletteId,
          String? title,
          int? color,
          String? status}) =>
      PaletteColor(
        id: id ?? this.id,
        paletteId: paletteId ?? this.paletteId,
        title: title ?? this.title,
        color: color ?? this.color,
        status: status ?? this.status,
      );
  PaletteColor copyWithCompanion(PaletteColorsCompanion data) {
    return PaletteColor(
      id: data.id.present ? data.id.value : this.id,
      paletteId: data.paletteId.present ? data.paletteId.value : this.paletteId,
      title: data.title.present ? data.title.value : this.title,
      color: data.color.present ? data.color.value : this.color,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaletteColor(')
          ..write('id: $id, ')
          ..write('paletteId: $paletteId, ')
          ..write('title: $title, ')
          ..write('color: $color, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, paletteId, title, color, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaletteColor &&
          other.id == this.id &&
          other.paletteId == this.paletteId &&
          other.title == this.title &&
          other.color == this.color &&
          other.status == this.status);
}

class PaletteColorsCompanion extends UpdateCompanion<PaletteColor> {
  final Value<int> id;
  final Value<int> paletteId;
  final Value<String> title;
  final Value<int> color;
  final Value<String> status;
  const PaletteColorsCompanion({
    this.id = const Value.absent(),
    this.paletteId = const Value.absent(),
    this.title = const Value.absent(),
    this.color = const Value.absent(),
    this.status = const Value.absent(),
  });
  PaletteColorsCompanion.insert({
    this.id = const Value.absent(),
    required int paletteId,
    required String title,
    required int color,
    this.status = const Value.absent(),
  })  : paletteId = Value(paletteId),
        title = Value(title),
        color = Value(color);
  static Insertable<PaletteColor> custom({
    Expression<int>? id,
    Expression<int>? paletteId,
    Expression<String>? title,
    Expression<int>? color,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paletteId != null) 'palette_id': paletteId,
      if (title != null) 'title': title,
      if (color != null) 'color': color,
      if (status != null) 'status': status,
    });
  }

  PaletteColorsCompanion copyWith(
      {Value<int>? id,
      Value<int>? paletteId,
      Value<String>? title,
      Value<int>? color,
      Value<String>? status}) {
    return PaletteColorsCompanion(
      id: id ?? this.id,
      paletteId: paletteId ?? this.paletteId,
      title: title ?? this.title,
      color: color ?? this.color,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paletteId.present) {
      map['palette_id'] = Variable<int>(paletteId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaletteColorsCompanion(')
          ..write('id: $id, ')
          ..write('paletteId: $paletteId, ')
          ..write('title: $title, ')
          ..write('color: $color, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $VendorColorsTable extends VendorColors
    with TableInfo<$VendorColorsTable, VendorColor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorColorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _weightInGramsMeta =
      const VerificationMeta('weightInGrams');
  @override
  late final GeneratedColumn<double> weightInGrams = GeneratedColumn<double>(
      'weight_in_grams', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _colorDensityMeta =
      const VerificationMeta('colorDensity');
  @override
  late final GeneratedColumn<double> colorDensity = GeneratedColumn<double>(
      'color_density', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, code, imageUrl, weightInGrams, colorDensity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendor_colors';
  @override
  VerificationContext validateIntegrity(Insertable<VendorColor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('weight_in_grams')) {
      context.handle(
          _weightInGramsMeta,
          weightInGrams.isAcceptableOrUnknown(
              data['weight_in_grams']!, _weightInGramsMeta));
    }
    if (data.containsKey('color_density')) {
      context.handle(
          _colorDensityMeta,
          colorDensity.isAcceptableOrUnknown(
              data['color_density']!, _colorDensityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VendorColor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VendorColor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      weightInGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_in_grams']),
      colorDensity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}color_density']),
    );
  }

  @override
  $VendorColorsTable createAlias(String alias) {
    return $VendorColorsTable(attachedDatabase, alias);
  }
}

class VendorColor extends DataClass implements Insertable<VendorColor> {
  final int id;
  final String name;
  final String code;
  final String imageUrl;
  final double? weightInGrams;
  final double? colorDensity;
  const VendorColor(
      {required this.id,
      required this.name,
      required this.code,
      required this.imageUrl,
      this.weightInGrams,
      this.colorDensity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['image_url'] = Variable<String>(imageUrl);
    if (!nullToAbsent || weightInGrams != null) {
      map['weight_in_grams'] = Variable<double>(weightInGrams);
    }
    if (!nullToAbsent || colorDensity != null) {
      map['color_density'] = Variable<double>(colorDensity);
    }
    return map;
  }

  VendorColorsCompanion toCompanion(bool nullToAbsent) {
    return VendorColorsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      imageUrl: Value(imageUrl),
      weightInGrams: weightInGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(weightInGrams),
      colorDensity: colorDensity == null && nullToAbsent
          ? const Value.absent()
          : Value(colorDensity),
    );
  }

  factory VendorColor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VendorColor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      weightInGrams: serializer.fromJson<double?>(json['weightInGrams']),
      colorDensity: serializer.fromJson<double?>(json['colorDensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'weightInGrams': serializer.toJson<double?>(weightInGrams),
      'colorDensity': serializer.toJson<double?>(colorDensity),
    };
  }

  VendorColor copyWith(
          {int? id,
          String? name,
          String? code,
          String? imageUrl,
          Value<double?> weightInGrams = const Value.absent(),
          Value<double?> colorDensity = const Value.absent()}) =>
      VendorColor(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        imageUrl: imageUrl ?? this.imageUrl,
        weightInGrams:
            weightInGrams.present ? weightInGrams.value : this.weightInGrams,
        colorDensity:
            colorDensity.present ? colorDensity.value : this.colorDensity,
      );
  VendorColor copyWithCompanion(VendorColorsCompanion data) {
    return VendorColor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      weightInGrams: data.weightInGrams.present
          ? data.weightInGrams.value
          : this.weightInGrams,
      colorDensity: data.colorDensity.present
          ? data.colorDensity.value
          : this.colorDensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VendorColor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('weightInGrams: $weightInGrams, ')
          ..write('colorDensity: $colorDensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, code, imageUrl, weightInGrams, colorDensity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VendorColor &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.imageUrl == this.imageUrl &&
          other.weightInGrams == this.weightInGrams &&
          other.colorDensity == this.colorDensity);
}

class VendorColorsCompanion extends UpdateCompanion<VendorColor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String> imageUrl;
  final Value<double?> weightInGrams;
  final Value<double?> colorDensity;
  const VendorColorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.weightInGrams = const Value.absent(),
    this.colorDensity = const Value.absent(),
  });
  VendorColorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String code,
    this.imageUrl = const Value.absent(),
    this.weightInGrams = const Value.absent(),
    this.colorDensity = const Value.absent(),
  })  : name = Value(name),
        code = Value(code);
  static Insertable<VendorColor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? imageUrl,
    Expression<double>? weightInGrams,
    Expression<double>? colorDensity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (imageUrl != null) 'image_url': imageUrl,
      if (weightInGrams != null) 'weight_in_grams': weightInGrams,
      if (colorDensity != null) 'color_density': colorDensity,
    });
  }

  VendorColorsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? code,
      Value<String>? imageUrl,
      Value<double?>? weightInGrams,
      Value<double?>? colorDensity}) {
    return VendorColorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      imageUrl: imageUrl ?? this.imageUrl,
      weightInGrams: weightInGrams ?? this.weightInGrams,
      colorDensity: colorDensity ?? this.colorDensity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (weightInGrams.present) {
      map['weight_in_grams'] = Variable<double>(weightInGrams.value);
    }
    if (colorDensity.present) {
      map['color_density'] = Variable<double>(colorDensity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorColorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('weightInGrams: $weightInGrams, ')
          ..write('colorDensity: $colorDensity')
          ..write(')'))
        .toString();
  }
}

class $VendorColorVariantsTable extends VendorColorVariants
    with TableInfo<$VendorColorVariantsTable, VendorColorVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorColorVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vendorColorIdMeta =
      const VerificationMeta('vendorColorId');
  @override
  late final GeneratedColumn<int> vendorColorId = GeneratedColumn<int>(
      'vendor_color_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vendor_colors (id)'));
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _weightInGramsMeta =
      const VerificationMeta('weightInGrams');
  @override
  late final GeneratedColumn<double> weightInGrams = GeneratedColumn<double>(
      'weight_in_grams', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vendorColorId, size, stock, weightInGrams];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendor_color_variants';
  @override
  VerificationContext validateIntegrity(Insertable<VendorColorVariant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vendor_color_id')) {
      context.handle(
          _vendorColorIdMeta,
          vendorColorId.isAcceptableOrUnknown(
              data['vendor_color_id']!, _vendorColorIdMeta));
    } else if (isInserting) {
      context.missing(_vendorColorIdMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('weight_in_grams')) {
      context.handle(
          _weightInGramsMeta,
          weightInGrams.isAcceptableOrUnknown(
              data['weight_in_grams']!, _weightInGramsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VendorColorVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VendorColorVariant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vendorColorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_color_id'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size'])!,
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      weightInGrams: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_in_grams']),
    );
  }

  @override
  $VendorColorVariantsTable createAlias(String alias) {
    return $VendorColorVariantsTable(attachedDatabase, alias);
  }
}

class VendorColorVariant extends DataClass
    implements Insertable<VendorColorVariant> {
  final int id;
  final int vendorColorId;
  final int size;
  final int stock;
  final double? weightInGrams;
  const VendorColorVariant(
      {required this.id,
      required this.vendorColorId,
      required this.size,
      required this.stock,
      this.weightInGrams});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vendor_color_id'] = Variable<int>(vendorColorId);
    map['size'] = Variable<int>(size);
    map['stock'] = Variable<int>(stock);
    if (!nullToAbsent || weightInGrams != null) {
      map['weight_in_grams'] = Variable<double>(weightInGrams);
    }
    return map;
  }

  VendorColorVariantsCompanion toCompanion(bool nullToAbsent) {
    return VendorColorVariantsCompanion(
      id: Value(id),
      vendorColorId: Value(vendorColorId),
      size: Value(size),
      stock: Value(stock),
      weightInGrams: weightInGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(weightInGrams),
    );
  }

  factory VendorColorVariant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VendorColorVariant(
      id: serializer.fromJson<int>(json['id']),
      vendorColorId: serializer.fromJson<int>(json['vendorColorId']),
      size: serializer.fromJson<int>(json['size']),
      stock: serializer.fromJson<int>(json['stock']),
      weightInGrams: serializer.fromJson<double?>(json['weightInGrams']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorColorId': serializer.toJson<int>(vendorColorId),
      'size': serializer.toJson<int>(size),
      'stock': serializer.toJson<int>(stock),
      'weightInGrams': serializer.toJson<double?>(weightInGrams),
    };
  }

  VendorColorVariant copyWith(
          {int? id,
          int? vendorColorId,
          int? size,
          int? stock,
          Value<double?> weightInGrams = const Value.absent()}) =>
      VendorColorVariant(
        id: id ?? this.id,
        vendorColorId: vendorColorId ?? this.vendorColorId,
        size: size ?? this.size,
        stock: stock ?? this.stock,
        weightInGrams:
            weightInGrams.present ? weightInGrams.value : this.weightInGrams,
      );
  VendorColorVariant copyWithCompanion(VendorColorVariantsCompanion data) {
    return VendorColorVariant(
      id: data.id.present ? data.id.value : this.id,
      vendorColorId: data.vendorColorId.present
          ? data.vendorColorId.value
          : this.vendorColorId,
      size: data.size.present ? data.size.value : this.size,
      stock: data.stock.present ? data.stock.value : this.stock,
      weightInGrams: data.weightInGrams.present
          ? data.weightInGrams.value
          : this.weightInGrams,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VendorColorVariant(')
          ..write('id: $id, ')
          ..write('vendorColorId: $vendorColorId, ')
          ..write('size: $size, ')
          ..write('stock: $stock, ')
          ..write('weightInGrams: $weightInGrams')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vendorColorId, size, stock, weightInGrams);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VendorColorVariant &&
          other.id == this.id &&
          other.vendorColorId == this.vendorColorId &&
          other.size == this.size &&
          other.stock == this.stock &&
          other.weightInGrams == this.weightInGrams);
}

class VendorColorVariantsCompanion extends UpdateCompanion<VendorColorVariant> {
  final Value<int> id;
  final Value<int> vendorColorId;
  final Value<int> size;
  final Value<int> stock;
  final Value<double?> weightInGrams;
  const VendorColorVariantsCompanion({
    this.id = const Value.absent(),
    this.vendorColorId = const Value.absent(),
    this.size = const Value.absent(),
    this.stock = const Value.absent(),
    this.weightInGrams = const Value.absent(),
  });
  VendorColorVariantsCompanion.insert({
    this.id = const Value.absent(),
    required int vendorColorId,
    required int size,
    this.stock = const Value.absent(),
    this.weightInGrams = const Value.absent(),
  })  : vendorColorId = Value(vendorColorId),
        size = Value(size);
  static Insertable<VendorColorVariant> custom({
    Expression<int>? id,
    Expression<int>? vendorColorId,
    Expression<int>? size,
    Expression<int>? stock,
    Expression<double>? weightInGrams,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorColorId != null) 'vendor_color_id': vendorColorId,
      if (size != null) 'size': size,
      if (stock != null) 'stock': stock,
      if (weightInGrams != null) 'weight_in_grams': weightInGrams,
    });
  }

  VendorColorVariantsCompanion copyWith(
      {Value<int>? id,
      Value<int>? vendorColorId,
      Value<int>? size,
      Value<int>? stock,
      Value<double?>? weightInGrams}) {
    return VendorColorVariantsCompanion(
      id: id ?? this.id,
      vendorColorId: vendorColorId ?? this.vendorColorId,
      size: size ?? this.size,
      stock: stock ?? this.stock,
      weightInGrams: weightInGrams ?? this.weightInGrams,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorColorId.present) {
      map['vendor_color_id'] = Variable<int>(vendorColorId.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (weightInGrams.present) {
      map['weight_in_grams'] = Variable<double>(weightInGrams.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorColorVariantsCompanion(')
          ..write('id: $id, ')
          ..write('vendorColorId: $vendorColorId, ')
          ..write('size: $size, ')
          ..write('stock: $stock, ')
          ..write('weightInGrams: $weightInGrams')
          ..write(')'))
        .toString();
  }
}

class $ColorComponentsTable extends ColorComponents
    with TableInfo<$ColorComponentsTable, ColorComponent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColorComponentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _paletteColorIdMeta =
      const VerificationMeta('paletteColorId');
  @override
  late final GeneratedColumn<int> paletteColorId = GeneratedColumn<int>(
      'palette_color_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES palette_colors (id)'));
  static const VerificationMeta _vendorColorIdMeta =
      const VerificationMeta('vendorColorId');
  @override
  late final GeneratedColumn<int> vendorColorId = GeneratedColumn<int>(
      'vendor_color_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vendor_colors (id)'));
  static const VerificationMeta _percentageMeta =
      const VerificationMeta('percentage');
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
      'percentage', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, paletteColorId, vendorColorId, percentage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'color_components';
  @override
  VerificationContext validateIntegrity(Insertable<ColorComponent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('palette_color_id')) {
      context.handle(
          _paletteColorIdMeta,
          paletteColorId.isAcceptableOrUnknown(
              data['palette_color_id']!, _paletteColorIdMeta));
    } else if (isInserting) {
      context.missing(_paletteColorIdMeta);
    }
    if (data.containsKey('vendor_color_id')) {
      context.handle(
          _vendorColorIdMeta,
          vendorColorId.isAcceptableOrUnknown(
              data['vendor_color_id']!, _vendorColorIdMeta));
    } else if (isInserting) {
      context.missing(_vendorColorIdMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
          _percentageMeta,
          percentage.isAcceptableOrUnknown(
              data['percentage']!, _percentageMeta));
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ColorComponent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColorComponent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      paletteColorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}palette_color_id'])!,
      vendorColorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_color_id'])!,
      percentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percentage'])!,
    );
  }

  @override
  $ColorComponentsTable createAlias(String alias) {
    return $ColorComponentsTable(attachedDatabase, alias);
  }
}

class ColorComponent extends DataClass implements Insertable<ColorComponent> {
  final int id;
  final int paletteColorId;
  final int vendorColorId;
  final double percentage;
  const ColorComponent(
      {required this.id,
      required this.paletteColorId,
      required this.vendorColorId,
      required this.percentage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['palette_color_id'] = Variable<int>(paletteColorId);
    map['vendor_color_id'] = Variable<int>(vendorColorId);
    map['percentage'] = Variable<double>(percentage);
    return map;
  }

  ColorComponentsCompanion toCompanion(bool nullToAbsent) {
    return ColorComponentsCompanion(
      id: Value(id),
      paletteColorId: Value(paletteColorId),
      vendorColorId: Value(vendorColorId),
      percentage: Value(percentage),
    );
  }

  factory ColorComponent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColorComponent(
      id: serializer.fromJson<int>(json['id']),
      paletteColorId: serializer.fromJson<int>(json['paletteColorId']),
      vendorColorId: serializer.fromJson<int>(json['vendorColorId']),
      percentage: serializer.fromJson<double>(json['percentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paletteColorId': serializer.toJson<int>(paletteColorId),
      'vendorColorId': serializer.toJson<int>(vendorColorId),
      'percentage': serializer.toJson<double>(percentage),
    };
  }

  ColorComponent copyWith(
          {int? id,
          int? paletteColorId,
          int? vendorColorId,
          double? percentage}) =>
      ColorComponent(
        id: id ?? this.id,
        paletteColorId: paletteColorId ?? this.paletteColorId,
        vendorColorId: vendorColorId ?? this.vendorColorId,
        percentage: percentage ?? this.percentage,
      );
  ColorComponent copyWithCompanion(ColorComponentsCompanion data) {
    return ColorComponent(
      id: data.id.present ? data.id.value : this.id,
      paletteColorId: data.paletteColorId.present
          ? data.paletteColorId.value
          : this.paletteColorId,
      vendorColorId: data.vendorColorId.present
          ? data.vendorColorId.value
          : this.vendorColorId,
      percentage:
          data.percentage.present ? data.percentage.value : this.percentage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColorComponent(')
          ..write('id: $id, ')
          ..write('paletteColorId: $paletteColorId, ')
          ..write('vendorColorId: $vendorColorId, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, paletteColorId, vendorColorId, percentage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColorComponent &&
          other.id == this.id &&
          other.paletteColorId == this.paletteColorId &&
          other.vendorColorId == this.vendorColorId &&
          other.percentage == this.percentage);
}

class ColorComponentsCompanion extends UpdateCompanion<ColorComponent> {
  final Value<int> id;
  final Value<int> paletteColorId;
  final Value<int> vendorColorId;
  final Value<double> percentage;
  const ColorComponentsCompanion({
    this.id = const Value.absent(),
    this.paletteColorId = const Value.absent(),
    this.vendorColorId = const Value.absent(),
    this.percentage = const Value.absent(),
  });
  ColorComponentsCompanion.insert({
    this.id = const Value.absent(),
    required int paletteColorId,
    required int vendorColorId,
    required double percentage,
  })  : paletteColorId = Value(paletteColorId),
        vendorColorId = Value(vendorColorId),
        percentage = Value(percentage);
  static Insertable<ColorComponent> custom({
    Expression<int>? id,
    Expression<int>? paletteColorId,
    Expression<int>? vendorColorId,
    Expression<double>? percentage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paletteColorId != null) 'palette_color_id': paletteColorId,
      if (vendorColorId != null) 'vendor_color_id': vendorColorId,
      if (percentage != null) 'percentage': percentage,
    });
  }

  ColorComponentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? paletteColorId,
      Value<int>? vendorColorId,
      Value<double>? percentage}) {
    return ColorComponentsCompanion(
      id: id ?? this.id,
      paletteColorId: paletteColorId ?? this.paletteColorId,
      vendorColorId: vendorColorId ?? this.vendorColorId,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paletteColorId.present) {
      map['palette_color_id'] = Variable<int>(paletteColorId.value);
    }
    if (vendorColorId.present) {
      map['vendor_color_id'] = Variable<int>(vendorColorId.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColorComponentsCompanion(')
          ..write('id: $id, ')
          ..write('paletteColorId: $paletteColorId, ')
          ..write('vendorColorId: $vendorColorId, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PalettesTable palettes = $PalettesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $PaletteColorsTable paletteColors = $PaletteColorsTable(this);
  late final $VendorColorsTable vendorColors = $VendorColorsTable(this);
  late final $VendorColorVariantsTable vendorColorVariants =
      $VendorColorVariantsTable(this);
  late final $ColorComponentsTable colorComponents =
      $ColorComponentsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        palettes,
        projects,
        paletteColors,
        vendorColors,
        vendorColorVariants,
        colorComponents,
        settings
      ];
}

typedef $$PalettesTableCreateCompanionBuilder = PalettesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<double> sizeInMl,
  Value<double> factor,
  Value<Uint8List?> thumbnail,
  Value<bool> isPredefined,
});
typedef $$PalettesTableUpdateCompanionBuilder = PalettesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<double> sizeInMl,
  Value<double> factor,
  Value<Uint8List?> thumbnail,
  Value<bool> isPredefined,
});

final class $$PalettesTableReferences
    extends BaseReferences<_$AppDatabase, $PalettesTable, Palette> {
  $$PalettesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.projects,
          aliasName:
              $_aliasNameGenerator(db.palettes.id, db.projects.paletteId));

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.paletteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaletteColorsTable, List<PaletteColor>>
      _paletteColorsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.paletteColors,
              aliasName: $_aliasNameGenerator(
                  db.palettes.id, db.paletteColors.paletteId));

  $$PaletteColorsTableProcessedTableManager get paletteColorsRefs {
    final manager = $$PaletteColorsTableTableManager($_db, $_db.paletteColors)
        .filter((f) => f.paletteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paletteColorsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PalettesTableFilterComposer
    extends Composer<_$AppDatabase, $PalettesTable> {
  $$PalettesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sizeInMl => $composableBuilder(
      column: $table.sizeInMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get factor => $composableBuilder(
      column: $table.factor, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPredefined => $composableBuilder(
      column: $table.isPredefined, builder: (column) => ColumnFilters(column));

  Expression<bool> projectsRefs(
      Expression<bool> Function($$ProjectsTableFilterComposer f) f) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.paletteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paletteColorsRefs(
      Expression<bool> Function($$PaletteColorsTableFilterComposer f) f) {
    final $$PaletteColorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paletteColors,
        getReferencedColumn: (t) => t.paletteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaletteColorsTableFilterComposer(
              $db: $db,
              $table: $db.paletteColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PalettesTableOrderingComposer
    extends Composer<_$AppDatabase, $PalettesTable> {
  $$PalettesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sizeInMl => $composableBuilder(
      column: $table.sizeInMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get factor => $composableBuilder(
      column: $table.factor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPredefined => $composableBuilder(
      column: $table.isPredefined,
      builder: (column) => ColumnOrderings(column));
}

class $$PalettesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PalettesTable> {
  $$PalettesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get sizeInMl =>
      $composableBuilder(column: $table.sizeInMl, builder: (column) => column);

  GeneratedColumn<double> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<bool> get isPredefined => $composableBuilder(
      column: $table.isPredefined, builder: (column) => column);

  Expression<T> projectsRefs<T extends Object>(
      Expression<T> Function($$ProjectsTableAnnotationComposer a) f) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.paletteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paletteColorsRefs<T extends Object>(
      Expression<T> Function($$PaletteColorsTableAnnotationComposer a) f) {
    final $$PaletteColorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paletteColors,
        getReferencedColumn: (t) => t.paletteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaletteColorsTableAnnotationComposer(
              $db: $db,
              $table: $db.paletteColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PalettesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PalettesTable,
    Palette,
    $$PalettesTableFilterComposer,
    $$PalettesTableOrderingComposer,
    $$PalettesTableAnnotationComposer,
    $$PalettesTableCreateCompanionBuilder,
    $$PalettesTableUpdateCompanionBuilder,
    (Palette, $$PalettesTableReferences),
    Palette,
    PrefetchHooks Function({bool projectsRefs, bool paletteColorsRefs})> {
  $$PalettesTableTableManager(_$AppDatabase db, $PalettesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PalettesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PalettesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PalettesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> sizeInMl = const Value.absent(),
            Value<double> factor = const Value.absent(),
            Value<Uint8List?> thumbnail = const Value.absent(),
            Value<bool> isPredefined = const Value.absent(),
          }) =>
              PalettesCompanion(
            id: id,
            name: name,
            description: description,
            sizeInMl: sizeInMl,
            factor: factor,
            thumbnail: thumbnail,
            isPredefined: isPredefined,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<double> sizeInMl = const Value.absent(),
            Value<double> factor = const Value.absent(),
            Value<Uint8List?> thumbnail = const Value.absent(),
            Value<bool> isPredefined = const Value.absent(),
          }) =>
              PalettesCompanion.insert(
            id: id,
            name: name,
            description: description,
            sizeInMl: sizeInMl,
            factor: factor,
            thumbnail: thumbnail,
            isPredefined: isPredefined,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PalettesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {projectsRefs = false, paletteColorsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (projectsRefs) db.projects,
                if (paletteColorsRefs) db.paletteColors
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectsRefs)
                    await $_getPrefetchedData<Palette, $PalettesTable, Project>(
                        currentTable: table,
                        referencedTable:
                            $$PalettesTableReferences._projectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PalettesTableReferences(db, table, p0)
                                .projectsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paletteId == item.id),
                        typedResults: items),
                  if (paletteColorsRefs)
                    await $_getPrefetchedData<Palette, $PalettesTable,
                            PaletteColor>(
                        currentTable: table,
                        referencedTable: $$PalettesTableReferences
                            ._paletteColorsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PalettesTableReferences(db, table, p0)
                                .paletteColorsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paletteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PalettesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PalettesTable,
    Palette,
    $$PalettesTableFilterComposer,
    $$PalettesTableOrderingComposer,
    $$PalettesTableAnnotationComposer,
    $$PalettesTableCreateCompanionBuilder,
    $$PalettesTableUpdateCompanionBuilder,
    (Palette, $$PalettesTableReferences),
    Palette,
    PrefetchHooks Function({bool projectsRefs, bool paletteColorsRefs})>;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  required Uint8List imageData,
  required Uint8List thumbnailData,
  Value<bool> isConverted,
  Value<String> vectorObjects,
  Value<double?> imageWidth,
  Value<double?> imageHeight,
  Value<int?> uniqueColorCount,
  Value<Uint8List?> originalImageData,
  Value<Uint8List?> resizedImageData,
  Value<double?> originalImageWidth,
  Value<double?> originalImageHeight,
  Value<int> filterQualityIndex,
  Value<int?> paletteId,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<Uint8List> imageData,
  Value<Uint8List> thumbnailData,
  Value<bool> isConverted,
  Value<String> vectorObjects,
  Value<double?> imageWidth,
  Value<double?> imageHeight,
  Value<int?> uniqueColorCount,
  Value<Uint8List?> originalImageData,
  Value<Uint8List?> resizedImageData,
  Value<double?> originalImageWidth,
  Value<double?> originalImageHeight,
  Value<int> filterQualityIndex,
  Value<int?> paletteId,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PalettesTable _paletteIdTable(_$AppDatabase db) => db.palettes
      .createAlias($_aliasNameGenerator(db.projects.paletteId, db.palettes.id));

  $$PalettesTableProcessedTableManager? get paletteId {
    final $_column = $_itemColumn<int>('palette_id');
    if ($_column == null) return null;
    final manager = $$PalettesTableTableManager($_db, $_db.palettes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paletteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get thumbnailData => $composableBuilder(
      column: $table.thumbnailData, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isConverted => $composableBuilder(
      column: $table.isConverted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vectorObjects => $composableBuilder(
      column: $table.vectorObjects, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get imageWidth => $composableBuilder(
      column: $table.imageWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get imageHeight => $composableBuilder(
      column: $table.imageHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uniqueColorCount => $composableBuilder(
      column: $table.uniqueColorCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get originalImageData => $composableBuilder(
      column: $table.originalImageData,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get resizedImageData => $composableBuilder(
      column: $table.resizedImageData,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalImageWidth => $composableBuilder(
      column: $table.originalImageWidth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalImageHeight => $composableBuilder(
      column: $table.originalImageHeight,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get filterQualityIndex => $composableBuilder(
      column: $table.filterQualityIndex,
      builder: (column) => ColumnFilters(column));

  $$PalettesTableFilterComposer get paletteId {
    final $$PalettesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteId,
        referencedTable: $db.palettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PalettesTableFilterComposer(
              $db: $db,
              $table: $db.palettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get thumbnailData => $composableBuilder(
      column: $table.thumbnailData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isConverted => $composableBuilder(
      column: $table.isConverted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vectorObjects => $composableBuilder(
      column: $table.vectorObjects,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get imageWidth => $composableBuilder(
      column: $table.imageWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get imageHeight => $composableBuilder(
      column: $table.imageHeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uniqueColorCount => $composableBuilder(
      column: $table.uniqueColorCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get originalImageData => $composableBuilder(
      column: $table.originalImageData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get resizedImageData => $composableBuilder(
      column: $table.resizedImageData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalImageWidth => $composableBuilder(
      column: $table.originalImageWidth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalImageHeight => $composableBuilder(
      column: $table.originalImageHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get filterQualityIndex => $composableBuilder(
      column: $table.filterQualityIndex,
      builder: (column) => ColumnOrderings(column));

  $$PalettesTableOrderingComposer get paletteId {
    final $$PalettesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteId,
        referencedTable: $db.palettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PalettesTableOrderingComposer(
              $db: $db,
              $table: $db.palettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageData =>
      $composableBuilder(column: $table.imageData, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbnailData => $composableBuilder(
      column: $table.thumbnailData, builder: (column) => column);

  GeneratedColumn<bool> get isConverted => $composableBuilder(
      column: $table.isConverted, builder: (column) => column);

  GeneratedColumn<String> get vectorObjects => $composableBuilder(
      column: $table.vectorObjects, builder: (column) => column);

  GeneratedColumn<double> get imageWidth => $composableBuilder(
      column: $table.imageWidth, builder: (column) => column);

  GeneratedColumn<double> get imageHeight => $composableBuilder(
      column: $table.imageHeight, builder: (column) => column);

  GeneratedColumn<int> get uniqueColorCount => $composableBuilder(
      column: $table.uniqueColorCount, builder: (column) => column);

  GeneratedColumn<Uint8List> get originalImageData => $composableBuilder(
      column: $table.originalImageData, builder: (column) => column);

  GeneratedColumn<Uint8List> get resizedImageData => $composableBuilder(
      column: $table.resizedImageData, builder: (column) => column);

  GeneratedColumn<double> get originalImageWidth => $composableBuilder(
      column: $table.originalImageWidth, builder: (column) => column);

  GeneratedColumn<double> get originalImageHeight => $composableBuilder(
      column: $table.originalImageHeight, builder: (column) => column);

  GeneratedColumn<int> get filterQualityIndex => $composableBuilder(
      column: $table.filterQualityIndex, builder: (column) => column);

  $$PalettesTableAnnotationComposer get paletteId {
    final $$PalettesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteId,
        referencedTable: $db.palettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PalettesTableAnnotationComposer(
              $db: $db,
              $table: $db.palettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function({bool paletteId})> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<Uint8List> imageData = const Value.absent(),
            Value<Uint8List> thumbnailData = const Value.absent(),
            Value<bool> isConverted = const Value.absent(),
            Value<String> vectorObjects = const Value.absent(),
            Value<double?> imageWidth = const Value.absent(),
            Value<double?> imageHeight = const Value.absent(),
            Value<int?> uniqueColorCount = const Value.absent(),
            Value<Uint8List?> originalImageData = const Value.absent(),
            Value<Uint8List?> resizedImageData = const Value.absent(),
            Value<double?> originalImageWidth = const Value.absent(),
            Value<double?> originalImageHeight = const Value.absent(),
            Value<int> filterQualityIndex = const Value.absent(),
            Value<int?> paletteId = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            imageData: imageData,
            thumbnailData: thumbnailData,
            isConverted: isConverted,
            vectorObjects: vectorObjects,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            uniqueColorCount: uniqueColorCount,
            originalImageData: originalImageData,
            resizedImageData: resizedImageData,
            originalImageWidth: originalImageWidth,
            originalImageHeight: originalImageHeight,
            filterQualityIndex: filterQualityIndex,
            paletteId: paletteId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required Uint8List imageData,
            required Uint8List thumbnailData,
            Value<bool> isConverted = const Value.absent(),
            Value<String> vectorObjects = const Value.absent(),
            Value<double?> imageWidth = const Value.absent(),
            Value<double?> imageHeight = const Value.absent(),
            Value<int?> uniqueColorCount = const Value.absent(),
            Value<Uint8List?> originalImageData = const Value.absent(),
            Value<Uint8List?> resizedImageData = const Value.absent(),
            Value<double?> originalImageWidth = const Value.absent(),
            Value<double?> originalImageHeight = const Value.absent(),
            Value<int> filterQualityIndex = const Value.absent(),
            Value<int?> paletteId = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            imageData: imageData,
            thumbnailData: thumbnailData,
            isConverted: isConverted,
            vectorObjects: vectorObjects,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            uniqueColorCount: uniqueColorCount,
            originalImageData: originalImageData,
            resizedImageData: resizedImageData,
            originalImageWidth: originalImageWidth,
            originalImageHeight: originalImageHeight,
            filterQualityIndex: filterQualityIndex,
            paletteId: paletteId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({paletteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (paletteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paletteId,
                    referencedTable:
                        $$ProjectsTableReferences._paletteIdTable(db),
                    referencedColumn:
                        $$ProjectsTableReferences._paletteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function({bool paletteId})>;
typedef $$PaletteColorsTableCreateCompanionBuilder = PaletteColorsCompanion
    Function({
  Value<int> id,
  required int paletteId,
  required String title,
  required int color,
  Value<String> status,
});
typedef $$PaletteColorsTableUpdateCompanionBuilder = PaletteColorsCompanion
    Function({
  Value<int> id,
  Value<int> paletteId,
  Value<String> title,
  Value<int> color,
  Value<String> status,
});

final class $$PaletteColorsTableReferences
    extends BaseReferences<_$AppDatabase, $PaletteColorsTable, PaletteColor> {
  $$PaletteColorsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PalettesTable _paletteIdTable(_$AppDatabase db) =>
      db.palettes.createAlias(
          $_aliasNameGenerator(db.paletteColors.paletteId, db.palettes.id));

  $$PalettesTableProcessedTableManager get paletteId {
    final $_column = $_itemColumn<int>('palette_id')!;

    final manager = $$PalettesTableTableManager($_db, $_db.palettes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paletteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ColorComponentsTable, List<ColorComponent>>
      _colorComponentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.colorComponents,
              aliasName: $_aliasNameGenerator(
                  db.paletteColors.id, db.colorComponents.paletteColorId));

  $$ColorComponentsTableProcessedTableManager get colorComponentsRefs {
    final manager = $$ColorComponentsTableTableManager(
            $_db, $_db.colorComponents)
        .filter((f) => f.paletteColorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_colorComponentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PaletteColorsTableFilterComposer
    extends Composer<_$AppDatabase, $PaletteColorsTable> {
  $$PaletteColorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$PalettesTableFilterComposer get paletteId {
    final $$PalettesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteId,
        referencedTable: $db.palettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PalettesTableFilterComposer(
              $db: $db,
              $table: $db.palettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> colorComponentsRefs(
      Expression<bool> Function($$ColorComponentsTableFilterComposer f) f) {
    final $$ColorComponentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.colorComponents,
        getReferencedColumn: (t) => t.paletteColorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorComponentsTableFilterComposer(
              $db: $db,
              $table: $db.colorComponents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PaletteColorsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaletteColorsTable> {
  $$PaletteColorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$PalettesTableOrderingComposer get paletteId {
    final $$PalettesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteId,
        referencedTable: $db.palettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PalettesTableOrderingComposer(
              $db: $db,
              $table: $db.palettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaletteColorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaletteColorsTable> {
  $$PaletteColorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$PalettesTableAnnotationComposer get paletteId {
    final $$PalettesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteId,
        referencedTable: $db.palettes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PalettesTableAnnotationComposer(
              $db: $db,
              $table: $db.palettes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> colorComponentsRefs<T extends Object>(
      Expression<T> Function($$ColorComponentsTableAnnotationComposer a) f) {
    final $$ColorComponentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.colorComponents,
        getReferencedColumn: (t) => t.paletteColorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorComponentsTableAnnotationComposer(
              $db: $db,
              $table: $db.colorComponents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PaletteColorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaletteColorsTable,
    PaletteColor,
    $$PaletteColorsTableFilterComposer,
    $$PaletteColorsTableOrderingComposer,
    $$PaletteColorsTableAnnotationComposer,
    $$PaletteColorsTableCreateCompanionBuilder,
    $$PaletteColorsTableUpdateCompanionBuilder,
    (PaletteColor, $$PaletteColorsTableReferences),
    PaletteColor,
    PrefetchHooks Function({bool paletteId, bool colorComponentsRefs})> {
  $$PaletteColorsTableTableManager(_$AppDatabase db, $PaletteColorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaletteColorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaletteColorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaletteColorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> paletteId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              PaletteColorsCompanion(
            id: id,
            paletteId: paletteId,
            title: title,
            color: color,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int paletteId,
            required String title,
            required int color,
            Value<String> status = const Value.absent(),
          }) =>
              PaletteColorsCompanion.insert(
            id: id,
            paletteId: paletteId,
            title: title,
            color: color,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaletteColorsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {paletteId = false, colorComponentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (colorComponentsRefs) db.colorComponents
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (paletteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paletteId,
                    referencedTable:
                        $$PaletteColorsTableReferences._paletteIdTable(db),
                    referencedColumn:
                        $$PaletteColorsTableReferences._paletteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (colorComponentsRefs)
                    await $_getPrefetchedData<PaletteColor, $PaletteColorsTable, ColorComponent>(
                        currentTable: table,
                        referencedTable: $$PaletteColorsTableReferences
                            ._colorComponentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PaletteColorsTableReferences(db, table, p0)
                                .colorComponentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paletteColorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PaletteColorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaletteColorsTable,
    PaletteColor,
    $$PaletteColorsTableFilterComposer,
    $$PaletteColorsTableOrderingComposer,
    $$PaletteColorsTableAnnotationComposer,
    $$PaletteColorsTableCreateCompanionBuilder,
    $$PaletteColorsTableUpdateCompanionBuilder,
    (PaletteColor, $$PaletteColorsTableReferences),
    PaletteColor,
    PrefetchHooks Function({bool paletteId, bool colorComponentsRefs})>;
typedef $$VendorColorsTableCreateCompanionBuilder = VendorColorsCompanion
    Function({
  Value<int> id,
  required String name,
  required String code,
  Value<String> imageUrl,
  Value<double?> weightInGrams,
  Value<double?> colorDensity,
});
typedef $$VendorColorsTableUpdateCompanionBuilder = VendorColorsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> code,
  Value<String> imageUrl,
  Value<double?> weightInGrams,
  Value<double?> colorDensity,
});

final class $$VendorColorsTableReferences
    extends BaseReferences<_$AppDatabase, $VendorColorsTable, VendorColor> {
  $$VendorColorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VendorColorVariantsTable,
      List<VendorColorVariant>> _vendorColorVariantsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.vendorColorVariants,
          aliasName: $_aliasNameGenerator(
              db.vendorColors.id, db.vendorColorVariants.vendorColorId));

  $$VendorColorVariantsTableProcessedTableManager get vendorColorVariantsRefs {
    final manager = $$VendorColorVariantsTableTableManager(
            $_db, $_db.vendorColorVariants)
        .filter((f) => f.vendorColorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_vendorColorVariantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ColorComponentsTable, List<ColorComponent>>
      _colorComponentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.colorComponents,
              aliasName: $_aliasNameGenerator(
                  db.vendorColors.id, db.colorComponents.vendorColorId));

  $$ColorComponentsTableProcessedTableManager get colorComponentsRefs {
    final manager = $$ColorComponentsTableTableManager(
            $_db, $_db.colorComponents)
        .filter((f) => f.vendorColorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_colorComponentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VendorColorsTableFilterComposer
    extends Composer<_$AppDatabase, $VendorColorsTable> {
  $$VendorColorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightInGrams => $composableBuilder(
      column: $table.weightInGrams, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get colorDensity => $composableBuilder(
      column: $table.colorDensity, builder: (column) => ColumnFilters(column));

  Expression<bool> vendorColorVariantsRefs(
      Expression<bool> Function($$VendorColorVariantsTableFilterComposer f) f) {
    final $$VendorColorVariantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vendorColorVariants,
        getReferencedColumn: (t) => t.vendorColorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorVariantsTableFilterComposer(
              $db: $db,
              $table: $db.vendorColorVariants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> colorComponentsRefs(
      Expression<bool> Function($$ColorComponentsTableFilterComposer f) f) {
    final $$ColorComponentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.colorComponents,
        getReferencedColumn: (t) => t.vendorColorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorComponentsTableFilterComposer(
              $db: $db,
              $table: $db.colorComponents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VendorColorsTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorColorsTable> {
  $$VendorColorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightInGrams => $composableBuilder(
      column: $table.weightInGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get colorDensity => $composableBuilder(
      column: $table.colorDensity,
      builder: (column) => ColumnOrderings(column));
}

class $$VendorColorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorColorsTable> {
  $$VendorColorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get weightInGrams => $composableBuilder(
      column: $table.weightInGrams, builder: (column) => column);

  GeneratedColumn<double> get colorDensity => $composableBuilder(
      column: $table.colorDensity, builder: (column) => column);

  Expression<T> vendorColorVariantsRefs<T extends Object>(
      Expression<T> Function($$VendorColorVariantsTableAnnotationComposer a)
          f) {
    final $$VendorColorVariantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.vendorColorVariants,
            getReferencedColumn: (t) => t.vendorColorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VendorColorVariantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.vendorColorVariants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> colorComponentsRefs<T extends Object>(
      Expression<T> Function($$ColorComponentsTableAnnotationComposer a) f) {
    final $$ColorComponentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.colorComponents,
        getReferencedColumn: (t) => t.vendorColorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ColorComponentsTableAnnotationComposer(
              $db: $db,
              $table: $db.colorComponents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VendorColorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VendorColorsTable,
    VendorColor,
    $$VendorColorsTableFilterComposer,
    $$VendorColorsTableOrderingComposer,
    $$VendorColorsTableAnnotationComposer,
    $$VendorColorsTableCreateCompanionBuilder,
    $$VendorColorsTableUpdateCompanionBuilder,
    (VendorColor, $$VendorColorsTableReferences),
    VendorColor,
    PrefetchHooks Function(
        {bool vendorColorVariantsRefs, bool colorComponentsRefs})> {
  $$VendorColorsTableTableManager(_$AppDatabase db, $VendorColorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorColorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorColorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorColorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<double?> weightInGrams = const Value.absent(),
            Value<double?> colorDensity = const Value.absent(),
          }) =>
              VendorColorsCompanion(
            id: id,
            name: name,
            code: code,
            imageUrl: imageUrl,
            weightInGrams: weightInGrams,
            colorDensity: colorDensity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String code,
            Value<String> imageUrl = const Value.absent(),
            Value<double?> weightInGrams = const Value.absent(),
            Value<double?> colorDensity = const Value.absent(),
          }) =>
              VendorColorsCompanion.insert(
            id: id,
            name: name,
            code: code,
            imageUrl: imageUrl,
            weightInGrams: weightInGrams,
            colorDensity: colorDensity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VendorColorsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {vendorColorVariantsRefs = false, colorComponentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vendorColorVariantsRefs) db.vendorColorVariants,
                if (colorComponentsRefs) db.colorComponents
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vendorColorVariantsRefs)
                    await $_getPrefetchedData<VendorColor, $VendorColorsTable,
                            VendorColorVariant>(
                        currentTable: table,
                        referencedTable: $$VendorColorsTableReferences
                            ._vendorColorVariantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorColorsTableReferences(db, table, p0)
                                .vendorColorVariantsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vendorColorId == item.id),
                        typedResults: items),
                  if (colorComponentsRefs)
                    await $_getPrefetchedData<VendorColor, $VendorColorsTable,
                            ColorComponent>(
                        currentTable: table,
                        referencedTable: $$VendorColorsTableReferences
                            ._colorComponentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorColorsTableReferences(db, table, p0)
                                .colorComponentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vendorColorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VendorColorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VendorColorsTable,
    VendorColor,
    $$VendorColorsTableFilterComposer,
    $$VendorColorsTableOrderingComposer,
    $$VendorColorsTableAnnotationComposer,
    $$VendorColorsTableCreateCompanionBuilder,
    $$VendorColorsTableUpdateCompanionBuilder,
    (VendorColor, $$VendorColorsTableReferences),
    VendorColor,
    PrefetchHooks Function(
        {bool vendorColorVariantsRefs, bool colorComponentsRefs})>;
typedef $$VendorColorVariantsTableCreateCompanionBuilder
    = VendorColorVariantsCompanion Function({
  Value<int> id,
  required int vendorColorId,
  required int size,
  Value<int> stock,
  Value<double?> weightInGrams,
});
typedef $$VendorColorVariantsTableUpdateCompanionBuilder
    = VendorColorVariantsCompanion Function({
  Value<int> id,
  Value<int> vendorColorId,
  Value<int> size,
  Value<int> stock,
  Value<double?> weightInGrams,
});

final class $$VendorColorVariantsTableReferences extends BaseReferences<
    _$AppDatabase, $VendorColorVariantsTable, VendorColorVariant> {
  $$VendorColorVariantsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $VendorColorsTable _vendorColorIdTable(_$AppDatabase db) =>
      db.vendorColors.createAlias($_aliasNameGenerator(
          db.vendorColorVariants.vendorColorId, db.vendorColors.id));

  $$VendorColorsTableProcessedTableManager get vendorColorId {
    final $_column = $_itemColumn<int>('vendor_color_id')!;

    final manager = $$VendorColorsTableTableManager($_db, $_db.vendorColors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorColorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VendorColorVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $VendorColorVariantsTable> {
  $$VendorColorVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightInGrams => $composableBuilder(
      column: $table.weightInGrams, builder: (column) => ColumnFilters(column));

  $$VendorColorsTableFilterComposer get vendorColorId {
    final $$VendorColorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorColorId,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorsTableFilterComposer(
              $db: $db,
              $table: $db.vendorColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VendorColorVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorColorVariantsTable> {
  $$VendorColorVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightInGrams => $composableBuilder(
      column: $table.weightInGrams,
      builder: (column) => ColumnOrderings(column));

  $$VendorColorsTableOrderingComposer get vendorColorId {
    final $$VendorColorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorColorId,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendorColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VendorColorVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorColorVariantsTable> {
  $$VendorColorVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<double> get weightInGrams => $composableBuilder(
      column: $table.weightInGrams, builder: (column) => column);

  $$VendorColorsTableAnnotationComposer get vendorColorId {
    final $$VendorColorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorColorId,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendorColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VendorColorVariantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VendorColorVariantsTable,
    VendorColorVariant,
    $$VendorColorVariantsTableFilterComposer,
    $$VendorColorVariantsTableOrderingComposer,
    $$VendorColorVariantsTableAnnotationComposer,
    $$VendorColorVariantsTableCreateCompanionBuilder,
    $$VendorColorVariantsTableUpdateCompanionBuilder,
    (VendorColorVariant, $$VendorColorVariantsTableReferences),
    VendorColorVariant,
    PrefetchHooks Function({bool vendorColorId})> {
  $$VendorColorVariantsTableTableManager(
      _$AppDatabase db, $VendorColorVariantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorColorVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorColorVariantsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorColorVariantsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> vendorColorId = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<double?> weightInGrams = const Value.absent(),
          }) =>
              VendorColorVariantsCompanion(
            id: id,
            vendorColorId: vendorColorId,
            size: size,
            stock: stock,
            weightInGrams: weightInGrams,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int vendorColorId,
            required int size,
            Value<int> stock = const Value.absent(),
            Value<double?> weightInGrams = const Value.absent(),
          }) =>
              VendorColorVariantsCompanion.insert(
            id: id,
            vendorColorId: vendorColorId,
            size: size,
            stock: stock,
            weightInGrams: weightInGrams,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VendorColorVariantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vendorColorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (vendorColorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorColorId,
                    referencedTable: $$VendorColorVariantsTableReferences
                        ._vendorColorIdTable(db),
                    referencedColumn: $$VendorColorVariantsTableReferences
                        ._vendorColorIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VendorColorVariantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VendorColorVariantsTable,
    VendorColorVariant,
    $$VendorColorVariantsTableFilterComposer,
    $$VendorColorVariantsTableOrderingComposer,
    $$VendorColorVariantsTableAnnotationComposer,
    $$VendorColorVariantsTableCreateCompanionBuilder,
    $$VendorColorVariantsTableUpdateCompanionBuilder,
    (VendorColorVariant, $$VendorColorVariantsTableReferences),
    VendorColorVariant,
    PrefetchHooks Function({bool vendorColorId})>;
typedef $$ColorComponentsTableCreateCompanionBuilder = ColorComponentsCompanion
    Function({
  Value<int> id,
  required int paletteColorId,
  required int vendorColorId,
  required double percentage,
});
typedef $$ColorComponentsTableUpdateCompanionBuilder = ColorComponentsCompanion
    Function({
  Value<int> id,
  Value<int> paletteColorId,
  Value<int> vendorColorId,
  Value<double> percentage,
});

final class $$ColorComponentsTableReferences extends BaseReferences<
    _$AppDatabase, $ColorComponentsTable, ColorComponent> {
  $$ColorComponentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PaletteColorsTable _paletteColorIdTable(_$AppDatabase db) =>
      db.paletteColors.createAlias($_aliasNameGenerator(
          db.colorComponents.paletteColorId, db.paletteColors.id));

  $$PaletteColorsTableProcessedTableManager get paletteColorId {
    final $_column = $_itemColumn<int>('palette_color_id')!;

    final manager = $$PaletteColorsTableTableManager($_db, $_db.paletteColors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paletteColorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $VendorColorsTable _vendorColorIdTable(_$AppDatabase db) =>
      db.vendorColors.createAlias($_aliasNameGenerator(
          db.colorComponents.vendorColorId, db.vendorColors.id));

  $$VendorColorsTableProcessedTableManager get vendorColorId {
    final $_column = $_itemColumn<int>('vendor_color_id')!;

    final manager = $$VendorColorsTableTableManager($_db, $_db.vendorColors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorColorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ColorComponentsTableFilterComposer
    extends Composer<_$AppDatabase, $ColorComponentsTable> {
  $$ColorComponentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnFilters(column));

  $$PaletteColorsTableFilterComposer get paletteColorId {
    final $$PaletteColorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteColorId,
        referencedTable: $db.paletteColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaletteColorsTableFilterComposer(
              $db: $db,
              $table: $db.paletteColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorColorsTableFilterComposer get vendorColorId {
    final $$VendorColorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorColorId,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorsTableFilterComposer(
              $db: $db,
              $table: $db.vendorColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ColorComponentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ColorComponentsTable> {
  $$ColorComponentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnOrderings(column));

  $$PaletteColorsTableOrderingComposer get paletteColorId {
    final $$PaletteColorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteColorId,
        referencedTable: $db.paletteColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaletteColorsTableOrderingComposer(
              $db: $db,
              $table: $db.paletteColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorColorsTableOrderingComposer get vendorColorId {
    final $$VendorColorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorColorId,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendorColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ColorComponentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColorComponentsTable> {
  $$ColorComponentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => column);

  $$PaletteColorsTableAnnotationComposer get paletteColorId {
    final $$PaletteColorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paletteColorId,
        referencedTable: $db.paletteColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaletteColorsTableAnnotationComposer(
              $db: $db,
              $table: $db.paletteColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorColorsTableAnnotationComposer get vendorColorId {
    final $$VendorColorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorColorId,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorColorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendorColors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ColorComponentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ColorComponentsTable,
    ColorComponent,
    $$ColorComponentsTableFilterComposer,
    $$ColorComponentsTableOrderingComposer,
    $$ColorComponentsTableAnnotationComposer,
    $$ColorComponentsTableCreateCompanionBuilder,
    $$ColorComponentsTableUpdateCompanionBuilder,
    (ColorComponent, $$ColorComponentsTableReferences),
    ColorComponent,
    PrefetchHooks Function({bool paletteColorId, bool vendorColorId})> {
  $$ColorComponentsTableTableManager(
      _$AppDatabase db, $ColorComponentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColorComponentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColorComponentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColorComponentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> paletteColorId = const Value.absent(),
            Value<int> vendorColorId = const Value.absent(),
            Value<double> percentage = const Value.absent(),
          }) =>
              ColorComponentsCompanion(
            id: id,
            paletteColorId: paletteColorId,
            vendorColorId: vendorColorId,
            percentage: percentage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int paletteColorId,
            required int vendorColorId,
            required double percentage,
          }) =>
              ColorComponentsCompanion.insert(
            id: id,
            paletteColorId: paletteColorId,
            vendorColorId: vendorColorId,
            percentage: percentage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ColorComponentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {paletteColorId = false, vendorColorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (paletteColorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paletteColorId,
                    referencedTable: $$ColorComponentsTableReferences
                        ._paletteColorIdTable(db),
                    referencedColumn: $$ColorComponentsTableReferences
                        ._paletteColorIdTable(db)
                        .id,
                  ) as T;
                }
                if (vendorColorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorColorId,
                    referencedTable: $$ColorComponentsTableReferences
                        ._vendorColorIdTable(db),
                    referencedColumn: $$ColorComponentsTableReferences
                        ._vendorColorIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ColorComponentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ColorComponentsTable,
    ColorComponent,
    $$ColorComponentsTableFilterComposer,
    $$ColorComponentsTableOrderingComposer,
    $$ColorComponentsTableAnnotationComposer,
    $$ColorComponentsTableCreateCompanionBuilder,
    $$ColorComponentsTableUpdateCompanionBuilder,
    (ColorComponent, $$ColorComponentsTableReferences),
    ColorComponent,
    PrefetchHooks Function({bool paletteColorId, bool vendorColorId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PalettesTableTableManager get palettes =>
      $$PalettesTableTableManager(_db, _db.palettes);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$PaletteColorsTableTableManager get paletteColors =>
      $$PaletteColorsTableTableManager(_db, _db.paletteColors);
  $$VendorColorsTableTableManager get vendorColors =>
      $$VendorColorsTableTableManager(_db, _db.vendorColors);
  $$VendorColorVariantsTableTableManager get vendorColorVariants =>
      $$VendorColorVariantsTableTableManager(_db, _db.vendorColorVariants);
  $$ColorComponentsTableTableManager get colorComponents =>
      $$ColorComponentsTableTableManager(_db, _db.colorComponents);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
