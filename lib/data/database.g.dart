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

class $VendorsTable extends Vendors with TableInfo<$VendorsTable, Vendor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vendorNameMeta =
      const VerificationMeta('vendorName');
  @override
  late final GeneratedColumn<String> vendorName = GeneratedColumn<String>(
      'vendor_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vendorBrandMeta =
      const VerificationMeta('vendorBrand');
  @override
  late final GeneratedColumn<String> vendorBrand = GeneratedColumn<String>(
      'vendor_brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vendorCategoryMeta =
      const VerificationMeta('vendorCategory');
  @override
  late final GeneratedColumn<String> vendorCategory = GeneratedColumn<String>(
      'vendor_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vendorName, vendorBrand, vendorCategory];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendors';
  @override
  VerificationContext validateIntegrity(Insertable<Vendor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vendor_name')) {
      context.handle(
          _vendorNameMeta,
          vendorName.isAcceptableOrUnknown(
              data['vendor_name']!, _vendorNameMeta));
    } else if (isInserting) {
      context.missing(_vendorNameMeta);
    }
    if (data.containsKey('vendor_brand')) {
      context.handle(
          _vendorBrandMeta,
          vendorBrand.isAcceptableOrUnknown(
              data['vendor_brand']!, _vendorBrandMeta));
    } else if (isInserting) {
      context.missing(_vendorBrandMeta);
    }
    if (data.containsKey('vendor_category')) {
      context.handle(
          _vendorCategoryMeta,
          vendorCategory.isAcceptableOrUnknown(
              data['vendor_category']!, _vendorCategoryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vendor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vendor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vendorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_name'])!,
      vendorBrand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_brand'])!,
      vendorCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_category']),
    );
  }

  @override
  $VendorsTable createAlias(String alias) {
    return $VendorsTable(attachedDatabase, alias);
  }
}

class Vendor extends DataClass implements Insertable<Vendor> {
  final int id;
  final String vendorName;
  final String vendorBrand;
  final String? vendorCategory;
  const Vendor(
      {required this.id,
      required this.vendorName,
      required this.vendorBrand,
      this.vendorCategory});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vendor_name'] = Variable<String>(vendorName);
    map['vendor_brand'] = Variable<String>(vendorBrand);
    if (!nullToAbsent || vendorCategory != null) {
      map['vendor_category'] = Variable<String>(vendorCategory);
    }
    return map;
  }

  VendorsCompanion toCompanion(bool nullToAbsent) {
    return VendorsCompanion(
      id: Value(id),
      vendorName: Value(vendorName),
      vendorBrand: Value(vendorBrand),
      vendorCategory: vendorCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorCategory),
    );
  }

  factory Vendor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vendor(
      id: serializer.fromJson<int>(json['id']),
      vendorName: serializer.fromJson<String>(json['vendorName']),
      vendorBrand: serializer.fromJson<String>(json['vendorBrand']),
      vendorCategory: serializer.fromJson<String?>(json['vendorCategory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorName': serializer.toJson<String>(vendorName),
      'vendorBrand': serializer.toJson<String>(vendorBrand),
      'vendorCategory': serializer.toJson<String?>(vendorCategory),
    };
  }

  Vendor copyWith(
          {int? id,
          String? vendorName,
          String? vendorBrand,
          Value<String?> vendorCategory = const Value.absent()}) =>
      Vendor(
        id: id ?? this.id,
        vendorName: vendorName ?? this.vendorName,
        vendorBrand: vendorBrand ?? this.vendorBrand,
        vendorCategory:
            vendorCategory.present ? vendorCategory.value : this.vendorCategory,
      );
  Vendor copyWithCompanion(VendorsCompanion data) {
    return Vendor(
      id: data.id.present ? data.id.value : this.id,
      vendorName:
          data.vendorName.present ? data.vendorName.value : this.vendorName,
      vendorBrand:
          data.vendorBrand.present ? data.vendorBrand.value : this.vendorBrand,
      vendorCategory: data.vendorCategory.present
          ? data.vendorCategory.value
          : this.vendorCategory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vendor(')
          ..write('id: $id, ')
          ..write('vendorName: $vendorName, ')
          ..write('vendorBrand: $vendorBrand, ')
          ..write('vendorCategory: $vendorCategory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vendorName, vendorBrand, vendorCategory);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vendor &&
          other.id == this.id &&
          other.vendorName == this.vendorName &&
          other.vendorBrand == this.vendorBrand &&
          other.vendorCategory == this.vendorCategory);
}

class VendorsCompanion extends UpdateCompanion<Vendor> {
  final Value<int> id;
  final Value<String> vendorName;
  final Value<String> vendorBrand;
  final Value<String?> vendorCategory;
  const VendorsCompanion({
    this.id = const Value.absent(),
    this.vendorName = const Value.absent(),
    this.vendorBrand = const Value.absent(),
    this.vendorCategory = const Value.absent(),
  });
  VendorsCompanion.insert({
    this.id = const Value.absent(),
    required String vendorName,
    required String vendorBrand,
    this.vendorCategory = const Value.absent(),
  })  : vendorName = Value(vendorName),
        vendorBrand = Value(vendorBrand);
  static Insertable<Vendor> custom({
    Expression<int>? id,
    Expression<String>? vendorName,
    Expression<String>? vendorBrand,
    Expression<String>? vendorCategory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorName != null) 'vendor_name': vendorName,
      if (vendorBrand != null) 'vendor_brand': vendorBrand,
      if (vendorCategory != null) 'vendor_category': vendorCategory,
    });
  }

  VendorsCompanion copyWith(
      {Value<int>? id,
      Value<String>? vendorName,
      Value<String>? vendorBrand,
      Value<String?>? vendorCategory}) {
    return VendorsCompanion(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      vendorBrand: vendorBrand ?? this.vendorBrand,
      vendorCategory: vendorCategory ?? this.vendorCategory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorName.present) {
      map['vendor_name'] = Variable<String>(vendorName.value);
    }
    if (vendorBrand.present) {
      map['vendor_brand'] = Variable<String>(vendorBrand.value);
    }
    if (vendorCategory.present) {
      map['vendor_category'] = Variable<String>(vendorCategory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorsCompanion(')
          ..write('id: $id, ')
          ..write('vendorName: $vendorName, ')
          ..write('vendorBrand: $vendorBrand, ')
          ..write('vendorCategory: $vendorCategory')
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
  static const VerificationMeta _vendorIdMeta =
      const VerificationMeta('vendorId');
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
      'vendor_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vendors (id)'));
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
  static const VerificationMeta _pigmentCodeMeta =
      const VerificationMeta('pigmentCode');
  @override
  late final GeneratedColumn<String> pigmentCode = GeneratedColumn<String>(
      'pigment_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _opacityMeta =
      const VerificationMeta('opacity');
  @override
  late final GeneratedColumn<String> opacity = GeneratedColumn<String>(
      'opacity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lightfastnessMeta =
      const VerificationMeta('lightfastness');
  @override
  late final GeneratedColumn<int> lightfastness = GeneratedColumn<int>(
      'lightfastness', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vendorId,
        name,
        code,
        imageUrl,
        weightInGrams,
        colorDensity,
        pigmentCode,
        opacity,
        lightfastness
      ];
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
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
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
    if (data.containsKey('pigment_code')) {
      context.handle(
          _pigmentCodeMeta,
          pigmentCode.isAcceptableOrUnknown(
              data['pigment_code']!, _pigmentCodeMeta));
    }
    if (data.containsKey('opacity')) {
      context.handle(_opacityMeta,
          opacity.isAcceptableOrUnknown(data['opacity']!, _opacityMeta));
    }
    if (data.containsKey('lightfastness')) {
      context.handle(
          _lightfastnessMeta,
          lightfastness.isAcceptableOrUnknown(
              data['lightfastness']!, _lightfastnessMeta));
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
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id']),
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
      pigmentCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pigment_code']),
      opacity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opacity']),
      lightfastness: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lightfastness']),
    );
  }

  @override
  $VendorColorsTable createAlias(String alias) {
    return $VendorColorsTable(attachedDatabase, alias);
  }
}

class VendorColor extends DataClass implements Insertable<VendorColor> {
  final int id;
  final int? vendorId;
  final String name;
  final String code;
  final String imageUrl;
  final double? weightInGrams;
  final double? colorDensity;
  final String? pigmentCode;
  final String? opacity;
  final int? lightfastness;
  const VendorColor(
      {required this.id,
      this.vendorId,
      required this.name,
      required this.code,
      required this.imageUrl,
      this.weightInGrams,
      this.colorDensity,
      this.pigmentCode,
      this.opacity,
      this.lightfastness});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || vendorId != null) {
      map['vendor_id'] = Variable<int>(vendorId);
    }
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['image_url'] = Variable<String>(imageUrl);
    if (!nullToAbsent || weightInGrams != null) {
      map['weight_in_grams'] = Variable<double>(weightInGrams);
    }
    if (!nullToAbsent || colorDensity != null) {
      map['color_density'] = Variable<double>(colorDensity);
    }
    if (!nullToAbsent || pigmentCode != null) {
      map['pigment_code'] = Variable<String>(pigmentCode);
    }
    if (!nullToAbsent || opacity != null) {
      map['opacity'] = Variable<String>(opacity);
    }
    if (!nullToAbsent || lightfastness != null) {
      map['lightfastness'] = Variable<int>(lightfastness);
    }
    return map;
  }

  VendorColorsCompanion toCompanion(bool nullToAbsent) {
    return VendorColorsCompanion(
      id: Value(id),
      vendorId: vendorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorId),
      name: Value(name),
      code: Value(code),
      imageUrl: Value(imageUrl),
      weightInGrams: weightInGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(weightInGrams),
      colorDensity: colorDensity == null && nullToAbsent
          ? const Value.absent()
          : Value(colorDensity),
      pigmentCode: pigmentCode == null && nullToAbsent
          ? const Value.absent()
          : Value(pigmentCode),
      opacity: opacity == null && nullToAbsent
          ? const Value.absent()
          : Value(opacity),
      lightfastness: lightfastness == null && nullToAbsent
          ? const Value.absent()
          : Value(lightfastness),
    );
  }

  factory VendorColor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VendorColor(
      id: serializer.fromJson<int>(json['id']),
      vendorId: serializer.fromJson<int?>(json['vendorId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      weightInGrams: serializer.fromJson<double?>(json['weightInGrams']),
      colorDensity: serializer.fromJson<double?>(json['colorDensity']),
      pigmentCode: serializer.fromJson<String?>(json['pigmentCode']),
      opacity: serializer.fromJson<String?>(json['opacity']),
      lightfastness: serializer.fromJson<int?>(json['lightfastness']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorId': serializer.toJson<int?>(vendorId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'weightInGrams': serializer.toJson<double?>(weightInGrams),
      'colorDensity': serializer.toJson<double?>(colorDensity),
      'pigmentCode': serializer.toJson<String?>(pigmentCode),
      'opacity': serializer.toJson<String?>(opacity),
      'lightfastness': serializer.toJson<int?>(lightfastness),
    };
  }

  VendorColor copyWith(
          {int? id,
          Value<int?> vendorId = const Value.absent(),
          String? name,
          String? code,
          String? imageUrl,
          Value<double?> weightInGrams = const Value.absent(),
          Value<double?> colorDensity = const Value.absent(),
          Value<String?> pigmentCode = const Value.absent(),
          Value<String?> opacity = const Value.absent(),
          Value<int?> lightfastness = const Value.absent()}) =>
      VendorColor(
        id: id ?? this.id,
        vendorId: vendorId.present ? vendorId.value : this.vendorId,
        name: name ?? this.name,
        code: code ?? this.code,
        imageUrl: imageUrl ?? this.imageUrl,
        weightInGrams:
            weightInGrams.present ? weightInGrams.value : this.weightInGrams,
        colorDensity:
            colorDensity.present ? colorDensity.value : this.colorDensity,
        pigmentCode: pigmentCode.present ? pigmentCode.value : this.pigmentCode,
        opacity: opacity.present ? opacity.value : this.opacity,
        lightfastness:
            lightfastness.present ? lightfastness.value : this.lightfastness,
      );
  VendorColor copyWithCompanion(VendorColorsCompanion data) {
    return VendorColor(
      id: data.id.present ? data.id.value : this.id,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      weightInGrams: data.weightInGrams.present
          ? data.weightInGrams.value
          : this.weightInGrams,
      colorDensity: data.colorDensity.present
          ? data.colorDensity.value
          : this.colorDensity,
      pigmentCode:
          data.pigmentCode.present ? data.pigmentCode.value : this.pigmentCode,
      opacity: data.opacity.present ? data.opacity.value : this.opacity,
      lightfastness: data.lightfastness.present
          ? data.lightfastness.value
          : this.lightfastness,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VendorColor(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('weightInGrams: $weightInGrams, ')
          ..write('colorDensity: $colorDensity, ')
          ..write('pigmentCode: $pigmentCode, ')
          ..write('opacity: $opacity, ')
          ..write('lightfastness: $lightfastness')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vendorId, name, code, imageUrl,
      weightInGrams, colorDensity, pigmentCode, opacity, lightfastness);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VendorColor &&
          other.id == this.id &&
          other.vendorId == this.vendorId &&
          other.name == this.name &&
          other.code == this.code &&
          other.imageUrl == this.imageUrl &&
          other.weightInGrams == this.weightInGrams &&
          other.colorDensity == this.colorDensity &&
          other.pigmentCode == this.pigmentCode &&
          other.opacity == this.opacity &&
          other.lightfastness == this.lightfastness);
}

class VendorColorsCompanion extends UpdateCompanion<VendorColor> {
  final Value<int> id;
  final Value<int?> vendorId;
  final Value<String> name;
  final Value<String> code;
  final Value<String> imageUrl;
  final Value<double?> weightInGrams;
  final Value<double?> colorDensity;
  final Value<String?> pigmentCode;
  final Value<String?> opacity;
  final Value<int?> lightfastness;
  const VendorColorsCompanion({
    this.id = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.weightInGrams = const Value.absent(),
    this.colorDensity = const Value.absent(),
    this.pigmentCode = const Value.absent(),
    this.opacity = const Value.absent(),
    this.lightfastness = const Value.absent(),
  });
  VendorColorsCompanion.insert({
    this.id = const Value.absent(),
    this.vendorId = const Value.absent(),
    required String name,
    required String code,
    this.imageUrl = const Value.absent(),
    this.weightInGrams = const Value.absent(),
    this.colorDensity = const Value.absent(),
    this.pigmentCode = const Value.absent(),
    this.opacity = const Value.absent(),
    this.lightfastness = const Value.absent(),
  })  : name = Value(name),
        code = Value(code);
  static Insertable<VendorColor> custom({
    Expression<int>? id,
    Expression<int>? vendorId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? imageUrl,
    Expression<double>? weightInGrams,
    Expression<double>? colorDensity,
    Expression<String>? pigmentCode,
    Expression<String>? opacity,
    Expression<int>? lightfastness,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorId != null) 'vendor_id': vendorId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (imageUrl != null) 'image_url': imageUrl,
      if (weightInGrams != null) 'weight_in_grams': weightInGrams,
      if (colorDensity != null) 'color_density': colorDensity,
      if (pigmentCode != null) 'pigment_code': pigmentCode,
      if (opacity != null) 'opacity': opacity,
      if (lightfastness != null) 'lightfastness': lightfastness,
    });
  }

  VendorColorsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? vendorId,
      Value<String>? name,
      Value<String>? code,
      Value<String>? imageUrl,
      Value<double?>? weightInGrams,
      Value<double?>? colorDensity,
      Value<String?>? pigmentCode,
      Value<String?>? opacity,
      Value<int?>? lightfastness}) {
    return VendorColorsCompanion(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      code: code ?? this.code,
      imageUrl: imageUrl ?? this.imageUrl,
      weightInGrams: weightInGrams ?? this.weightInGrams,
      colorDensity: colorDensity ?? this.colorDensity,
      pigmentCode: pigmentCode ?? this.pigmentCode,
      opacity: opacity ?? this.opacity,
      lightfastness: lightfastness ?? this.lightfastness,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
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
    if (pigmentCode.present) {
      map['pigment_code'] = Variable<String>(pigmentCode.value);
    }
    if (opacity.present) {
      map['opacity'] = Variable<String>(opacity.value);
    }
    if (lightfastness.present) {
      map['lightfastness'] = Variable<int>(lightfastness.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorColorsCompanion(')
          ..write('id: $id, ')
          ..write('vendorId: $vendorId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('weightInGrams: $weightInGrams, ')
          ..write('colorDensity: $colorDensity, ')
          ..write('pigmentCode: $pigmentCode, ')
          ..write('opacity: $opacity, ')
          ..write('lightfastness: $lightfastness')
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

class $ImagesTable extends Images with TableInfo<$ImagesTable, DbImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _origSrcMeta =
      const VerificationMeta('origSrc');
  @override
  late final GeneratedColumn<Uint8List> origSrc = GeneratedColumn<Uint8List>(
      'orig_src', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _origBytesMeta =
      const VerificationMeta('origBytes');
  @override
  late final GeneratedColumn<int> origBytes = GeneratedColumn<int>(
      'orig_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _origWidthMeta =
      const VerificationMeta('origWidth');
  @override
  late final GeneratedColumn<int> origWidth = GeneratedColumn<int>(
      'orig_width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _origHeightMeta =
      const VerificationMeta('origHeight');
  @override
  late final GeneratedColumn<int> origHeight = GeneratedColumn<int>(
      'orig_height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _origUniqueColorsMeta =
      const VerificationMeta('origUniqueColors');
  @override
  late final GeneratedColumn<int> origUniqueColors = GeneratedColumn<int>(
      'orig_unique_colors', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _origDpiMeta =
      const VerificationMeta('origDpi');
  @override
  late final GeneratedColumn<int> origDpi = GeneratedColumn<int>(
      'orig_dpi', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _convSrcMeta =
      const VerificationMeta('convSrc');
  @override
  late final GeneratedColumn<Uint8List> convSrc = GeneratedColumn<Uint8List>(
      'conv_src', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _convBytesMeta =
      const VerificationMeta('convBytes');
  @override
  late final GeneratedColumn<int> convBytes = GeneratedColumn<int>(
      'conv_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _convWidthMeta =
      const VerificationMeta('convWidth');
  @override
  late final GeneratedColumn<int> convWidth = GeneratedColumn<int>(
      'conv_width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _convHeightMeta =
      const VerificationMeta('convHeight');
  @override
  late final GeneratedColumn<int> convHeight = GeneratedColumn<int>(
      'conv_height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _convUniqueColorsMeta =
      const VerificationMeta('convUniqueColors');
  @override
  late final GeneratedColumn<int> convUniqueColors = GeneratedColumn<int>(
      'conv_unique_colors', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dpiMeta = const VerificationMeta('dpi');
  @override
  late final GeneratedColumn<int> dpi = GeneratedColumn<int>(
      'dpi', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailMeta =
      const VerificationMeta('thumbnail');
  @override
  late final GeneratedColumn<Uint8List> thumbnail = GeneratedColumn<Uint8List>(
      'thumbnail', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _layerOffsetXMeta =
      const VerificationMeta('layerOffsetX');
  @override
  late final GeneratedColumn<double> layerOffsetX = GeneratedColumn<double>(
      'layer_offset_x', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _layerOffsetYMeta =
      const VerificationMeta('layerOffsetY');
  @override
  late final GeneratedColumn<double> layerOffsetY = GeneratedColumn<double>(
      'layer_offset_y', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _layerScaleMeta =
      const VerificationMeta('layerScale');
  @override
  late final GeneratedColumn<double> layerScale = GeneratedColumn<double>(
      'layer_scale', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _layerRotationDegMeta =
      const VerificationMeta('layerRotationDeg');
  @override
  late final GeneratedColumn<double> layerRotationDeg = GeneratedColumn<double>(
      'layer_rotation_deg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _layerOpacityMeta =
      const VerificationMeta('layerOpacity');
  @override
  late final GeneratedColumn<double> layerOpacity = GeneratedColumn<double>(
      'layer_opacity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _layerVisibleMeta =
      const VerificationMeta('layerVisible');
  @override
  late final GeneratedColumn<bool> layerVisible = GeneratedColumn<bool>(
      'layer_visible', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("layer_visible" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        origSrc,
        origBytes,
        origWidth,
        origHeight,
        origUniqueColors,
        origDpi,
        convSrc,
        convBytes,
        convWidth,
        convHeight,
        convUniqueColors,
        dpi,
        thumbnail,
        mimeType,
        layerOffsetX,
        layerOffsetY,
        layerScale,
        layerRotationDeg,
        layerOpacity,
        layerVisible
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(Insertable<DbImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('orig_src')) {
      context.handle(_origSrcMeta,
          origSrc.isAcceptableOrUnknown(data['orig_src']!, _origSrcMeta));
    }
    if (data.containsKey('orig_bytes')) {
      context.handle(_origBytesMeta,
          origBytes.isAcceptableOrUnknown(data['orig_bytes']!, _origBytesMeta));
    }
    if (data.containsKey('orig_width')) {
      context.handle(_origWidthMeta,
          origWidth.isAcceptableOrUnknown(data['orig_width']!, _origWidthMeta));
    }
    if (data.containsKey('orig_height')) {
      context.handle(
          _origHeightMeta,
          origHeight.isAcceptableOrUnknown(
              data['orig_height']!, _origHeightMeta));
    }
    if (data.containsKey('orig_unique_colors')) {
      context.handle(
          _origUniqueColorsMeta,
          origUniqueColors.isAcceptableOrUnknown(
              data['orig_unique_colors']!, _origUniqueColorsMeta));
    }
    if (data.containsKey('orig_dpi')) {
      context.handle(_origDpiMeta,
          origDpi.isAcceptableOrUnknown(data['orig_dpi']!, _origDpiMeta));
    }
    if (data.containsKey('conv_src')) {
      context.handle(_convSrcMeta,
          convSrc.isAcceptableOrUnknown(data['conv_src']!, _convSrcMeta));
    }
    if (data.containsKey('conv_bytes')) {
      context.handle(_convBytesMeta,
          convBytes.isAcceptableOrUnknown(data['conv_bytes']!, _convBytesMeta));
    }
    if (data.containsKey('conv_width')) {
      context.handle(_convWidthMeta,
          convWidth.isAcceptableOrUnknown(data['conv_width']!, _convWidthMeta));
    }
    if (data.containsKey('conv_height')) {
      context.handle(
          _convHeightMeta,
          convHeight.isAcceptableOrUnknown(
              data['conv_height']!, _convHeightMeta));
    }
    if (data.containsKey('conv_unique_colors')) {
      context.handle(
          _convUniqueColorsMeta,
          convUniqueColors.isAcceptableOrUnknown(
              data['conv_unique_colors']!, _convUniqueColorsMeta));
    }
    if (data.containsKey('dpi')) {
      context.handle(
          _dpiMeta, dpi.isAcceptableOrUnknown(data['dpi']!, _dpiMeta));
    }
    if (data.containsKey('thumbnail')) {
      context.handle(_thumbnailMeta,
          thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta));
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('layer_offset_x')) {
      context.handle(
          _layerOffsetXMeta,
          layerOffsetX.isAcceptableOrUnknown(
              data['layer_offset_x']!, _layerOffsetXMeta));
    }
    if (data.containsKey('layer_offset_y')) {
      context.handle(
          _layerOffsetYMeta,
          layerOffsetY.isAcceptableOrUnknown(
              data['layer_offset_y']!, _layerOffsetYMeta));
    }
    if (data.containsKey('layer_scale')) {
      context.handle(
          _layerScaleMeta,
          layerScale.isAcceptableOrUnknown(
              data['layer_scale']!, _layerScaleMeta));
    }
    if (data.containsKey('layer_rotation_deg')) {
      context.handle(
          _layerRotationDegMeta,
          layerRotationDeg.isAcceptableOrUnknown(
              data['layer_rotation_deg']!, _layerRotationDegMeta));
    }
    if (data.containsKey('layer_opacity')) {
      context.handle(
          _layerOpacityMeta,
          layerOpacity.isAcceptableOrUnknown(
              data['layer_opacity']!, _layerOpacityMeta));
    }
    if (data.containsKey('layer_visible')) {
      context.handle(
          _layerVisibleMeta,
          layerVisible.isAcceptableOrUnknown(
              data['layer_visible']!, _layerVisibleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      origSrc: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}orig_src']),
      origBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orig_bytes']),
      origWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orig_width']),
      origHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orig_height']),
      origUniqueColors: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orig_unique_colors']),
      origDpi: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orig_dpi']),
      convSrc: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}conv_src']),
      convBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conv_bytes']),
      convWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conv_width']),
      convHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conv_height']),
      convUniqueColors: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conv_unique_colors']),
      dpi: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dpi']),
      thumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}thumbnail']),
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      layerOffsetX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}layer_offset_x']),
      layerOffsetY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}layer_offset_y']),
      layerScale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}layer_scale']),
      layerRotationDeg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}layer_rotation_deg']),
      layerOpacity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}layer_opacity']),
      layerVisible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}layer_visible']),
    );
  }

  @override
  $ImagesTable createAlias(String alias) {
    return $ImagesTable(attachedDatabase, alias);
  }
}

class DbImage extends DataClass implements Insertable<DbImage> {
  final int id;
  final Uint8List? origSrc;
  final int? origBytes;
  final int? origWidth;
  final int? origHeight;
  final int? origUniqueColors;
  final int? origDpi;
  final Uint8List? convSrc;
  final int? convBytes;
  final int? convWidth;
  final int? convHeight;
  final int? convUniqueColors;
  final int? dpi;
  final Uint8List? thumbnail;
  final String? mimeType;
  final double? layerOffsetX;
  final double? layerOffsetY;
  final double? layerScale;
  final double? layerRotationDeg;
  final double? layerOpacity;
  final bool? layerVisible;
  const DbImage(
      {required this.id,
      this.origSrc,
      this.origBytes,
      this.origWidth,
      this.origHeight,
      this.origUniqueColors,
      this.origDpi,
      this.convSrc,
      this.convBytes,
      this.convWidth,
      this.convHeight,
      this.convUniqueColors,
      this.dpi,
      this.thumbnail,
      this.mimeType,
      this.layerOffsetX,
      this.layerOffsetY,
      this.layerScale,
      this.layerRotationDeg,
      this.layerOpacity,
      this.layerVisible});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || origSrc != null) {
      map['orig_src'] = Variable<Uint8List>(origSrc);
    }
    if (!nullToAbsent || origBytes != null) {
      map['orig_bytes'] = Variable<int>(origBytes);
    }
    if (!nullToAbsent || origWidth != null) {
      map['orig_width'] = Variable<int>(origWidth);
    }
    if (!nullToAbsent || origHeight != null) {
      map['orig_height'] = Variable<int>(origHeight);
    }
    if (!nullToAbsent || origUniqueColors != null) {
      map['orig_unique_colors'] = Variable<int>(origUniqueColors);
    }
    if (!nullToAbsent || origDpi != null) {
      map['orig_dpi'] = Variable<int>(origDpi);
    }
    if (!nullToAbsent || convSrc != null) {
      map['conv_src'] = Variable<Uint8List>(convSrc);
    }
    if (!nullToAbsent || convBytes != null) {
      map['conv_bytes'] = Variable<int>(convBytes);
    }
    if (!nullToAbsent || convWidth != null) {
      map['conv_width'] = Variable<int>(convWidth);
    }
    if (!nullToAbsent || convHeight != null) {
      map['conv_height'] = Variable<int>(convHeight);
    }
    if (!nullToAbsent || convUniqueColors != null) {
      map['conv_unique_colors'] = Variable<int>(convUniqueColors);
    }
    if (!nullToAbsent || dpi != null) {
      map['dpi'] = Variable<int>(dpi);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || layerOffsetX != null) {
      map['layer_offset_x'] = Variable<double>(layerOffsetX);
    }
    if (!nullToAbsent || layerOffsetY != null) {
      map['layer_offset_y'] = Variable<double>(layerOffsetY);
    }
    if (!nullToAbsent || layerScale != null) {
      map['layer_scale'] = Variable<double>(layerScale);
    }
    if (!nullToAbsent || layerRotationDeg != null) {
      map['layer_rotation_deg'] = Variable<double>(layerRotationDeg);
    }
    if (!nullToAbsent || layerOpacity != null) {
      map['layer_opacity'] = Variable<double>(layerOpacity);
    }
    if (!nullToAbsent || layerVisible != null) {
      map['layer_visible'] = Variable<bool>(layerVisible);
    }
    return map;
  }

  ImagesCompanion toCompanion(bool nullToAbsent) {
    return ImagesCompanion(
      id: Value(id),
      origSrc: origSrc == null && nullToAbsent
          ? const Value.absent()
          : Value(origSrc),
      origBytes: origBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(origBytes),
      origWidth: origWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(origWidth),
      origHeight: origHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(origHeight),
      origUniqueColors: origUniqueColors == null && nullToAbsent
          ? const Value.absent()
          : Value(origUniqueColors),
      origDpi: origDpi == null && nullToAbsent
          ? const Value.absent()
          : Value(origDpi),
      convSrc: convSrc == null && nullToAbsent
          ? const Value.absent()
          : Value(convSrc),
      convBytes: convBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(convBytes),
      convWidth: convWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(convWidth),
      convHeight: convHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(convHeight),
      convUniqueColors: convUniqueColors == null && nullToAbsent
          ? const Value.absent()
          : Value(convUniqueColors),
      dpi: dpi == null && nullToAbsent ? const Value.absent() : Value(dpi),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      layerOffsetX: layerOffsetX == null && nullToAbsent
          ? const Value.absent()
          : Value(layerOffsetX),
      layerOffsetY: layerOffsetY == null && nullToAbsent
          ? const Value.absent()
          : Value(layerOffsetY),
      layerScale: layerScale == null && nullToAbsent
          ? const Value.absent()
          : Value(layerScale),
      layerRotationDeg: layerRotationDeg == null && nullToAbsent
          ? const Value.absent()
          : Value(layerRotationDeg),
      layerOpacity: layerOpacity == null && nullToAbsent
          ? const Value.absent()
          : Value(layerOpacity),
      layerVisible: layerVisible == null && nullToAbsent
          ? const Value.absent()
          : Value(layerVisible),
    );
  }

  factory DbImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbImage(
      id: serializer.fromJson<int>(json['id']),
      origSrc: serializer.fromJson<Uint8List?>(json['origSrc']),
      origBytes: serializer.fromJson<int?>(json['origBytes']),
      origWidth: serializer.fromJson<int?>(json['origWidth']),
      origHeight: serializer.fromJson<int?>(json['origHeight']),
      origUniqueColors: serializer.fromJson<int?>(json['origUniqueColors']),
      origDpi: serializer.fromJson<int?>(json['origDpi']),
      convSrc: serializer.fromJson<Uint8List?>(json['convSrc']),
      convBytes: serializer.fromJson<int?>(json['convBytes']),
      convWidth: serializer.fromJson<int?>(json['convWidth']),
      convHeight: serializer.fromJson<int?>(json['convHeight']),
      convUniqueColors: serializer.fromJson<int?>(json['convUniqueColors']),
      dpi: serializer.fromJson<int?>(json['dpi']),
      thumbnail: serializer.fromJson<Uint8List?>(json['thumbnail']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      layerOffsetX: serializer.fromJson<double?>(json['layerOffsetX']),
      layerOffsetY: serializer.fromJson<double?>(json['layerOffsetY']),
      layerScale: serializer.fromJson<double?>(json['layerScale']),
      layerRotationDeg: serializer.fromJson<double?>(json['layerRotationDeg']),
      layerOpacity: serializer.fromJson<double?>(json['layerOpacity']),
      layerVisible: serializer.fromJson<bool?>(json['layerVisible']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'origSrc': serializer.toJson<Uint8List?>(origSrc),
      'origBytes': serializer.toJson<int?>(origBytes),
      'origWidth': serializer.toJson<int?>(origWidth),
      'origHeight': serializer.toJson<int?>(origHeight),
      'origUniqueColors': serializer.toJson<int?>(origUniqueColors),
      'origDpi': serializer.toJson<int?>(origDpi),
      'convSrc': serializer.toJson<Uint8List?>(convSrc),
      'convBytes': serializer.toJson<int?>(convBytes),
      'convWidth': serializer.toJson<int?>(convWidth),
      'convHeight': serializer.toJson<int?>(convHeight),
      'convUniqueColors': serializer.toJson<int?>(convUniqueColors),
      'dpi': serializer.toJson<int?>(dpi),
      'thumbnail': serializer.toJson<Uint8List?>(thumbnail),
      'mimeType': serializer.toJson<String?>(mimeType),
      'layerOffsetX': serializer.toJson<double?>(layerOffsetX),
      'layerOffsetY': serializer.toJson<double?>(layerOffsetY),
      'layerScale': serializer.toJson<double?>(layerScale),
      'layerRotationDeg': serializer.toJson<double?>(layerRotationDeg),
      'layerOpacity': serializer.toJson<double?>(layerOpacity),
      'layerVisible': serializer.toJson<bool?>(layerVisible),
    };
  }

  DbImage copyWith(
          {int? id,
          Value<Uint8List?> origSrc = const Value.absent(),
          Value<int?> origBytes = const Value.absent(),
          Value<int?> origWidth = const Value.absent(),
          Value<int?> origHeight = const Value.absent(),
          Value<int?> origUniqueColors = const Value.absent(),
          Value<int?> origDpi = const Value.absent(),
          Value<Uint8List?> convSrc = const Value.absent(),
          Value<int?> convBytes = const Value.absent(),
          Value<int?> convWidth = const Value.absent(),
          Value<int?> convHeight = const Value.absent(),
          Value<int?> convUniqueColors = const Value.absent(),
          Value<int?> dpi = const Value.absent(),
          Value<Uint8List?> thumbnail = const Value.absent(),
          Value<String?> mimeType = const Value.absent(),
          Value<double?> layerOffsetX = const Value.absent(),
          Value<double?> layerOffsetY = const Value.absent(),
          Value<double?> layerScale = const Value.absent(),
          Value<double?> layerRotationDeg = const Value.absent(),
          Value<double?> layerOpacity = const Value.absent(),
          Value<bool?> layerVisible = const Value.absent()}) =>
      DbImage(
        id: id ?? this.id,
        origSrc: origSrc.present ? origSrc.value : this.origSrc,
        origBytes: origBytes.present ? origBytes.value : this.origBytes,
        origWidth: origWidth.present ? origWidth.value : this.origWidth,
        origHeight: origHeight.present ? origHeight.value : this.origHeight,
        origUniqueColors: origUniqueColors.present
            ? origUniqueColors.value
            : this.origUniqueColors,
        origDpi: origDpi.present ? origDpi.value : this.origDpi,
        convSrc: convSrc.present ? convSrc.value : this.convSrc,
        convBytes: convBytes.present ? convBytes.value : this.convBytes,
        convWidth: convWidth.present ? convWidth.value : this.convWidth,
        convHeight: convHeight.present ? convHeight.value : this.convHeight,
        convUniqueColors: convUniqueColors.present
            ? convUniqueColors.value
            : this.convUniqueColors,
        dpi: dpi.present ? dpi.value : this.dpi,
        thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        layerOffsetX:
            layerOffsetX.present ? layerOffsetX.value : this.layerOffsetX,
        layerOffsetY:
            layerOffsetY.present ? layerOffsetY.value : this.layerOffsetY,
        layerScale: layerScale.present ? layerScale.value : this.layerScale,
        layerRotationDeg: layerRotationDeg.present
            ? layerRotationDeg.value
            : this.layerRotationDeg,
        layerOpacity:
            layerOpacity.present ? layerOpacity.value : this.layerOpacity,
        layerVisible:
            layerVisible.present ? layerVisible.value : this.layerVisible,
      );
  DbImage copyWithCompanion(ImagesCompanion data) {
    return DbImage(
      id: data.id.present ? data.id.value : this.id,
      origSrc: data.origSrc.present ? data.origSrc.value : this.origSrc,
      origBytes: data.origBytes.present ? data.origBytes.value : this.origBytes,
      origWidth: data.origWidth.present ? data.origWidth.value : this.origWidth,
      origHeight:
          data.origHeight.present ? data.origHeight.value : this.origHeight,
      origUniqueColors: data.origUniqueColors.present
          ? data.origUniqueColors.value
          : this.origUniqueColors,
      origDpi: data.origDpi.present ? data.origDpi.value : this.origDpi,
      convSrc: data.convSrc.present ? data.convSrc.value : this.convSrc,
      convBytes: data.convBytes.present ? data.convBytes.value : this.convBytes,
      convWidth: data.convWidth.present ? data.convWidth.value : this.convWidth,
      convHeight:
          data.convHeight.present ? data.convHeight.value : this.convHeight,
      convUniqueColors: data.convUniqueColors.present
          ? data.convUniqueColors.value
          : this.convUniqueColors,
      dpi: data.dpi.present ? data.dpi.value : this.dpi,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      layerOffsetX: data.layerOffsetX.present
          ? data.layerOffsetX.value
          : this.layerOffsetX,
      layerOffsetY: data.layerOffsetY.present
          ? data.layerOffsetY.value
          : this.layerOffsetY,
      layerScale:
          data.layerScale.present ? data.layerScale.value : this.layerScale,
      layerRotationDeg: data.layerRotationDeg.present
          ? data.layerRotationDeg.value
          : this.layerRotationDeg,
      layerOpacity: data.layerOpacity.present
          ? data.layerOpacity.value
          : this.layerOpacity,
      layerVisible: data.layerVisible.present
          ? data.layerVisible.value
          : this.layerVisible,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbImage(')
          ..write('id: $id, ')
          ..write('origSrc: $origSrc, ')
          ..write('origBytes: $origBytes, ')
          ..write('origWidth: $origWidth, ')
          ..write('origHeight: $origHeight, ')
          ..write('origUniqueColors: $origUniqueColors, ')
          ..write('origDpi: $origDpi, ')
          ..write('convSrc: $convSrc, ')
          ..write('convBytes: $convBytes, ')
          ..write('convWidth: $convWidth, ')
          ..write('convHeight: $convHeight, ')
          ..write('convUniqueColors: $convUniqueColors, ')
          ..write('dpi: $dpi, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('mimeType: $mimeType, ')
          ..write('layerOffsetX: $layerOffsetX, ')
          ..write('layerOffsetY: $layerOffsetY, ')
          ..write('layerScale: $layerScale, ')
          ..write('layerRotationDeg: $layerRotationDeg, ')
          ..write('layerOpacity: $layerOpacity, ')
          ..write('layerVisible: $layerVisible')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        $driftBlobEquality.hash(origSrc),
        origBytes,
        origWidth,
        origHeight,
        origUniqueColors,
        origDpi,
        $driftBlobEquality.hash(convSrc),
        convBytes,
        convWidth,
        convHeight,
        convUniqueColors,
        dpi,
        $driftBlobEquality.hash(thumbnail),
        mimeType,
        layerOffsetX,
        layerOffsetY,
        layerScale,
        layerRotationDeg,
        layerOpacity,
        layerVisible
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbImage &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.origSrc, this.origSrc) &&
          other.origBytes == this.origBytes &&
          other.origWidth == this.origWidth &&
          other.origHeight == this.origHeight &&
          other.origUniqueColors == this.origUniqueColors &&
          other.origDpi == this.origDpi &&
          $driftBlobEquality.equals(other.convSrc, this.convSrc) &&
          other.convBytes == this.convBytes &&
          other.convWidth == this.convWidth &&
          other.convHeight == this.convHeight &&
          other.convUniqueColors == this.convUniqueColors &&
          other.dpi == this.dpi &&
          $driftBlobEquality.equals(other.thumbnail, this.thumbnail) &&
          other.mimeType == this.mimeType &&
          other.layerOffsetX == this.layerOffsetX &&
          other.layerOffsetY == this.layerOffsetY &&
          other.layerScale == this.layerScale &&
          other.layerRotationDeg == this.layerRotationDeg &&
          other.layerOpacity == this.layerOpacity &&
          other.layerVisible == this.layerVisible);
}

class ImagesCompanion extends UpdateCompanion<DbImage> {
  final Value<int> id;
  final Value<Uint8List?> origSrc;
  final Value<int?> origBytes;
  final Value<int?> origWidth;
  final Value<int?> origHeight;
  final Value<int?> origUniqueColors;
  final Value<int?> origDpi;
  final Value<Uint8List?> convSrc;
  final Value<int?> convBytes;
  final Value<int?> convWidth;
  final Value<int?> convHeight;
  final Value<int?> convUniqueColors;
  final Value<int?> dpi;
  final Value<Uint8List?> thumbnail;
  final Value<String?> mimeType;
  final Value<double?> layerOffsetX;
  final Value<double?> layerOffsetY;
  final Value<double?> layerScale;
  final Value<double?> layerRotationDeg;
  final Value<double?> layerOpacity;
  final Value<bool?> layerVisible;
  const ImagesCompanion({
    this.id = const Value.absent(),
    this.origSrc = const Value.absent(),
    this.origBytes = const Value.absent(),
    this.origWidth = const Value.absent(),
    this.origHeight = const Value.absent(),
    this.origUniqueColors = const Value.absent(),
    this.origDpi = const Value.absent(),
    this.convSrc = const Value.absent(),
    this.convBytes = const Value.absent(),
    this.convWidth = const Value.absent(),
    this.convHeight = const Value.absent(),
    this.convUniqueColors = const Value.absent(),
    this.dpi = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.layerOffsetX = const Value.absent(),
    this.layerOffsetY = const Value.absent(),
    this.layerScale = const Value.absent(),
    this.layerRotationDeg = const Value.absent(),
    this.layerOpacity = const Value.absent(),
    this.layerVisible = const Value.absent(),
  });
  ImagesCompanion.insert({
    this.id = const Value.absent(),
    this.origSrc = const Value.absent(),
    this.origBytes = const Value.absent(),
    this.origWidth = const Value.absent(),
    this.origHeight = const Value.absent(),
    this.origUniqueColors = const Value.absent(),
    this.origDpi = const Value.absent(),
    this.convSrc = const Value.absent(),
    this.convBytes = const Value.absent(),
    this.convWidth = const Value.absent(),
    this.convHeight = const Value.absent(),
    this.convUniqueColors = const Value.absent(),
    this.dpi = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.layerOffsetX = const Value.absent(),
    this.layerOffsetY = const Value.absent(),
    this.layerScale = const Value.absent(),
    this.layerRotationDeg = const Value.absent(),
    this.layerOpacity = const Value.absent(),
    this.layerVisible = const Value.absent(),
  });
  static Insertable<DbImage> custom({
    Expression<int>? id,
    Expression<Uint8List>? origSrc,
    Expression<int>? origBytes,
    Expression<int>? origWidth,
    Expression<int>? origHeight,
    Expression<int>? origUniqueColors,
    Expression<int>? origDpi,
    Expression<Uint8List>? convSrc,
    Expression<int>? convBytes,
    Expression<int>? convWidth,
    Expression<int>? convHeight,
    Expression<int>? convUniqueColors,
    Expression<int>? dpi,
    Expression<Uint8List>? thumbnail,
    Expression<String>? mimeType,
    Expression<double>? layerOffsetX,
    Expression<double>? layerOffsetY,
    Expression<double>? layerScale,
    Expression<double>? layerRotationDeg,
    Expression<double>? layerOpacity,
    Expression<bool>? layerVisible,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origSrc != null) 'orig_src': origSrc,
      if (origBytes != null) 'orig_bytes': origBytes,
      if (origWidth != null) 'orig_width': origWidth,
      if (origHeight != null) 'orig_height': origHeight,
      if (origUniqueColors != null) 'orig_unique_colors': origUniqueColors,
      if (origDpi != null) 'orig_dpi': origDpi,
      if (convSrc != null) 'conv_src': convSrc,
      if (convBytes != null) 'conv_bytes': convBytes,
      if (convWidth != null) 'conv_width': convWidth,
      if (convHeight != null) 'conv_height': convHeight,
      if (convUniqueColors != null) 'conv_unique_colors': convUniqueColors,
      if (dpi != null) 'dpi': dpi,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (mimeType != null) 'mime_type': mimeType,
      if (layerOffsetX != null) 'layer_offset_x': layerOffsetX,
      if (layerOffsetY != null) 'layer_offset_y': layerOffsetY,
      if (layerScale != null) 'layer_scale': layerScale,
      if (layerRotationDeg != null) 'layer_rotation_deg': layerRotationDeg,
      if (layerOpacity != null) 'layer_opacity': layerOpacity,
      if (layerVisible != null) 'layer_visible': layerVisible,
    });
  }

  ImagesCompanion copyWith(
      {Value<int>? id,
      Value<Uint8List?>? origSrc,
      Value<int?>? origBytes,
      Value<int?>? origWidth,
      Value<int?>? origHeight,
      Value<int?>? origUniqueColors,
      Value<int?>? origDpi,
      Value<Uint8List?>? convSrc,
      Value<int?>? convBytes,
      Value<int?>? convWidth,
      Value<int?>? convHeight,
      Value<int?>? convUniqueColors,
      Value<int?>? dpi,
      Value<Uint8List?>? thumbnail,
      Value<String?>? mimeType,
      Value<double?>? layerOffsetX,
      Value<double?>? layerOffsetY,
      Value<double?>? layerScale,
      Value<double?>? layerRotationDeg,
      Value<double?>? layerOpacity,
      Value<bool?>? layerVisible}) {
    return ImagesCompanion(
      id: id ?? this.id,
      origSrc: origSrc ?? this.origSrc,
      origBytes: origBytes ?? this.origBytes,
      origWidth: origWidth ?? this.origWidth,
      origHeight: origHeight ?? this.origHeight,
      origUniqueColors: origUniqueColors ?? this.origUniqueColors,
      origDpi: origDpi ?? this.origDpi,
      convSrc: convSrc ?? this.convSrc,
      convBytes: convBytes ?? this.convBytes,
      convWidth: convWidth ?? this.convWidth,
      convHeight: convHeight ?? this.convHeight,
      convUniqueColors: convUniqueColors ?? this.convUniqueColors,
      dpi: dpi ?? this.dpi,
      thumbnail: thumbnail ?? this.thumbnail,
      mimeType: mimeType ?? this.mimeType,
      layerOffsetX: layerOffsetX ?? this.layerOffsetX,
      layerOffsetY: layerOffsetY ?? this.layerOffsetY,
      layerScale: layerScale ?? this.layerScale,
      layerRotationDeg: layerRotationDeg ?? this.layerRotationDeg,
      layerOpacity: layerOpacity ?? this.layerOpacity,
      layerVisible: layerVisible ?? this.layerVisible,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (origSrc.present) {
      map['orig_src'] = Variable<Uint8List>(origSrc.value);
    }
    if (origBytes.present) {
      map['orig_bytes'] = Variable<int>(origBytes.value);
    }
    if (origWidth.present) {
      map['orig_width'] = Variable<int>(origWidth.value);
    }
    if (origHeight.present) {
      map['orig_height'] = Variable<int>(origHeight.value);
    }
    if (origUniqueColors.present) {
      map['orig_unique_colors'] = Variable<int>(origUniqueColors.value);
    }
    if (origDpi.present) {
      map['orig_dpi'] = Variable<int>(origDpi.value);
    }
    if (convSrc.present) {
      map['conv_src'] = Variable<Uint8List>(convSrc.value);
    }
    if (convBytes.present) {
      map['conv_bytes'] = Variable<int>(convBytes.value);
    }
    if (convWidth.present) {
      map['conv_width'] = Variable<int>(convWidth.value);
    }
    if (convHeight.present) {
      map['conv_height'] = Variable<int>(convHeight.value);
    }
    if (convUniqueColors.present) {
      map['conv_unique_colors'] = Variable<int>(convUniqueColors.value);
    }
    if (dpi.present) {
      map['dpi'] = Variable<int>(dpi.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (layerOffsetX.present) {
      map['layer_offset_x'] = Variable<double>(layerOffsetX.value);
    }
    if (layerOffsetY.present) {
      map['layer_offset_y'] = Variable<double>(layerOffsetY.value);
    }
    if (layerScale.present) {
      map['layer_scale'] = Variable<double>(layerScale.value);
    }
    if (layerRotationDeg.present) {
      map['layer_rotation_deg'] = Variable<double>(layerRotationDeg.value);
    }
    if (layerOpacity.present) {
      map['layer_opacity'] = Variable<double>(layerOpacity.value);
    }
    if (layerVisible.present) {
      map['layer_visible'] = Variable<bool>(layerVisible.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('id: $id, ')
          ..write('origSrc: $origSrc, ')
          ..write('origBytes: $origBytes, ')
          ..write('origWidth: $origWidth, ')
          ..write('origHeight: $origHeight, ')
          ..write('origUniqueColors: $origUniqueColors, ')
          ..write('origDpi: $origDpi, ')
          ..write('convSrc: $convSrc, ')
          ..write('convBytes: $convBytes, ')
          ..write('convWidth: $convWidth, ')
          ..write('convHeight: $convHeight, ')
          ..write('convUniqueColors: $convUniqueColors, ')
          ..write('dpi: $dpi, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('mimeType: $mimeType, ')
          ..write('layerOffsetX: $layerOffsetX, ')
          ..write('layerOffsetY: $layerOffsetY, ')
          ..write('layerScale: $layerScale, ')
          ..write('layerRotationDeg: $layerRotationDeg, ')
          ..write('layerOpacity: $layerOpacity, ')
          ..write('layerVisible: $layerVisible')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, DbProject> {
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<int> imageId = GeneratedColumn<int>(
      'image_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES images (id) ON DELETE SET NULL'));
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendorIdMeta =
      const VerificationMeta('vendorId');
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
      'vendor_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vendors (id) ON DELETE SET NULL'));
  static const VerificationMeta _canvasWidthPxMeta =
      const VerificationMeta('canvasWidthPx');
  @override
  late final GeneratedColumn<int> canvasWidthPx = GeneratedColumn<int>(
      'canvas_width_px', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _canvasHeightPxMeta =
      const VerificationMeta('canvasHeightPx');
  @override
  late final GeneratedColumn<int> canvasHeightPx = GeneratedColumn<int>(
      'canvas_height_px', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _canvasWidthValueMeta =
      const VerificationMeta('canvasWidthValue');
  @override
  late final GeneratedColumn<double> canvasWidthValue = GeneratedColumn<double>(
      'canvas_width_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(100.0));
  static const VerificationMeta _canvasWidthUnitMeta =
      const VerificationMeta('canvasWidthUnit');
  @override
  late final GeneratedColumn<String> canvasWidthUnit = GeneratedColumn<String>(
      'canvas_width_unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mm'));
  static const VerificationMeta _canvasHeightValueMeta =
      const VerificationMeta('canvasHeightValue');
  @override
  late final GeneratedColumn<double> canvasHeightValue =
      GeneratedColumn<double>('canvas_height_value', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(100.0));
  static const VerificationMeta _canvasHeightUnitMeta =
      const VerificationMeta('canvasHeightUnit');
  @override
  late final GeneratedColumn<String> canvasHeightUnit = GeneratedColumn<String>(
      'canvas_height_unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mm'));
  static const VerificationMeta _gridCellWidthValueMeta =
      const VerificationMeta('gridCellWidthValue');
  @override
  late final GeneratedColumn<double> gridCellWidthValue =
      GeneratedColumn<double>('grid_cell_width_value', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(10.0));
  static const VerificationMeta _gridCellWidthUnitMeta =
      const VerificationMeta('gridCellWidthUnit');
  @override
  late final GeneratedColumn<String> gridCellWidthUnit =
      GeneratedColumn<String>('grid_cell_width_unit', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('mm'));
  static const VerificationMeta _gridCellHeightValueMeta =
      const VerificationMeta('gridCellHeightValue');
  @override
  late final GeneratedColumn<double> gridCellHeightValue =
      GeneratedColumn<double>('grid_cell_height_value', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(10.0));
  static const VerificationMeta _gridCellHeightUnitMeta =
      const VerificationMeta('gridCellHeightUnit');
  @override
  late final GeneratedColumn<String> gridCellHeightUnit =
      GeneratedColumn<String>('grid_cell_height_unit', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('mm'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        author,
        status,
        createdAt,
        updatedAt,
        imageId,
        model,
        vendorId,
        canvasWidthPx,
        canvasHeightPx,
        canvasWidthValue,
        canvasWidthUnit,
        canvasHeightValue,
        canvasHeightUnit,
        gridCellWidthValue,
        gridCellWidthUnit,
        gridCellHeightValue,
        gridCellHeightUnit
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<DbProject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    }
    if (data.containsKey('canvas_width_px')) {
      context.handle(
          _canvasWidthPxMeta,
          canvasWidthPx.isAcceptableOrUnknown(
              data['canvas_width_px']!, _canvasWidthPxMeta));
    }
    if (data.containsKey('canvas_height_px')) {
      context.handle(
          _canvasHeightPxMeta,
          canvasHeightPx.isAcceptableOrUnknown(
              data['canvas_height_px']!, _canvasHeightPxMeta));
    }
    if (data.containsKey('canvas_width_value')) {
      context.handle(
          _canvasWidthValueMeta,
          canvasWidthValue.isAcceptableOrUnknown(
              data['canvas_width_value']!, _canvasWidthValueMeta));
    }
    if (data.containsKey('canvas_width_unit')) {
      context.handle(
          _canvasWidthUnitMeta,
          canvasWidthUnit.isAcceptableOrUnknown(
              data['canvas_width_unit']!, _canvasWidthUnitMeta));
    }
    if (data.containsKey('canvas_height_value')) {
      context.handle(
          _canvasHeightValueMeta,
          canvasHeightValue.isAcceptableOrUnknown(
              data['canvas_height_value']!, _canvasHeightValueMeta));
    }
    if (data.containsKey('canvas_height_unit')) {
      context.handle(
          _canvasHeightUnitMeta,
          canvasHeightUnit.isAcceptableOrUnknown(
              data['canvas_height_unit']!, _canvasHeightUnitMeta));
    }
    if (data.containsKey('grid_cell_width_value')) {
      context.handle(
          _gridCellWidthValueMeta,
          gridCellWidthValue.isAcceptableOrUnknown(
              data['grid_cell_width_value']!, _gridCellWidthValueMeta));
    }
    if (data.containsKey('grid_cell_width_unit')) {
      context.handle(
          _gridCellWidthUnitMeta,
          gridCellWidthUnit.isAcceptableOrUnknown(
              data['grid_cell_width_unit']!, _gridCellWidthUnitMeta));
    }
    if (data.containsKey('grid_cell_height_value')) {
      context.handle(
          _gridCellHeightValueMeta,
          gridCellHeightValue.isAcceptableOrUnknown(
              data['grid_cell_height_value']!, _gridCellHeightValueMeta));
    }
    if (data.containsKey('grid_cell_height_unit')) {
      context.handle(
          _gridCellHeightUnitMeta,
          gridCellHeightUnit.isAcceptableOrUnknown(
              data['grid_cell_height_unit']!, _gridCellHeightUnitMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}image_id']),
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model']),
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id']),
      canvasWidthPx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}canvas_width_px'])!,
      canvasHeightPx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}canvas_height_px'])!,
      canvasWidthValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}canvas_width_value'])!,
      canvasWidthUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}canvas_width_unit'])!,
      canvasHeightValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}canvas_height_value'])!,
      canvasHeightUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}canvas_height_unit'])!,
      gridCellWidthValue: attachedDatabase.typeMapping.read(DriftSqlType.double,
          data['${effectivePrefix}grid_cell_width_value'])!,
      gridCellWidthUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}grid_cell_width_unit'])!,
      gridCellHeightValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}grid_cell_height_value'])!,
      gridCellHeightUnit: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}grid_cell_height_unit'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class DbProject extends DataClass implements Insertable<DbProject> {
  final int id;
  final String title;
  final String? author;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int? imageId;
  final String? model;
  final int? vendorId;
  final int canvasWidthPx;
  final int canvasHeightPx;
  final double canvasWidthValue;
  final String canvasWidthUnit;
  final double canvasHeightValue;
  final String canvasHeightUnit;
  final double gridCellWidthValue;
  final String gridCellWidthUnit;
  final double gridCellHeightValue;
  final String gridCellHeightUnit;
  const DbProject(
      {required this.id,
      required this.title,
      this.author,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.imageId,
      this.model,
      this.vendorId,
      required this.canvasWidthPx,
      required this.canvasHeightPx,
      required this.canvasWidthValue,
      required this.canvasWidthUnit,
      required this.canvasHeightValue,
      required this.canvasHeightUnit,
      required this.gridCellWidthValue,
      required this.gridCellWidthUnit,
      required this.gridCellHeightValue,
      required this.gridCellHeightUnit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<int>(imageId);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || vendorId != null) {
      map['vendor_id'] = Variable<int>(vendorId);
    }
    map['canvas_width_px'] = Variable<int>(canvasWidthPx);
    map['canvas_height_px'] = Variable<int>(canvasHeightPx);
    map['canvas_width_value'] = Variable<double>(canvasWidthValue);
    map['canvas_width_unit'] = Variable<String>(canvasWidthUnit);
    map['canvas_height_value'] = Variable<double>(canvasHeightValue);
    map['canvas_height_unit'] = Variable<String>(canvasHeightUnit);
    map['grid_cell_width_value'] = Variable<double>(gridCellWidthValue);
    map['grid_cell_width_unit'] = Variable<String>(gridCellWidthUnit);
    map['grid_cell_height_value'] = Variable<double>(gridCellHeightValue);
    map['grid_cell_height_unit'] = Variable<String>(gridCellHeightUnit);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
      model:
          model == null && nullToAbsent ? const Value.absent() : Value(model),
      vendorId: vendorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorId),
      canvasWidthPx: Value(canvasWidthPx),
      canvasHeightPx: Value(canvasHeightPx),
      canvasWidthValue: Value(canvasWidthValue),
      canvasWidthUnit: Value(canvasWidthUnit),
      canvasHeightValue: Value(canvasHeightValue),
      canvasHeightUnit: Value(canvasHeightUnit),
      gridCellWidthValue: Value(gridCellWidthValue),
      gridCellWidthUnit: Value(gridCellWidthUnit),
      gridCellHeightValue: Value(gridCellHeightValue),
      gridCellHeightUnit: Value(gridCellHeightUnit),
    );
  }

  factory DbProject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProject(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      imageId: serializer.fromJson<int?>(json['imageId']),
      model: serializer.fromJson<String?>(json['model']),
      vendorId: serializer.fromJson<int?>(json['vendorId']),
      canvasWidthPx: serializer.fromJson<int>(json['canvasWidthPx']),
      canvasHeightPx: serializer.fromJson<int>(json['canvasHeightPx']),
      canvasWidthValue: serializer.fromJson<double>(json['canvasWidthValue']),
      canvasWidthUnit: serializer.fromJson<String>(json['canvasWidthUnit']),
      canvasHeightValue: serializer.fromJson<double>(json['canvasHeightValue']),
      canvasHeightUnit: serializer.fromJson<String>(json['canvasHeightUnit']),
      gridCellWidthValue:
          serializer.fromJson<double>(json['gridCellWidthValue']),
      gridCellWidthUnit: serializer.fromJson<String>(json['gridCellWidthUnit']),
      gridCellHeightValue:
          serializer.fromJson<double>(json['gridCellHeightValue']),
      gridCellHeightUnit:
          serializer.fromJson<String>(json['gridCellHeightUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'imageId': serializer.toJson<int?>(imageId),
      'model': serializer.toJson<String?>(model),
      'vendorId': serializer.toJson<int?>(vendorId),
      'canvasWidthPx': serializer.toJson<int>(canvasWidthPx),
      'canvasHeightPx': serializer.toJson<int>(canvasHeightPx),
      'canvasWidthValue': serializer.toJson<double>(canvasWidthValue),
      'canvasWidthUnit': serializer.toJson<String>(canvasWidthUnit),
      'canvasHeightValue': serializer.toJson<double>(canvasHeightValue),
      'canvasHeightUnit': serializer.toJson<String>(canvasHeightUnit),
      'gridCellWidthValue': serializer.toJson<double>(gridCellWidthValue),
      'gridCellWidthUnit': serializer.toJson<String>(gridCellWidthUnit),
      'gridCellHeightValue': serializer.toJson<double>(gridCellHeightValue),
      'gridCellHeightUnit': serializer.toJson<String>(gridCellHeightUnit),
    };
  }

  DbProject copyWith(
          {int? id,
          String? title,
          Value<String?> author = const Value.absent(),
          String? status,
          int? createdAt,
          int? updatedAt,
          Value<int?> imageId = const Value.absent(),
          Value<String?> model = const Value.absent(),
          Value<int?> vendorId = const Value.absent(),
          int? canvasWidthPx,
          int? canvasHeightPx,
          double? canvasWidthValue,
          String? canvasWidthUnit,
          double? canvasHeightValue,
          String? canvasHeightUnit,
          double? gridCellWidthValue,
          String? gridCellWidthUnit,
          double? gridCellHeightValue,
          String? gridCellHeightUnit}) =>
      DbProject(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author.present ? author.value : this.author,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        imageId: imageId.present ? imageId.value : this.imageId,
        model: model.present ? model.value : this.model,
        vendorId: vendorId.present ? vendorId.value : this.vendorId,
        canvasWidthPx: canvasWidthPx ?? this.canvasWidthPx,
        canvasHeightPx: canvasHeightPx ?? this.canvasHeightPx,
        canvasWidthValue: canvasWidthValue ?? this.canvasWidthValue,
        canvasWidthUnit: canvasWidthUnit ?? this.canvasWidthUnit,
        canvasHeightValue: canvasHeightValue ?? this.canvasHeightValue,
        canvasHeightUnit: canvasHeightUnit ?? this.canvasHeightUnit,
        gridCellWidthValue: gridCellWidthValue ?? this.gridCellWidthValue,
        gridCellWidthUnit: gridCellWidthUnit ?? this.gridCellWidthUnit,
        gridCellHeightValue: gridCellHeightValue ?? this.gridCellHeightValue,
        gridCellHeightUnit: gridCellHeightUnit ?? this.gridCellHeightUnit,
      );
  DbProject copyWithCompanion(ProjectsCompanion data) {
    return DbProject(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      model: data.model.present ? data.model.value : this.model,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      canvasWidthPx: data.canvasWidthPx.present
          ? data.canvasWidthPx.value
          : this.canvasWidthPx,
      canvasHeightPx: data.canvasHeightPx.present
          ? data.canvasHeightPx.value
          : this.canvasHeightPx,
      canvasWidthValue: data.canvasWidthValue.present
          ? data.canvasWidthValue.value
          : this.canvasWidthValue,
      canvasWidthUnit: data.canvasWidthUnit.present
          ? data.canvasWidthUnit.value
          : this.canvasWidthUnit,
      canvasHeightValue: data.canvasHeightValue.present
          ? data.canvasHeightValue.value
          : this.canvasHeightValue,
      canvasHeightUnit: data.canvasHeightUnit.present
          ? data.canvasHeightUnit.value
          : this.canvasHeightUnit,
      gridCellWidthValue: data.gridCellWidthValue.present
          ? data.gridCellWidthValue.value
          : this.gridCellWidthValue,
      gridCellWidthUnit: data.gridCellWidthUnit.present
          ? data.gridCellWidthUnit.value
          : this.gridCellWidthUnit,
      gridCellHeightValue: data.gridCellHeightValue.present
          ? data.gridCellHeightValue.value
          : this.gridCellHeightValue,
      gridCellHeightUnit: data.gridCellHeightUnit.present
          ? data.gridCellHeightUnit.value
          : this.gridCellHeightUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProject(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('imageId: $imageId, ')
          ..write('model: $model, ')
          ..write('vendorId: $vendorId, ')
          ..write('canvasWidthPx: $canvasWidthPx, ')
          ..write('canvasHeightPx: $canvasHeightPx, ')
          ..write('canvasWidthValue: $canvasWidthValue, ')
          ..write('canvasWidthUnit: $canvasWidthUnit, ')
          ..write('canvasHeightValue: $canvasHeightValue, ')
          ..write('canvasHeightUnit: $canvasHeightUnit, ')
          ..write('gridCellWidthValue: $gridCellWidthValue, ')
          ..write('gridCellWidthUnit: $gridCellWidthUnit, ')
          ..write('gridCellHeightValue: $gridCellHeightValue, ')
          ..write('gridCellHeightUnit: $gridCellHeightUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      author,
      status,
      createdAt,
      updatedAt,
      imageId,
      model,
      vendorId,
      canvasWidthPx,
      canvasHeightPx,
      canvasWidthValue,
      canvasWidthUnit,
      canvasHeightValue,
      canvasHeightUnit,
      gridCellWidthValue,
      gridCellWidthUnit,
      gridCellHeightValue,
      gridCellHeightUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProject &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.imageId == this.imageId &&
          other.model == this.model &&
          other.vendorId == this.vendorId &&
          other.canvasWidthPx == this.canvasWidthPx &&
          other.canvasHeightPx == this.canvasHeightPx &&
          other.canvasWidthValue == this.canvasWidthValue &&
          other.canvasWidthUnit == this.canvasWidthUnit &&
          other.canvasHeightValue == this.canvasHeightValue &&
          other.canvasHeightUnit == this.canvasHeightUnit &&
          other.gridCellWidthValue == this.gridCellWidthValue &&
          other.gridCellWidthUnit == this.gridCellWidthUnit &&
          other.gridCellHeightValue == this.gridCellHeightValue &&
          other.gridCellHeightUnit == this.gridCellHeightUnit);
}

class ProjectsCompanion extends UpdateCompanion<DbProject> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> imageId;
  final Value<String?> model;
  final Value<int?> vendorId;
  final Value<int> canvasWidthPx;
  final Value<int> canvasHeightPx;
  final Value<double> canvasWidthValue;
  final Value<String> canvasWidthUnit;
  final Value<double> canvasHeightValue;
  final Value<String> canvasHeightUnit;
  final Value<double> gridCellWidthValue;
  final Value<String> gridCellWidthUnit;
  final Value<double> gridCellHeightValue;
  final Value<String> gridCellHeightUnit;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.imageId = const Value.absent(),
    this.model = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.canvasWidthPx = const Value.absent(),
    this.canvasHeightPx = const Value.absent(),
    this.canvasWidthValue = const Value.absent(),
    this.canvasWidthUnit = const Value.absent(),
    this.canvasHeightValue = const Value.absent(),
    this.canvasHeightUnit = const Value.absent(),
    this.gridCellWidthValue = const Value.absent(),
    this.gridCellWidthUnit = const Value.absent(),
    this.gridCellHeightValue = const Value.absent(),
    this.gridCellHeightUnit = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.imageId = const Value.absent(),
    this.model = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.canvasWidthPx = const Value.absent(),
    this.canvasHeightPx = const Value.absent(),
    this.canvasWidthValue = const Value.absent(),
    this.canvasWidthUnit = const Value.absent(),
    this.canvasHeightValue = const Value.absent(),
    this.canvasHeightUnit = const Value.absent(),
    this.gridCellWidthValue = const Value.absent(),
    this.gridCellWidthUnit = const Value.absent(),
    this.gridCellHeightValue = const Value.absent(),
    this.gridCellHeightUnit = const Value.absent(),
  })  : title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbProject> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? imageId,
    Expression<String>? model,
    Expression<int>? vendorId,
    Expression<int>? canvasWidthPx,
    Expression<int>? canvasHeightPx,
    Expression<double>? canvasWidthValue,
    Expression<String>? canvasWidthUnit,
    Expression<double>? canvasHeightValue,
    Expression<String>? canvasHeightUnit,
    Expression<double>? gridCellWidthValue,
    Expression<String>? gridCellWidthUnit,
    Expression<double>? gridCellHeightValue,
    Expression<String>? gridCellHeightUnit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (imageId != null) 'image_id': imageId,
      if (model != null) 'model': model,
      if (vendorId != null) 'vendor_id': vendorId,
      if (canvasWidthPx != null) 'canvas_width_px': canvasWidthPx,
      if (canvasHeightPx != null) 'canvas_height_px': canvasHeightPx,
      if (canvasWidthValue != null) 'canvas_width_value': canvasWidthValue,
      if (canvasWidthUnit != null) 'canvas_width_unit': canvasWidthUnit,
      if (canvasHeightValue != null) 'canvas_height_value': canvasHeightValue,
      if (canvasHeightUnit != null) 'canvas_height_unit': canvasHeightUnit,
      if (gridCellWidthValue != null)
        'grid_cell_width_value': gridCellWidthValue,
      if (gridCellWidthUnit != null) 'grid_cell_width_unit': gridCellWidthUnit,
      if (gridCellHeightValue != null)
        'grid_cell_height_value': gridCellHeightValue,
      if (gridCellHeightUnit != null)
        'grid_cell_height_unit': gridCellHeightUnit,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? author,
      Value<String>? status,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? imageId,
      Value<String?>? model,
      Value<int?>? vendorId,
      Value<int>? canvasWidthPx,
      Value<int>? canvasHeightPx,
      Value<double>? canvasWidthValue,
      Value<String>? canvasWidthUnit,
      Value<double>? canvasHeightValue,
      Value<String>? canvasHeightUnit,
      Value<double>? gridCellWidthValue,
      Value<String>? gridCellWidthUnit,
      Value<double>? gridCellHeightValue,
      Value<String>? gridCellHeightUnit}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageId: imageId ?? this.imageId,
      model: model ?? this.model,
      vendorId: vendorId ?? this.vendorId,
      canvasWidthPx: canvasWidthPx ?? this.canvasWidthPx,
      canvasHeightPx: canvasHeightPx ?? this.canvasHeightPx,
      canvasWidthValue: canvasWidthValue ?? this.canvasWidthValue,
      canvasWidthUnit: canvasWidthUnit ?? this.canvasWidthUnit,
      canvasHeightValue: canvasHeightValue ?? this.canvasHeightValue,
      canvasHeightUnit: canvasHeightUnit ?? this.canvasHeightUnit,
      gridCellWidthValue: gridCellWidthValue ?? this.gridCellWidthValue,
      gridCellWidthUnit: gridCellWidthUnit ?? this.gridCellWidthUnit,
      gridCellHeightValue: gridCellHeightValue ?? this.gridCellHeightValue,
      gridCellHeightUnit: gridCellHeightUnit ?? this.gridCellHeightUnit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<int>(imageId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (canvasWidthPx.present) {
      map['canvas_width_px'] = Variable<int>(canvasWidthPx.value);
    }
    if (canvasHeightPx.present) {
      map['canvas_height_px'] = Variable<int>(canvasHeightPx.value);
    }
    if (canvasWidthValue.present) {
      map['canvas_width_value'] = Variable<double>(canvasWidthValue.value);
    }
    if (canvasWidthUnit.present) {
      map['canvas_width_unit'] = Variable<String>(canvasWidthUnit.value);
    }
    if (canvasHeightValue.present) {
      map['canvas_height_value'] = Variable<double>(canvasHeightValue.value);
    }
    if (canvasHeightUnit.present) {
      map['canvas_height_unit'] = Variable<String>(canvasHeightUnit.value);
    }
    if (gridCellWidthValue.present) {
      map['grid_cell_width_value'] = Variable<double>(gridCellWidthValue.value);
    }
    if (gridCellWidthUnit.present) {
      map['grid_cell_width_unit'] = Variable<String>(gridCellWidthUnit.value);
    }
    if (gridCellHeightValue.present) {
      map['grid_cell_height_value'] =
          Variable<double>(gridCellHeightValue.value);
    }
    if (gridCellHeightUnit.present) {
      map['grid_cell_height_unit'] = Variable<String>(gridCellHeightUnit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('imageId: $imageId, ')
          ..write('model: $model, ')
          ..write('vendorId: $vendorId, ')
          ..write('canvasWidthPx: $canvasWidthPx, ')
          ..write('canvasHeightPx: $canvasHeightPx, ')
          ..write('canvasWidthValue: $canvasWidthValue, ')
          ..write('canvasWidthUnit: $canvasWidthUnit, ')
          ..write('canvasHeightValue: $canvasHeightValue, ')
          ..write('canvasHeightUnit: $canvasHeightUnit, ')
          ..write('gridCellWidthValue: $gridCellWidthValue, ')
          ..write('gridCellWidthUnit: $gridCellWidthUnit, ')
          ..write('gridCellHeightValue: $gridCellHeightValue, ')
          ..write('gridCellHeightUnit: $gridCellHeightUnit')
          ..write(')'))
        .toString();
  }
}

class $LegoColorsTable extends LegoColors
    with TableInfo<$LegoColorsTable, DbLegoColor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegoColorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _blColorIdMeta =
      const VerificationMeta('blColorId');
  @override
  late final GeneratedColumn<int> blColorId = GeneratedColumn<int>(
      'bl_color_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rgbHexMeta = const VerificationMeta('rgbHex');
  @override
  late final GeneratedColumn<String> rgbHex = GeneratedColumn<String>(
      'rgb_hex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startYearMeta =
      const VerificationMeta('startYear');
  @override
  late final GeneratedColumn<int> startYear = GeneratedColumn<int>(
      'start_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endYearMeta =
      const VerificationMeta('endYear');
  @override
  late final GeneratedColumn<int> endYear = GeneratedColumn<int>(
      'end_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [blColorId, name, rgbHex, startYear, endYear, groupName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lego_colors';
  @override
  VerificationContext validateIntegrity(Insertable<DbLegoColor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bl_color_id')) {
      context.handle(
          _blColorIdMeta,
          blColorId.isAcceptableOrUnknown(
              data['bl_color_id']!, _blColorIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rgb_hex')) {
      context.handle(_rgbHexMeta,
          rgbHex.isAcceptableOrUnknown(data['rgb_hex']!, _rgbHexMeta));
    }
    if (data.containsKey('start_year')) {
      context.handle(_startYearMeta,
          startYear.isAcceptableOrUnknown(data['start_year']!, _startYearMeta));
    }
    if (data.containsKey('end_year')) {
      context.handle(_endYearMeta,
          endYear.isAcceptableOrUnknown(data['end_year']!, _endYearMeta));
    }
    if (data.containsKey('group')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group']!, _groupNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {blColorId};
  @override
  DbLegoColor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbLegoColor(
      blColorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bl_color_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      rgbHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rgb_hex']),
      startYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_year']),
      endYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_year']),
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group']),
    );
  }

  @override
  $LegoColorsTable createAlias(String alias) {
    return $LegoColorsTable(attachedDatabase, alias);
  }
}

class DbLegoColor extends DataClass implements Insertable<DbLegoColor> {
  final int blColorId;
  final String name;
  final String? rgbHex;
  final int? startYear;
  final int? endYear;
  final String? groupName;
  const DbLegoColor(
      {required this.blColorId,
      required this.name,
      this.rgbHex,
      this.startYear,
      this.endYear,
      this.groupName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bl_color_id'] = Variable<int>(blColorId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || rgbHex != null) {
      map['rgb_hex'] = Variable<String>(rgbHex);
    }
    if (!nullToAbsent || startYear != null) {
      map['start_year'] = Variable<int>(startYear);
    }
    if (!nullToAbsent || endYear != null) {
      map['end_year'] = Variable<int>(endYear);
    }
    if (!nullToAbsent || groupName != null) {
      map['group'] = Variable<String>(groupName);
    }
    return map;
  }

  LegoColorsCompanion toCompanion(bool nullToAbsent) {
    return LegoColorsCompanion(
      blColorId: Value(blColorId),
      name: Value(name),
      rgbHex:
          rgbHex == null && nullToAbsent ? const Value.absent() : Value(rgbHex),
      startYear: startYear == null && nullToAbsent
          ? const Value.absent()
          : Value(startYear),
      endYear: endYear == null && nullToAbsent
          ? const Value.absent()
          : Value(endYear),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
    );
  }

  factory DbLegoColor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbLegoColor(
      blColorId: serializer.fromJson<int>(json['blColorId']),
      name: serializer.fromJson<String>(json['name']),
      rgbHex: serializer.fromJson<String?>(json['rgbHex']),
      startYear: serializer.fromJson<int?>(json['startYear']),
      endYear: serializer.fromJson<int?>(json['endYear']),
      groupName: serializer.fromJson<String?>(json['groupName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'blColorId': serializer.toJson<int>(blColorId),
      'name': serializer.toJson<String>(name),
      'rgbHex': serializer.toJson<String?>(rgbHex),
      'startYear': serializer.toJson<int?>(startYear),
      'endYear': serializer.toJson<int?>(endYear),
      'groupName': serializer.toJson<String?>(groupName),
    };
  }

  DbLegoColor copyWith(
          {int? blColorId,
          String? name,
          Value<String?> rgbHex = const Value.absent(),
          Value<int?> startYear = const Value.absent(),
          Value<int?> endYear = const Value.absent(),
          Value<String?> groupName = const Value.absent()}) =>
      DbLegoColor(
        blColorId: blColorId ?? this.blColorId,
        name: name ?? this.name,
        rgbHex: rgbHex.present ? rgbHex.value : this.rgbHex,
        startYear: startYear.present ? startYear.value : this.startYear,
        endYear: endYear.present ? endYear.value : this.endYear,
        groupName: groupName.present ? groupName.value : this.groupName,
      );
  DbLegoColor copyWithCompanion(LegoColorsCompanion data) {
    return DbLegoColor(
      blColorId: data.blColorId.present ? data.blColorId.value : this.blColorId,
      name: data.name.present ? data.name.value : this.name,
      rgbHex: data.rgbHex.present ? data.rgbHex.value : this.rgbHex,
      startYear: data.startYear.present ? data.startYear.value : this.startYear,
      endYear: data.endYear.present ? data.endYear.value : this.endYear,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbLegoColor(')
          ..write('blColorId: $blColorId, ')
          ..write('name: $name, ')
          ..write('rgbHex: $rgbHex, ')
          ..write('startYear: $startYear, ')
          ..write('endYear: $endYear, ')
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(blColorId, name, rgbHex, startYear, endYear, groupName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbLegoColor &&
          other.blColorId == this.blColorId &&
          other.name == this.name &&
          other.rgbHex == this.rgbHex &&
          other.startYear == this.startYear &&
          other.endYear == this.endYear &&
          other.groupName == this.groupName);
}

class LegoColorsCompanion extends UpdateCompanion<DbLegoColor> {
  final Value<int> blColorId;
  final Value<String> name;
  final Value<String?> rgbHex;
  final Value<int?> startYear;
  final Value<int?> endYear;
  final Value<String?> groupName;
  const LegoColorsCompanion({
    this.blColorId = const Value.absent(),
    this.name = const Value.absent(),
    this.rgbHex = const Value.absent(),
    this.startYear = const Value.absent(),
    this.endYear = const Value.absent(),
    this.groupName = const Value.absent(),
  });
  LegoColorsCompanion.insert({
    this.blColorId = const Value.absent(),
    required String name,
    this.rgbHex = const Value.absent(),
    this.startYear = const Value.absent(),
    this.endYear = const Value.absent(),
    this.groupName = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DbLegoColor> custom({
    Expression<int>? blColorId,
    Expression<String>? name,
    Expression<String>? rgbHex,
    Expression<int>? startYear,
    Expression<int>? endYear,
    Expression<String>? groupName,
  }) {
    return RawValuesInsertable({
      if (blColorId != null) 'bl_color_id': blColorId,
      if (name != null) 'name': name,
      if (rgbHex != null) 'rgb_hex': rgbHex,
      if (startYear != null) 'start_year': startYear,
      if (endYear != null) 'end_year': endYear,
      if (groupName != null) 'group': groupName,
    });
  }

  LegoColorsCompanion copyWith(
      {Value<int>? blColorId,
      Value<String>? name,
      Value<String?>? rgbHex,
      Value<int?>? startYear,
      Value<int?>? endYear,
      Value<String?>? groupName}) {
    return LegoColorsCompanion(
      blColorId: blColorId ?? this.blColorId,
      name: name ?? this.name,
      rgbHex: rgbHex ?? this.rgbHex,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      groupName: groupName ?? this.groupName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (blColorId.present) {
      map['bl_color_id'] = Variable<int>(blColorId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rgbHex.present) {
      map['rgb_hex'] = Variable<String>(rgbHex.value);
    }
    if (startYear.present) {
      map['start_year'] = Variable<int>(startYear.value);
    }
    if (endYear.present) {
      map['end_year'] = Variable<int>(endYear.value);
    }
    if (groupName.present) {
      map['group'] = Variable<String>(groupName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegoColorsCompanion(')
          ..write('blColorId: $blColorId, ')
          ..write('name: $name, ')
          ..write('rgbHex: $rgbHex, ')
          ..write('startYear: $startYear, ')
          ..write('endYear: $endYear, ')
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PalettesTable palettes = $PalettesTable(this);
  late final $PaletteColorsTable paletteColors = $PaletteColorsTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $VendorColorsTable vendorColors = $VendorColorsTable(this);
  late final $VendorColorVariantsTable vendorColorVariants =
      $VendorColorVariantsTable(this);
  late final $ColorComponentsTable colorComponents =
      $ColorComponentsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ImagesTable images = $ImagesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $LegoColorsTable legoColors = $LegoColorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        palettes,
        paletteColors,
        vendors,
        vendorColors,
        vendorColorVariants,
        colorComponents,
        settings,
        images,
        projects,
        legoColors
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('images',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('projects', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('vendors',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('projects', kind: UpdateKind.update),
            ],
          ),
        ],
      );
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
    PrefetchHooks Function({bool paletteColorsRefs})> {
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
          prefetchHooksCallback: ({paletteColorsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (paletteColorsRefs) db.paletteColors
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
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
    PrefetchHooks Function({bool paletteColorsRefs})>;
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
typedef $$VendorsTableCreateCompanionBuilder = VendorsCompanion Function({
  Value<int> id,
  required String vendorName,
  required String vendorBrand,
  Value<String?> vendorCategory,
});
typedef $$VendorsTableUpdateCompanionBuilder = VendorsCompanion Function({
  Value<int> id,
  Value<String> vendorName,
  Value<String> vendorBrand,
  Value<String?> vendorCategory,
});

final class $$VendorsTableReferences
    extends BaseReferences<_$AppDatabase, $VendorsTable, Vendor> {
  $$VendorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VendorColorsTable, List<VendorColor>>
      _vendorColorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.vendorColors,
          aliasName:
              $_aliasNameGenerator(db.vendors.id, db.vendorColors.vendorId));

  $$VendorColorsTableProcessedTableManager get vendorColorsRefs {
    final manager = $$VendorColorsTableTableManager($_db, $_db.vendorColors)
        .filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vendorColorsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProjectsTable, List<DbProject>>
      _projectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.projects,
          aliasName: $_aliasNameGenerator(db.vendors.id, db.projects.vendorId));

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VendorsTableFilterComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorBrand => $composableBuilder(
      column: $table.vendorBrand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorCategory => $composableBuilder(
      column: $table.vendorCategory,
      builder: (column) => ColumnFilters(column));

  Expression<bool> vendorColorsRefs(
      Expression<bool> Function($$VendorColorsTableFilterComposer f) f) {
    final $$VendorColorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.vendorId,
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
    return f(composer);
  }

  Expression<bool> projectsRefs(
      Expression<bool> Function($$ProjectsTableFilterComposer f) f) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.vendorId,
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
}

class $$VendorsTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorBrand => $composableBuilder(
      column: $table.vendorBrand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorCategory => $composableBuilder(
      column: $table.vendorCategory,
      builder: (column) => ColumnOrderings(column));
}

class $$VendorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => column);

  GeneratedColumn<String> get vendorBrand => $composableBuilder(
      column: $table.vendorBrand, builder: (column) => column);

  GeneratedColumn<String> get vendorCategory => $composableBuilder(
      column: $table.vendorCategory, builder: (column) => column);

  Expression<T> vendorColorsRefs<T extends Object>(
      Expression<T> Function($$VendorColorsTableAnnotationComposer a) f) {
    final $$VendorColorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vendorColors,
        getReferencedColumn: (t) => t.vendorId,
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
    return f(composer);
  }

  Expression<T> projectsRefs<T extends Object>(
      Expression<T> Function($$ProjectsTableAnnotationComposer a) f) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.vendorId,
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
}

class $$VendorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VendorsTable,
    Vendor,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (Vendor, $$VendorsTableReferences),
    Vendor,
    PrefetchHooks Function({bool vendorColorsRefs, bool projectsRefs})> {
  $$VendorsTableTableManager(_$AppDatabase db, $VendorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> vendorName = const Value.absent(),
            Value<String> vendorBrand = const Value.absent(),
            Value<String?> vendorCategory = const Value.absent(),
          }) =>
              VendorsCompanion(
            id: id,
            vendorName: vendorName,
            vendorBrand: vendorBrand,
            vendorCategory: vendorCategory,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String vendorName,
            required String vendorBrand,
            Value<String?> vendorCategory = const Value.absent(),
          }) =>
              VendorsCompanion.insert(
            id: id,
            vendorName: vendorName,
            vendorBrand: vendorBrand,
            vendorCategory: vendorCategory,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VendorsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {vendorColorsRefs = false, projectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vendorColorsRefs) db.vendorColors,
                if (projectsRefs) db.projects
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vendorColorsRefs)
                    await $_getPrefetchedData<Vendor, $VendorsTable,
                            VendorColor>(
                        currentTable: table,
                        referencedTable:
                            $$VendorsTableReferences._vendorColorsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorsTableReferences(db, table, p0)
                                .vendorColorsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.vendorId == item.id),
                        typedResults: items),
                  if (projectsRefs)
                    await $_getPrefetchedData<Vendor, $VendorsTable, DbProject>(
                        currentTable: table,
                        referencedTable:
                            $$VendorsTableReferences._projectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorsTableReferences(db, table, p0)
                                .projectsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.vendorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VendorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VendorsTable,
    Vendor,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (Vendor, $$VendorsTableReferences),
    Vendor,
    PrefetchHooks Function({bool vendorColorsRefs, bool projectsRefs})>;
typedef $$VendorColorsTableCreateCompanionBuilder = VendorColorsCompanion
    Function({
  Value<int> id,
  Value<int?> vendorId,
  required String name,
  required String code,
  Value<String> imageUrl,
  Value<double?> weightInGrams,
  Value<double?> colorDensity,
  Value<String?> pigmentCode,
  Value<String?> opacity,
  Value<int?> lightfastness,
});
typedef $$VendorColorsTableUpdateCompanionBuilder = VendorColorsCompanion
    Function({
  Value<int> id,
  Value<int?> vendorId,
  Value<String> name,
  Value<String> code,
  Value<String> imageUrl,
  Value<double?> weightInGrams,
  Value<double?> colorDensity,
  Value<String?> pigmentCode,
  Value<String?> opacity,
  Value<int?> lightfastness,
});

final class $$VendorColorsTableReferences
    extends BaseReferences<_$AppDatabase, $VendorColorsTable, VendorColor> {
  $$VendorColorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VendorsTable _vendorIdTable(_$AppDatabase db) =>
      db.vendors.createAlias(
          $_aliasNameGenerator(db.vendorColors.vendorId, db.vendors.id));

  $$VendorsTableProcessedTableManager? get vendorId {
    final $_column = $_itemColumn<int>('vendor_id');
    if ($_column == null) return null;
    final manager = $$VendorsTableTableManager($_db, $_db.vendors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

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

  ColumnFilters<String> get pigmentCode => $composableBuilder(
      column: $table.pigmentCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opacity => $composableBuilder(
      column: $table.opacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lightfastness => $composableBuilder(
      column: $table.lightfastness, builder: (column) => ColumnFilters(column));

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableFilterComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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

  ColumnOrderings<String> get pigmentCode => $composableBuilder(
      column: $table.pigmentCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opacity => $composableBuilder(
      column: $table.opacity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lightfastness => $composableBuilder(
      column: $table.lightfastness,
      builder: (column) => ColumnOrderings(column));

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get pigmentCode => $composableBuilder(
      column: $table.pigmentCode, builder: (column) => column);

  GeneratedColumn<String> get opacity =>
      $composableBuilder(column: $table.opacity, builder: (column) => column);

  GeneratedColumn<int> get lightfastness => $composableBuilder(
      column: $table.lightfastness, builder: (column) => column);

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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
        {bool vendorId,
        bool vendorColorVariantsRefs,
        bool colorComponentsRefs})> {
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
            Value<int?> vendorId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<double?> weightInGrams = const Value.absent(),
            Value<double?> colorDensity = const Value.absent(),
            Value<String?> pigmentCode = const Value.absent(),
            Value<String?> opacity = const Value.absent(),
            Value<int?> lightfastness = const Value.absent(),
          }) =>
              VendorColorsCompanion(
            id: id,
            vendorId: vendorId,
            name: name,
            code: code,
            imageUrl: imageUrl,
            weightInGrams: weightInGrams,
            colorDensity: colorDensity,
            pigmentCode: pigmentCode,
            opacity: opacity,
            lightfastness: lightfastness,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> vendorId = const Value.absent(),
            required String name,
            required String code,
            Value<String> imageUrl = const Value.absent(),
            Value<double?> weightInGrams = const Value.absent(),
            Value<double?> colorDensity = const Value.absent(),
            Value<String?> pigmentCode = const Value.absent(),
            Value<String?> opacity = const Value.absent(),
            Value<int?> lightfastness = const Value.absent(),
          }) =>
              VendorColorsCompanion.insert(
            id: id,
            vendorId: vendorId,
            name: name,
            code: code,
            imageUrl: imageUrl,
            weightInGrams: weightInGrams,
            colorDensity: colorDensity,
            pigmentCode: pigmentCode,
            opacity: opacity,
            lightfastness: lightfastness,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VendorColorsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {vendorId = false,
              vendorColorVariantsRefs = false,
              colorComponentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vendorColorVariantsRefs) db.vendorColorVariants,
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
                if (vendorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorId,
                    referencedTable:
                        $$VendorColorsTableReferences._vendorIdTable(db),
                    referencedColumn:
                        $$VendorColorsTableReferences._vendorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
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
        {bool vendorId,
        bool vendorColorVariantsRefs,
        bool colorComponentsRefs})>;
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
typedef $$ImagesTableCreateCompanionBuilder = ImagesCompanion Function({
  Value<int> id,
  Value<Uint8List?> origSrc,
  Value<int?> origBytes,
  Value<int?> origWidth,
  Value<int?> origHeight,
  Value<int?> origUniqueColors,
  Value<int?> origDpi,
  Value<Uint8List?> convSrc,
  Value<int?> convBytes,
  Value<int?> convWidth,
  Value<int?> convHeight,
  Value<int?> convUniqueColors,
  Value<int?> dpi,
  Value<Uint8List?> thumbnail,
  Value<String?> mimeType,
  Value<double?> layerOffsetX,
  Value<double?> layerOffsetY,
  Value<double?> layerScale,
  Value<double?> layerRotationDeg,
  Value<double?> layerOpacity,
  Value<bool?> layerVisible,
});
typedef $$ImagesTableUpdateCompanionBuilder = ImagesCompanion Function({
  Value<int> id,
  Value<Uint8List?> origSrc,
  Value<int?> origBytes,
  Value<int?> origWidth,
  Value<int?> origHeight,
  Value<int?> origUniqueColors,
  Value<int?> origDpi,
  Value<Uint8List?> convSrc,
  Value<int?> convBytes,
  Value<int?> convWidth,
  Value<int?> convHeight,
  Value<int?> convUniqueColors,
  Value<int?> dpi,
  Value<Uint8List?> thumbnail,
  Value<String?> mimeType,
  Value<double?> layerOffsetX,
  Value<double?> layerOffsetY,
  Value<double?> layerScale,
  Value<double?> layerRotationDeg,
  Value<double?> layerOpacity,
  Value<bool?> layerVisible,
});

final class $$ImagesTableReferences
    extends BaseReferences<_$AppDatabase, $ImagesTable, DbImage> {
  $$ImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<DbProject>>
      _projectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.projects,
          aliasName: $_aliasNameGenerator(db.images.id, db.projects.imageId));

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.imageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get origSrc => $composableBuilder(
      column: $table.origSrc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get origBytes => $composableBuilder(
      column: $table.origBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get origWidth => $composableBuilder(
      column: $table.origWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get origHeight => $composableBuilder(
      column: $table.origHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get origUniqueColors => $composableBuilder(
      column: $table.origUniqueColors,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get origDpi => $composableBuilder(
      column: $table.origDpi, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get convSrc => $composableBuilder(
      column: $table.convSrc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get convBytes => $composableBuilder(
      column: $table.convBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get convWidth => $composableBuilder(
      column: $table.convWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get convHeight => $composableBuilder(
      column: $table.convHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get convUniqueColors => $composableBuilder(
      column: $table.convUniqueColors,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dpi => $composableBuilder(
      column: $table.dpi, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get layerOffsetX => $composableBuilder(
      column: $table.layerOffsetX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get layerOffsetY => $composableBuilder(
      column: $table.layerOffsetY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get layerScale => $composableBuilder(
      column: $table.layerScale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get layerRotationDeg => $composableBuilder(
      column: $table.layerRotationDeg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get layerOpacity => $composableBuilder(
      column: $table.layerOpacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get layerVisible => $composableBuilder(
      column: $table.layerVisible, builder: (column) => ColumnFilters(column));

  Expression<bool> projectsRefs(
      Expression<bool> Function($$ProjectsTableFilterComposer f) f) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.imageId,
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
}

class $$ImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get origSrc => $composableBuilder(
      column: $table.origSrc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origBytes => $composableBuilder(
      column: $table.origBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origWidth => $composableBuilder(
      column: $table.origWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origHeight => $composableBuilder(
      column: $table.origHeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origUniqueColors => $composableBuilder(
      column: $table.origUniqueColors,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origDpi => $composableBuilder(
      column: $table.origDpi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get convSrc => $composableBuilder(
      column: $table.convSrc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get convBytes => $composableBuilder(
      column: $table.convBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get convWidth => $composableBuilder(
      column: $table.convWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get convHeight => $composableBuilder(
      column: $table.convHeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get convUniqueColors => $composableBuilder(
      column: $table.convUniqueColors,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dpi => $composableBuilder(
      column: $table.dpi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get layerOffsetX => $composableBuilder(
      column: $table.layerOffsetX,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get layerOffsetY => $composableBuilder(
      column: $table.layerOffsetY,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get layerScale => $composableBuilder(
      column: $table.layerScale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get layerRotationDeg => $composableBuilder(
      column: $table.layerRotationDeg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get layerOpacity => $composableBuilder(
      column: $table.layerOpacity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get layerVisible => $composableBuilder(
      column: $table.layerVisible,
      builder: (column) => ColumnOrderings(column));
}

class $$ImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get origSrc =>
      $composableBuilder(column: $table.origSrc, builder: (column) => column);

  GeneratedColumn<int> get origBytes =>
      $composableBuilder(column: $table.origBytes, builder: (column) => column);

  GeneratedColumn<int> get origWidth =>
      $composableBuilder(column: $table.origWidth, builder: (column) => column);

  GeneratedColumn<int> get origHeight => $composableBuilder(
      column: $table.origHeight, builder: (column) => column);

  GeneratedColumn<int> get origUniqueColors => $composableBuilder(
      column: $table.origUniqueColors, builder: (column) => column);

  GeneratedColumn<int> get origDpi =>
      $composableBuilder(column: $table.origDpi, builder: (column) => column);

  GeneratedColumn<Uint8List> get convSrc =>
      $composableBuilder(column: $table.convSrc, builder: (column) => column);

  GeneratedColumn<int> get convBytes =>
      $composableBuilder(column: $table.convBytes, builder: (column) => column);

  GeneratedColumn<int> get convWidth =>
      $composableBuilder(column: $table.convWidth, builder: (column) => column);

  GeneratedColumn<int> get convHeight => $composableBuilder(
      column: $table.convHeight, builder: (column) => column);

  GeneratedColumn<int> get convUniqueColors => $composableBuilder(
      column: $table.convUniqueColors, builder: (column) => column);

  GeneratedColumn<int> get dpi =>
      $composableBuilder(column: $table.dpi, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<double> get layerOffsetX => $composableBuilder(
      column: $table.layerOffsetX, builder: (column) => column);

  GeneratedColumn<double> get layerOffsetY => $composableBuilder(
      column: $table.layerOffsetY, builder: (column) => column);

  GeneratedColumn<double> get layerScale => $composableBuilder(
      column: $table.layerScale, builder: (column) => column);

  GeneratedColumn<double> get layerRotationDeg => $composableBuilder(
      column: $table.layerRotationDeg, builder: (column) => column);

  GeneratedColumn<double> get layerOpacity => $composableBuilder(
      column: $table.layerOpacity, builder: (column) => column);

  GeneratedColumn<bool> get layerVisible => $composableBuilder(
      column: $table.layerVisible, builder: (column) => column);

  Expression<T> projectsRefs<T extends Object>(
      Expression<T> Function($$ProjectsTableAnnotationComposer a) f) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.imageId,
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
}

class $$ImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImagesTable,
    DbImage,
    $$ImagesTableFilterComposer,
    $$ImagesTableOrderingComposer,
    $$ImagesTableAnnotationComposer,
    $$ImagesTableCreateCompanionBuilder,
    $$ImagesTableUpdateCompanionBuilder,
    (DbImage, $$ImagesTableReferences),
    DbImage,
    PrefetchHooks Function({bool projectsRefs})> {
  $$ImagesTableTableManager(_$AppDatabase db, $ImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uint8List?> origSrc = const Value.absent(),
            Value<int?> origBytes = const Value.absent(),
            Value<int?> origWidth = const Value.absent(),
            Value<int?> origHeight = const Value.absent(),
            Value<int?> origUniqueColors = const Value.absent(),
            Value<int?> origDpi = const Value.absent(),
            Value<Uint8List?> convSrc = const Value.absent(),
            Value<int?> convBytes = const Value.absent(),
            Value<int?> convWidth = const Value.absent(),
            Value<int?> convHeight = const Value.absent(),
            Value<int?> convUniqueColors = const Value.absent(),
            Value<int?> dpi = const Value.absent(),
            Value<Uint8List?> thumbnail = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<double?> layerOffsetX = const Value.absent(),
            Value<double?> layerOffsetY = const Value.absent(),
            Value<double?> layerScale = const Value.absent(),
            Value<double?> layerRotationDeg = const Value.absent(),
            Value<double?> layerOpacity = const Value.absent(),
            Value<bool?> layerVisible = const Value.absent(),
          }) =>
              ImagesCompanion(
            id: id,
            origSrc: origSrc,
            origBytes: origBytes,
            origWidth: origWidth,
            origHeight: origHeight,
            origUniqueColors: origUniqueColors,
            origDpi: origDpi,
            convSrc: convSrc,
            convBytes: convBytes,
            convWidth: convWidth,
            convHeight: convHeight,
            convUniqueColors: convUniqueColors,
            dpi: dpi,
            thumbnail: thumbnail,
            mimeType: mimeType,
            layerOffsetX: layerOffsetX,
            layerOffsetY: layerOffsetY,
            layerScale: layerScale,
            layerRotationDeg: layerRotationDeg,
            layerOpacity: layerOpacity,
            layerVisible: layerVisible,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<Uint8List?> origSrc = const Value.absent(),
            Value<int?> origBytes = const Value.absent(),
            Value<int?> origWidth = const Value.absent(),
            Value<int?> origHeight = const Value.absent(),
            Value<int?> origUniqueColors = const Value.absent(),
            Value<int?> origDpi = const Value.absent(),
            Value<Uint8List?> convSrc = const Value.absent(),
            Value<int?> convBytes = const Value.absent(),
            Value<int?> convWidth = const Value.absent(),
            Value<int?> convHeight = const Value.absent(),
            Value<int?> convUniqueColors = const Value.absent(),
            Value<int?> dpi = const Value.absent(),
            Value<Uint8List?> thumbnail = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<double?> layerOffsetX = const Value.absent(),
            Value<double?> layerOffsetY = const Value.absent(),
            Value<double?> layerScale = const Value.absent(),
            Value<double?> layerRotationDeg = const Value.absent(),
            Value<double?> layerOpacity = const Value.absent(),
            Value<bool?> layerVisible = const Value.absent(),
          }) =>
              ImagesCompanion.insert(
            id: id,
            origSrc: origSrc,
            origBytes: origBytes,
            origWidth: origWidth,
            origHeight: origHeight,
            origUniqueColors: origUniqueColors,
            origDpi: origDpi,
            convSrc: convSrc,
            convBytes: convBytes,
            convWidth: convWidth,
            convHeight: convHeight,
            convUniqueColors: convUniqueColors,
            dpi: dpi,
            thumbnail: thumbnail,
            mimeType: mimeType,
            layerOffsetX: layerOffsetX,
            layerOffsetY: layerOffsetY,
            layerScale: layerScale,
            layerRotationDeg: layerRotationDeg,
            layerOpacity: layerOpacity,
            layerVisible: layerVisible,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ImagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({projectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (projectsRefs) db.projects],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectsRefs)
                    await $_getPrefetchedData<DbImage, $ImagesTable, DbProject>(
                        currentTable: table,
                        referencedTable:
                            $$ImagesTableReferences._projectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ImagesTableReferences(db, table, p0).projectsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.imageId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImagesTable,
    DbImage,
    $$ImagesTableFilterComposer,
    $$ImagesTableOrderingComposer,
    $$ImagesTableAnnotationComposer,
    $$ImagesTableCreateCompanionBuilder,
    $$ImagesTableUpdateCompanionBuilder,
    (DbImage, $$ImagesTableReferences),
    DbImage,
    PrefetchHooks Function({bool projectsRefs})>;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> author,
  Value<String> status,
  required int createdAt,
  required int updatedAt,
  Value<int?> imageId,
  Value<String?> model,
  Value<int?> vendorId,
  Value<int> canvasWidthPx,
  Value<int> canvasHeightPx,
  Value<double> canvasWidthValue,
  Value<String> canvasWidthUnit,
  Value<double> canvasHeightValue,
  Value<String> canvasHeightUnit,
  Value<double> gridCellWidthValue,
  Value<String> gridCellWidthUnit,
  Value<double> gridCellHeightValue,
  Value<String> gridCellHeightUnit,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> author,
  Value<String> status,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> imageId,
  Value<String?> model,
  Value<int?> vendorId,
  Value<int> canvasWidthPx,
  Value<int> canvasHeightPx,
  Value<double> canvasWidthValue,
  Value<String> canvasWidthUnit,
  Value<double> canvasHeightValue,
  Value<String> canvasHeightUnit,
  Value<double> gridCellWidthValue,
  Value<String> gridCellWidthUnit,
  Value<double> gridCellHeightValue,
  Value<String> gridCellHeightUnit,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, DbProject> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImagesTable _imageIdTable(_$AppDatabase db) => db.images
      .createAlias($_aliasNameGenerator(db.projects.imageId, db.images.id));

  $$ImagesTableProcessedTableManager? get imageId {
    final $_column = $_itemColumn<int>('image_id');
    if ($_column == null) return null;
    final manager = $$ImagesTableTableManager($_db, $_db.images)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $VendorsTable _vendorIdTable(_$AppDatabase db) => db.vendors
      .createAlias($_aliasNameGenerator(db.projects.vendorId, db.vendors.id));

  $$VendorsTableProcessedTableManager? get vendorId {
    final $_column = $_itemColumn<int>('vendor_id');
    if ($_column == null) return null;
    final manager = $$VendorsTableTableManager($_db, $_db.vendors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
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

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get canvasWidthPx => $composableBuilder(
      column: $table.canvasWidthPx, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get canvasHeightPx => $composableBuilder(
      column: $table.canvasHeightPx,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get canvasWidthValue => $composableBuilder(
      column: $table.canvasWidthValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canvasWidthUnit => $composableBuilder(
      column: $table.canvasWidthUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get canvasHeightValue => $composableBuilder(
      column: $table.canvasHeightValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canvasHeightUnit => $composableBuilder(
      column: $table.canvasHeightUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gridCellWidthValue => $composableBuilder(
      column: $table.gridCellWidthValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gridCellWidthUnit => $composableBuilder(
      column: $table.gridCellWidthUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gridCellHeightValue => $composableBuilder(
      column: $table.gridCellHeightValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gridCellHeightUnit => $composableBuilder(
      column: $table.gridCellHeightUnit,
      builder: (column) => ColumnFilters(column));

  $$ImagesTableFilterComposer get imageId {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.images,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImagesTableFilterComposer(
              $db: $db,
              $table: $db.images,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableFilterComposer(
              $db: $db,
              $table: $db.vendors,
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

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get canvasWidthPx => $composableBuilder(
      column: $table.canvasWidthPx,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get canvasHeightPx => $composableBuilder(
      column: $table.canvasHeightPx,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get canvasWidthValue => $composableBuilder(
      column: $table.canvasWidthValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canvasWidthUnit => $composableBuilder(
      column: $table.canvasWidthUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get canvasHeightValue => $composableBuilder(
      column: $table.canvasHeightValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canvasHeightUnit => $composableBuilder(
      column: $table.canvasHeightUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gridCellWidthValue => $composableBuilder(
      column: $table.gridCellWidthValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gridCellWidthUnit => $composableBuilder(
      column: $table.gridCellWidthUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gridCellHeightValue => $composableBuilder(
      column: $table.gridCellHeightValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gridCellHeightUnit => $composableBuilder(
      column: $table.gridCellHeightUnit,
      builder: (column) => ColumnOrderings(column));

  $$ImagesTableOrderingComposer get imageId {
    final $$ImagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.images,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImagesTableOrderingComposer(
              $db: $db,
              $table: $db.images,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendors,
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get canvasWidthPx => $composableBuilder(
      column: $table.canvasWidthPx, builder: (column) => column);

  GeneratedColumn<int> get canvasHeightPx => $composableBuilder(
      column: $table.canvasHeightPx, builder: (column) => column);

  GeneratedColumn<double> get canvasWidthValue => $composableBuilder(
      column: $table.canvasWidthValue, builder: (column) => column);

  GeneratedColumn<String> get canvasWidthUnit => $composableBuilder(
      column: $table.canvasWidthUnit, builder: (column) => column);

  GeneratedColumn<double> get canvasHeightValue => $composableBuilder(
      column: $table.canvasHeightValue, builder: (column) => column);

  GeneratedColumn<String> get canvasHeightUnit => $composableBuilder(
      column: $table.canvasHeightUnit, builder: (column) => column);

  GeneratedColumn<double> get gridCellWidthValue => $composableBuilder(
      column: $table.gridCellWidthValue, builder: (column) => column);

  GeneratedColumn<String> get gridCellWidthUnit => $composableBuilder(
      column: $table.gridCellWidthUnit, builder: (column) => column);

  GeneratedColumn<double> get gridCellHeightValue => $composableBuilder(
      column: $table.gridCellHeightValue, builder: (column) => column);

  GeneratedColumn<String> get gridCellHeightUnit => $composableBuilder(
      column: $table.gridCellHeightUnit, builder: (column) => column);

  $$ImagesTableAnnotationComposer get imageId {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.images,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.images,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendors,
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
    DbProject,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (DbProject, $$ProjectsTableReferences),
    DbProject,
    PrefetchHooks Function({bool imageId, bool vendorId})> {
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
            Value<String> title = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> imageId = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<int?> vendorId = const Value.absent(),
            Value<int> canvasWidthPx = const Value.absent(),
            Value<int> canvasHeightPx = const Value.absent(),
            Value<double> canvasWidthValue = const Value.absent(),
            Value<String> canvasWidthUnit = const Value.absent(),
            Value<double> canvasHeightValue = const Value.absent(),
            Value<String> canvasHeightUnit = const Value.absent(),
            Value<double> gridCellWidthValue = const Value.absent(),
            Value<String> gridCellWidthUnit = const Value.absent(),
            Value<double> gridCellHeightValue = const Value.absent(),
            Value<String> gridCellHeightUnit = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            title: title,
            author: author,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            imageId: imageId,
            model: model,
            vendorId: vendorId,
            canvasWidthPx: canvasWidthPx,
            canvasHeightPx: canvasHeightPx,
            canvasWidthValue: canvasWidthValue,
            canvasWidthUnit: canvasWidthUnit,
            canvasHeightValue: canvasHeightValue,
            canvasHeightUnit: canvasHeightUnit,
            gridCellWidthValue: gridCellWidthValue,
            gridCellWidthUnit: gridCellWidthUnit,
            gridCellHeightValue: gridCellHeightValue,
            gridCellHeightUnit: gridCellHeightUnit,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> author = const Value.absent(),
            Value<String> status = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> imageId = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<int?> vendorId = const Value.absent(),
            Value<int> canvasWidthPx = const Value.absent(),
            Value<int> canvasHeightPx = const Value.absent(),
            Value<double> canvasWidthValue = const Value.absent(),
            Value<String> canvasWidthUnit = const Value.absent(),
            Value<double> canvasHeightValue = const Value.absent(),
            Value<String> canvasHeightUnit = const Value.absent(),
            Value<double> gridCellWidthValue = const Value.absent(),
            Value<String> gridCellWidthUnit = const Value.absent(),
            Value<double> gridCellHeightValue = const Value.absent(),
            Value<String> gridCellHeightUnit = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            title: title,
            author: author,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            imageId: imageId,
            model: model,
            vendorId: vendorId,
            canvasWidthPx: canvasWidthPx,
            canvasHeightPx: canvasHeightPx,
            canvasWidthValue: canvasWidthValue,
            canvasWidthUnit: canvasWidthUnit,
            canvasHeightValue: canvasHeightValue,
            canvasHeightUnit: canvasHeightUnit,
            gridCellWidthValue: gridCellWidthValue,
            gridCellWidthUnit: gridCellWidthUnit,
            gridCellHeightValue: gridCellHeightValue,
            gridCellHeightUnit: gridCellHeightUnit,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({imageId = false, vendorId = false}) {
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
                if (imageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.imageId,
                    referencedTable:
                        $$ProjectsTableReferences._imageIdTable(db),
                    referencedColumn:
                        $$ProjectsTableReferences._imageIdTable(db).id,
                  ) as T;
                }
                if (vendorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorId,
                    referencedTable:
                        $$ProjectsTableReferences._vendorIdTable(db),
                    referencedColumn:
                        $$ProjectsTableReferences._vendorIdTable(db).id,
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
    DbProject,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (DbProject, $$ProjectsTableReferences),
    DbProject,
    PrefetchHooks Function({bool imageId, bool vendorId})>;
typedef $$LegoColorsTableCreateCompanionBuilder = LegoColorsCompanion Function({
  Value<int> blColorId,
  required String name,
  Value<String?> rgbHex,
  Value<int?> startYear,
  Value<int?> endYear,
  Value<String?> groupName,
});
typedef $$LegoColorsTableUpdateCompanionBuilder = LegoColorsCompanion Function({
  Value<int> blColorId,
  Value<String> name,
  Value<String?> rgbHex,
  Value<int?> startYear,
  Value<int?> endYear,
  Value<String?> groupName,
});

class $$LegoColorsTableFilterComposer
    extends Composer<_$AppDatabase, $LegoColorsTable> {
  $$LegoColorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get blColorId => $composableBuilder(
      column: $table.blColorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rgbHex => $composableBuilder(
      column: $table.rgbHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startYear => $composableBuilder(
      column: $table.startYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endYear => $composableBuilder(
      column: $table.endYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));
}

class $$LegoColorsTableOrderingComposer
    extends Composer<_$AppDatabase, $LegoColorsTable> {
  $$LegoColorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get blColorId => $composableBuilder(
      column: $table.blColorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rgbHex => $composableBuilder(
      column: $table.rgbHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startYear => $composableBuilder(
      column: $table.startYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endYear => $composableBuilder(
      column: $table.endYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));
}

class $$LegoColorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LegoColorsTable> {
  $$LegoColorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get blColorId =>
      $composableBuilder(column: $table.blColorId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rgbHex =>
      $composableBuilder(column: $table.rgbHex, builder: (column) => column);

  GeneratedColumn<int> get startYear =>
      $composableBuilder(column: $table.startYear, builder: (column) => column);

  GeneratedColumn<int> get endYear =>
      $composableBuilder(column: $table.endYear, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);
}

class $$LegoColorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LegoColorsTable,
    DbLegoColor,
    $$LegoColorsTableFilterComposer,
    $$LegoColorsTableOrderingComposer,
    $$LegoColorsTableAnnotationComposer,
    $$LegoColorsTableCreateCompanionBuilder,
    $$LegoColorsTableUpdateCompanionBuilder,
    (DbLegoColor, BaseReferences<_$AppDatabase, $LegoColorsTable, DbLegoColor>),
    DbLegoColor,
    PrefetchHooks Function()> {
  $$LegoColorsTableTableManager(_$AppDatabase db, $LegoColorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LegoColorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LegoColorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LegoColorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> blColorId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> rgbHex = const Value.absent(),
            Value<int?> startYear = const Value.absent(),
            Value<int?> endYear = const Value.absent(),
            Value<String?> groupName = const Value.absent(),
          }) =>
              LegoColorsCompanion(
            blColorId: blColorId,
            name: name,
            rgbHex: rgbHex,
            startYear: startYear,
            endYear: endYear,
            groupName: groupName,
          ),
          createCompanionCallback: ({
            Value<int> blColorId = const Value.absent(),
            required String name,
            Value<String?> rgbHex = const Value.absent(),
            Value<int?> startYear = const Value.absent(),
            Value<int?> endYear = const Value.absent(),
            Value<String?> groupName = const Value.absent(),
          }) =>
              LegoColorsCompanion.insert(
            blColorId: blColorId,
            name: name,
            rgbHex: rgbHex,
            startYear: startYear,
            endYear: endYear,
            groupName: groupName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LegoColorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LegoColorsTable,
    DbLegoColor,
    $$LegoColorsTableFilterComposer,
    $$LegoColorsTableOrderingComposer,
    $$LegoColorsTableAnnotationComposer,
    $$LegoColorsTableCreateCompanionBuilder,
    $$LegoColorsTableUpdateCompanionBuilder,
    (DbLegoColor, BaseReferences<_$AppDatabase, $LegoColorsTable, DbLegoColor>),
    DbLegoColor,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PalettesTableTableManager get palettes =>
      $$PalettesTableTableManager(_db, _db.palettes);
  $$PaletteColorsTableTableManager get paletteColors =>
      $$PaletteColorsTableTableManager(_db, _db.paletteColors);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$VendorColorsTableTableManager get vendorColors =>
      $$VendorColorsTableTableManager(_db, _db.vendorColors);
  $$VendorColorVariantsTableTableManager get vendorColorVariants =>
      $$VendorColorVariantsTableTableManager(_db, _db.vendorColorVariants);
  $$ColorComponentsTableTableManager get colorComponents =>
      $$ColorComponentsTableTableManager(_db, _db.colorComponents);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ImagesTableTableManager get images =>
      $$ImagesTableTableManager(_db, _db.images);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$LegoColorsTableTableManager get legoColors =>
      $$LegoColorsTableTableManager(_db, _db.legoColors);
}
