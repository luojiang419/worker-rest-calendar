// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScheduleProfilesTable extends ScheduleProfiles
    with TableInfo<$ScheduleProfilesTable, ScheduleProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternTypeMeta = const VerificationMeta(
    'patternType',
  );
  @override
  late final GeneratedColumn<String> patternType = GeneratedColumn<String>(
    'pattern_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorDateMeta = const VerificationMeta(
    'anchorDate',
  );
  @override
  late final GeneratedColumn<String> anchorDate = GeneratedColumn<String>(
    'anchor_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorWeekTypeMeta = const VerificationMeta(
    'anchorWeekType',
  );
  @override
  late final GeneratedColumn<String> anchorWeekType = GeneratedColumn<String>(
    'anchor_week_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cycleDaysJsonMeta = const VerificationMeta(
    'cycleDaysJson',
  );
  @override
  late final GeneratedColumn<String> cycleDaysJson = GeneratedColumn<String>(
    'cycle_days_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _holidayOverridesEnabledMeta =
      const VerificationMeta('holidayOverridesEnabled');
  @override
  late final GeneratedColumn<bool> holidayOverridesEnabled =
      GeneratedColumn<bool>(
        'holiday_overrides_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("holiday_overrides_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    patternType,
    anchorDate,
    anchorWeekType,
    cycleDaysJson,
    holidayOverridesEnabled,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pattern_type')) {
      context.handle(
        _patternTypeMeta,
        patternType.isAcceptableOrUnknown(
          data['pattern_type']!,
          _patternTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternTypeMeta);
    }
    if (data.containsKey('anchor_date')) {
      context.handle(
        _anchorDateMeta,
        anchorDate.isAcceptableOrUnknown(data['anchor_date']!, _anchorDateMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDateMeta);
    }
    if (data.containsKey('anchor_week_type')) {
      context.handle(
        _anchorWeekTypeMeta,
        anchorWeekType.isAcceptableOrUnknown(
          data['anchor_week_type']!,
          _anchorWeekTypeMeta,
        ),
      );
    }
    if (data.containsKey('cycle_days_json')) {
      context.handle(
        _cycleDaysJsonMeta,
        cycleDaysJson.isAcceptableOrUnknown(
          data['cycle_days_json']!,
          _cycleDaysJsonMeta,
        ),
      );
    }
    if (data.containsKey('holiday_overrides_enabled')) {
      context.handle(
        _holidayOverridesEnabledMeta,
        holidayOverridesEnabled.isAcceptableOrUnknown(
          data['holiday_overrides_enabled']!,
          _holidayOverridesEnabledMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      patternType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_type'],
      )!,
      anchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_date'],
      )!,
      anchorWeekType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_week_type'],
      ),
      cycleDaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_days_json'],
      )!,
      holidayOverridesEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}holiday_overrides_enabled'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ScheduleProfilesTable createAlias(String alias) {
    return $ScheduleProfilesTable(attachedDatabase, alias);
  }
}

class ScheduleProfileRow extends DataClass
    implements Insertable<ScheduleProfileRow> {
  final String id;
  final String name;
  final String patternType;
  final String anchorDate;
  final String? anchorWeekType;
  final String cycleDaysJson;
  final bool holidayOverridesEnabled;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ScheduleProfileRow({
    required this.id,
    required this.name,
    required this.patternType,
    required this.anchorDate,
    this.anchorWeekType,
    required this.cycleDaysJson,
    required this.holidayOverridesEnabled,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['pattern_type'] = Variable<String>(patternType);
    map['anchor_date'] = Variable<String>(anchorDate);
    if (!nullToAbsent || anchorWeekType != null) {
      map['anchor_week_type'] = Variable<String>(anchorWeekType);
    }
    map['cycle_days_json'] = Variable<String>(cycleDaysJson);
    map['holiday_overrides_enabled'] = Variable<bool>(holidayOverridesEnabled);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ScheduleProfilesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleProfilesCompanion(
      id: Value(id),
      name: Value(name),
      patternType: Value(patternType),
      anchorDate: Value(anchorDate),
      anchorWeekType: anchorWeekType == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorWeekType),
      cycleDaysJson: Value(cycleDaysJson),
      holidayOverridesEnabled: Value(holidayOverridesEnabled),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ScheduleProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      patternType: serializer.fromJson<String>(json['patternType']),
      anchorDate: serializer.fromJson<String>(json['anchorDate']),
      anchorWeekType: serializer.fromJson<String?>(json['anchorWeekType']),
      cycleDaysJson: serializer.fromJson<String>(json['cycleDaysJson']),
      holidayOverridesEnabled: serializer.fromJson<bool>(
        json['holidayOverridesEnabled'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'patternType': serializer.toJson<String>(patternType),
      'anchorDate': serializer.toJson<String>(anchorDate),
      'anchorWeekType': serializer.toJson<String?>(anchorWeekType),
      'cycleDaysJson': serializer.toJson<String>(cycleDaysJson),
      'holidayOverridesEnabled': serializer.toJson<bool>(
        holidayOverridesEnabled,
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ScheduleProfileRow copyWith({
    String? id,
    String? name,
    String? patternType,
    String? anchorDate,
    Value<String?> anchorWeekType = const Value.absent(),
    String? cycleDaysJson,
    bool? holidayOverridesEnabled,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ScheduleProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    patternType: patternType ?? this.patternType,
    anchorDate: anchorDate ?? this.anchorDate,
    anchorWeekType: anchorWeekType.present
        ? anchorWeekType.value
        : this.anchorWeekType,
    cycleDaysJson: cycleDaysJson ?? this.cycleDaysJson,
    holidayOverridesEnabled:
        holidayOverridesEnabled ?? this.holidayOverridesEnabled,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ScheduleProfileRow copyWithCompanion(ScheduleProfilesCompanion data) {
    return ScheduleProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      patternType: data.patternType.present
          ? data.patternType.value
          : this.patternType,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      anchorWeekType: data.anchorWeekType.present
          ? data.anchorWeekType.value
          : this.anchorWeekType,
      cycleDaysJson: data.cycleDaysJson.present
          ? data.cycleDaysJson.value
          : this.cycleDaysJson,
      holidayOverridesEnabled: data.holidayOverridesEnabled.present
          ? data.holidayOverridesEnabled.value
          : this.holidayOverridesEnabled,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('patternType: $patternType, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('anchorWeekType: $anchorWeekType, ')
          ..write('cycleDaysJson: $cycleDaysJson, ')
          ..write('holidayOverridesEnabled: $holidayOverridesEnabled, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    patternType,
    anchorDate,
    anchorWeekType,
    cycleDaysJson,
    holidayOverridesEnabled,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.patternType == this.patternType &&
          other.anchorDate == this.anchorDate &&
          other.anchorWeekType == this.anchorWeekType &&
          other.cycleDaysJson == this.cycleDaysJson &&
          other.holidayOverridesEnabled == this.holidayOverridesEnabled &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ScheduleProfilesCompanion extends UpdateCompanion<ScheduleProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> patternType;
  final Value<String> anchorDate;
  final Value<String?> anchorWeekType;
  final Value<String> cycleDaysJson;
  final Value<bool> holidayOverridesEnabled;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ScheduleProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.patternType = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.anchorWeekType = const Value.absent(),
    this.cycleDaysJson = const Value.absent(),
    this.holidayOverridesEnabled = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleProfilesCompanion.insert({
    required String id,
    required String name,
    required String patternType,
    required String anchorDate,
    this.anchorWeekType = const Value.absent(),
    this.cycleDaysJson = const Value.absent(),
    this.holidayOverridesEnabled = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       patternType = Value(patternType),
       anchorDate = Value(anchorDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ScheduleProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? patternType,
    Expression<String>? anchorDate,
    Expression<String>? anchorWeekType,
    Expression<String>? cycleDaysJson,
    Expression<bool>? holidayOverridesEnabled,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (patternType != null) 'pattern_type': patternType,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (anchorWeekType != null) 'anchor_week_type': anchorWeekType,
      if (cycleDaysJson != null) 'cycle_days_json': cycleDaysJson,
      if (holidayOverridesEnabled != null)
        'holiday_overrides_enabled': holidayOverridesEnabled,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? patternType,
    Value<String>? anchorDate,
    Value<String?>? anchorWeekType,
    Value<String>? cycleDaysJson,
    Value<bool>? holidayOverridesEnabled,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ScheduleProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      patternType: patternType ?? this.patternType,
      anchorDate: anchorDate ?? this.anchorDate,
      anchorWeekType: anchorWeekType ?? this.anchorWeekType,
      cycleDaysJson: cycleDaysJson ?? this.cycleDaysJson,
      holidayOverridesEnabled:
          holidayOverridesEnabled ?? this.holidayOverridesEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (patternType.present) {
      map['pattern_type'] = Variable<String>(patternType.value);
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<String>(anchorDate.value);
    }
    if (anchorWeekType.present) {
      map['anchor_week_type'] = Variable<String>(anchorWeekType.value);
    }
    if (cycleDaysJson.present) {
      map['cycle_days_json'] = Variable<String>(cycleDaysJson.value);
    }
    if (holidayOverridesEnabled.present) {
      map['holiday_overrides_enabled'] = Variable<bool>(
        holidayOverridesEnabled.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('patternType: $patternType, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('anchorWeekType: $anchorWeekType, ')
          ..write('cycleDaysJson: $cycleDaysJson, ')
          ..write('holidayOverridesEnabled: $holidayOverridesEnabled, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayOverridesTable extends DayOverrides
    with TableInfo<$DayOverridesTable, DayOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedule_profiles (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overtimeMinutesMeta = const VerificationMeta(
    'overtimeMinutes',
  );
  @override
  late final GeneratedColumn<int> overtimeMinutes = GeneratedColumn<int>(
    'overtime_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    profileId,
    kind,
    overtimeMinutes,
    note,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayOverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('overtime_minutes')) {
      context.handle(
        _overtimeMinutesMeta,
        overtimeMinutes.isAcceptableOrUnknown(
          data['overtime_minutes']!,
          _overtimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, date},
  ];
  @override
  DayOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayOverrideRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      overtimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overtime_minutes'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DayOverridesTable createAlias(String alias) {
    return $DayOverridesTable(attachedDatabase, alias);
  }
}

class DayOverrideRow extends DataClass implements Insertable<DayOverrideRow> {
  final String id;
  final String date;
  final String profileId;
  final String kind;
  final int overtimeMinutes;
  final String? note;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const DayOverrideRow({
    required this.id,
    required this.date,
    required this.profileId,
    required this.kind,
    required this.overtimeMinutes,
    this.note,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['profile_id'] = Variable<String>(profileId);
    map['kind'] = Variable<String>(kind);
    map['overtime_minutes'] = Variable<int>(overtimeMinutes);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DayOverridesCompanion toCompanion(bool nullToAbsent) {
    return DayOverridesCompanion(
      id: Value(id),
      date: Value(date),
      profileId: Value(profileId),
      kind: Value(kind),
      overtimeMinutes: Value(overtimeMinutes),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DayOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayOverrideRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      profileId: serializer.fromJson<String>(json['profileId']),
      kind: serializer.fromJson<String>(json['kind']),
      overtimeMinutes: serializer.fromJson<int>(json['overtimeMinutes']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'profileId': serializer.toJson<String>(profileId),
      'kind': serializer.toJson<String>(kind),
      'overtimeMinutes': serializer.toJson<int>(overtimeMinutes),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DayOverrideRow copyWith({
    String? id,
    String? date,
    String? profileId,
    String? kind,
    int? overtimeMinutes,
    Value<String?> note = const Value.absent(),
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DayOverrideRow(
    id: id ?? this.id,
    date: date ?? this.date,
    profileId: profileId ?? this.profileId,
    kind: kind ?? this.kind,
    overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DayOverrideRow copyWithCompanion(DayOverridesCompanion data) {
    return DayOverrideRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      kind: data.kind.present ? data.kind.value : this.kind,
      overtimeMinutes: data.overtimeMinutes.present
          ? data.overtimeMinutes.value
          : this.overtimeMinutes,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayOverrideRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('overtimeMinutes: $overtimeMinutes, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    profileId,
    kind,
    overtimeMinutes,
    note,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayOverrideRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.profileId == this.profileId &&
          other.kind == this.kind &&
          other.overtimeMinutes == this.overtimeMinutes &&
          other.note == this.note &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class DayOverridesCompanion extends UpdateCompanion<DayOverrideRow> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> profileId;
  final Value<String> kind;
  final Value<int> overtimeMinutes;
  final Value<String?> note;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DayOverridesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.profileId = const Value.absent(),
    this.kind = const Value.absent(),
    this.overtimeMinutes = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayOverridesCompanion.insert({
    required String id,
    required String date,
    required String profileId,
    required String kind,
    this.overtimeMinutes = const Value.absent(),
    this.note = const Value.absent(),
    required String source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       profileId = Value(profileId),
       kind = Value(kind),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DayOverrideRow> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? profileId,
    Expression<String>? kind,
    Expression<int>? overtimeMinutes,
    Expression<String>? note,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (profileId != null) 'profile_id': profileId,
      if (kind != null) 'kind': kind,
      if (overtimeMinutes != null) 'overtime_minutes': overtimeMinutes,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayOverridesCompanion copyWith({
    Value<String>? id,
    Value<String>? date,
    Value<String>? profileId,
    Value<String>? kind,
    Value<int>? overtimeMinutes,
    Value<String?>? note,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return DayOverridesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      profileId: profileId ?? this.profileId,
      kind: kind ?? this.kind,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      note: note ?? this.note,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (overtimeMinutes.present) {
      map['overtime_minutes'] = Variable<int>(overtimeMinutes.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayOverridesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('overtimeMinutes: $overtimeMinutes, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidayOverridesTable extends HolidayOverrides
    with TableInfo<$HolidayOverridesTable, HolidayOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidayOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataVersionMeta = const VerificationMeta(
    'dataVersion',
  );
  @override
  late final GeneratedColumn<String> dataVersion = GeneratedColumn<String>(
    'data_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    kind,
    title,
    region,
    dataVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holiday_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolidayOverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('data_version')) {
      context.handle(
        _dataVersionMeta,
        dataVersion.isAcceptableOrUnknown(
          data['data_version']!,
          _dataVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataVersionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, region};
  @override
  HolidayOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolidayOverrideRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      dataVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HolidayOverridesTable createAlias(String alias) {
    return $HolidayOverridesTable(attachedDatabase, alias);
  }
}

class HolidayOverrideRow extends DataClass
    implements Insertable<HolidayOverrideRow> {
  final String date;
  final String kind;
  final String title;
  final String region;
  final String dataVersion;
  final DateTime updatedAt;
  const HolidayOverrideRow({
    required this.date,
    required this.kind,
    required this.title,
    required this.region,
    required this.dataVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['region'] = Variable<String>(region);
    map['data_version'] = Variable<String>(dataVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HolidayOverridesCompanion toCompanion(bool nullToAbsent) {
    return HolidayOverridesCompanion(
      date: Value(date),
      kind: Value(kind),
      title: Value(title),
      region: Value(region),
      dataVersion: Value(dataVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory HolidayOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolidayOverrideRow(
      date: serializer.fromJson<String>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      region: serializer.fromJson<String>(json['region']),
      dataVersion: serializer.fromJson<String>(json['dataVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'region': serializer.toJson<String>(region),
      'dataVersion': serializer.toJson<String>(dataVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HolidayOverrideRow copyWith({
    String? date,
    String? kind,
    String? title,
    String? region,
    String? dataVersion,
    DateTime? updatedAt,
  }) => HolidayOverrideRow(
    date: date ?? this.date,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    region: region ?? this.region,
    dataVersion: dataVersion ?? this.dataVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HolidayOverrideRow copyWithCompanion(HolidayOverridesCompanion data) {
    return HolidayOverrideRow(
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      region: data.region.present ? data.region.value : this.region,
      dataVersion: data.dataVersion.present
          ? data.dataVersion.value
          : this.dataVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolidayOverrideRow(')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('region: $region, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, kind, title, region, dataVersion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolidayOverrideRow &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.region == this.region &&
          other.dataVersion == this.dataVersion &&
          other.updatedAt == this.updatedAt);
}

class HolidayOverridesCompanion extends UpdateCompanion<HolidayOverrideRow> {
  final Value<String> date;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> region;
  final Value<String> dataVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HolidayOverridesCompanion({
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.region = const Value.absent(),
    this.dataVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidayOverridesCompanion.insert({
    required String date,
    required String kind,
    required String title,
    required String region,
    required String dataVersion,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       kind = Value(kind),
       title = Value(title),
       region = Value(region),
       dataVersion = Value(dataVersion),
       updatedAt = Value(updatedAt);
  static Insertable<HolidayOverrideRow> custom({
    Expression<String>? date,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? region,
    Expression<String>? dataVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (region != null) 'region': region,
      if (dataVersion != null) 'data_version': dataVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HolidayOverridesCompanion copyWith({
    Value<String>? date,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? region,
    Value<String>? dataVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HolidayOverridesCompanion(
      date: date ?? this.date,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      region: region ?? this.region,
      dataVersion: dataVersion ?? this.dataVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (dataVersion.present) {
      map['data_version'] = Variable<String>(dataVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidayOverridesCompanion(')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('region: $region, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderSettingsTable extends ReminderSettings
    with TableInfo<$ReminderSettingsTable, ReminderSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dailyNextDayEnabledMeta =
      const VerificationMeta('dailyNextDayEnabled');
  @override
  late final GeneratedColumn<bool> dailyNextDayEnabled = GeneratedColumn<bool>(
    'daily_next_day_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_next_day_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyNextDayTimeMeta = const VerificationMeta(
    'dailyNextDayTime',
  );
  @override
  late final GeneratedColumn<String> dailyNextDayTime = GeneratedColumn<String>(
    'daily_next_day_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('20:00'),
  );
  static const VerificationMeta _adjustedWorkEnabledMeta =
      const VerificationMeta('adjustedWorkEnabled');
  @override
  late final GeneratedColumn<bool> adjustedWorkEnabled = GeneratedColumn<bool>(
    'adjusted_work_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("adjusted_work_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _adjustedWorkLeadDaysMeta =
      const VerificationMeta('adjustedWorkLeadDays');
  @override
  late final GeneratedColumn<int> adjustedWorkLeadDays = GeneratedColumn<int>(
    'adjusted_work_lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weeklyPreviewEnabledMeta =
      const VerificationMeta('weeklyPreviewEnabled');
  @override
  late final GeneratedColumn<bool> weeklyPreviewEnabled = GeneratedColumn<bool>(
    'weekly_preview_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekly_preview_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weeklyPreviewWeekdayMeta =
      const VerificationMeta('weeklyPreviewWeekday');
  @override
  late final GeneratedColumn<int> weeklyPreviewWeekday = GeneratedColumn<int>(
    'weekly_preview_weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _weeklyPreviewTimeMeta = const VerificationMeta(
    'weeklyPreviewTime',
  );
  @override
  late final GeneratedColumn<String> weeklyPreviewTime =
      GeneratedColumn<String>(
        'weekly_preview_time',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('20:00'),
      );
  static const VerificationMeta _countdownEnabledMeta = const VerificationMeta(
    'countdownEnabled',
  );
  @override
  late final GeneratedColumn<bool> countdownEnabled = GeneratedColumn<bool>(
    'countdown_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("countdown_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyNextDayEnabled,
    dailyNextDayTime,
    adjustedWorkEnabled,
    adjustedWorkLeadDays,
    weeklyPreviewEnabled,
    weeklyPreviewWeekday,
    weeklyPreviewTime,
    countdownEnabled,
    timeZoneId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_next_day_enabled')) {
      context.handle(
        _dailyNextDayEnabledMeta,
        dailyNextDayEnabled.isAcceptableOrUnknown(
          data['daily_next_day_enabled']!,
          _dailyNextDayEnabledMeta,
        ),
      );
    }
    if (data.containsKey('daily_next_day_time')) {
      context.handle(
        _dailyNextDayTimeMeta,
        dailyNextDayTime.isAcceptableOrUnknown(
          data['daily_next_day_time']!,
          _dailyNextDayTimeMeta,
        ),
      );
    }
    if (data.containsKey('adjusted_work_enabled')) {
      context.handle(
        _adjustedWorkEnabledMeta,
        adjustedWorkEnabled.isAcceptableOrUnknown(
          data['adjusted_work_enabled']!,
          _adjustedWorkEnabledMeta,
        ),
      );
    }
    if (data.containsKey('adjusted_work_lead_days')) {
      context.handle(
        _adjustedWorkLeadDaysMeta,
        adjustedWorkLeadDays.isAcceptableOrUnknown(
          data['adjusted_work_lead_days']!,
          _adjustedWorkLeadDaysMeta,
        ),
      );
    }
    if (data.containsKey('weekly_preview_enabled')) {
      context.handle(
        _weeklyPreviewEnabledMeta,
        weeklyPreviewEnabled.isAcceptableOrUnknown(
          data['weekly_preview_enabled']!,
          _weeklyPreviewEnabledMeta,
        ),
      );
    }
    if (data.containsKey('weekly_preview_weekday')) {
      context.handle(
        _weeklyPreviewWeekdayMeta,
        weeklyPreviewWeekday.isAcceptableOrUnknown(
          data['weekly_preview_weekday']!,
          _weeklyPreviewWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('weekly_preview_time')) {
      context.handle(
        _weeklyPreviewTimeMeta,
        weeklyPreviewTime.isAcceptableOrUnknown(
          data['weekly_preview_time']!,
          _weeklyPreviewTimeMeta,
        ),
      );
    }
    if (data.containsKey('countdown_enabled')) {
      context.handle(
        _countdownEnabledMeta,
        countdownEnabled.isAcceptableOrUnknown(
          data['countdown_enabled']!,
          _countdownEnabledMeta,
        ),
      );
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyNextDayEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_next_day_enabled'],
      )!,
      dailyNextDayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_next_day_time'],
      )!,
      adjustedWorkEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}adjusted_work_enabled'],
      )!,
      adjustedWorkLeadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjusted_work_lead_days'],
      )!,
      weeklyPreviewEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_preview_enabled'],
      )!,
      weeklyPreviewWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_preview_weekday'],
      )!,
      weeklyPreviewTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekly_preview_time'],
      )!,
      countdownEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}countdown_enabled'],
      )!,
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      )!,
    );
  }

  @override
  $ReminderSettingsTable createAlias(String alias) {
    return $ReminderSettingsTable(attachedDatabase, alias);
  }
}

class ReminderSettingsRow extends DataClass
    implements Insertable<ReminderSettingsRow> {
  final int id;
  final bool dailyNextDayEnabled;
  final String dailyNextDayTime;
  final bool adjustedWorkEnabled;
  final int adjustedWorkLeadDays;
  final bool weeklyPreviewEnabled;
  final int weeklyPreviewWeekday;
  final String weeklyPreviewTime;
  final bool countdownEnabled;
  final String timeZoneId;
  const ReminderSettingsRow({
    required this.id,
    required this.dailyNextDayEnabled,
    required this.dailyNextDayTime,
    required this.adjustedWorkEnabled,
    required this.adjustedWorkLeadDays,
    required this.weeklyPreviewEnabled,
    required this.weeklyPreviewWeekday,
    required this.weeklyPreviewTime,
    required this.countdownEnabled,
    required this.timeZoneId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_next_day_enabled'] = Variable<bool>(dailyNextDayEnabled);
    map['daily_next_day_time'] = Variable<String>(dailyNextDayTime);
    map['adjusted_work_enabled'] = Variable<bool>(adjustedWorkEnabled);
    map['adjusted_work_lead_days'] = Variable<int>(adjustedWorkLeadDays);
    map['weekly_preview_enabled'] = Variable<bool>(weeklyPreviewEnabled);
    map['weekly_preview_weekday'] = Variable<int>(weeklyPreviewWeekday);
    map['weekly_preview_time'] = Variable<String>(weeklyPreviewTime);
    map['countdown_enabled'] = Variable<bool>(countdownEnabled);
    map['time_zone_id'] = Variable<String>(timeZoneId);
    return map;
  }

  ReminderSettingsCompanion toCompanion(bool nullToAbsent) {
    return ReminderSettingsCompanion(
      id: Value(id),
      dailyNextDayEnabled: Value(dailyNextDayEnabled),
      dailyNextDayTime: Value(dailyNextDayTime),
      adjustedWorkEnabled: Value(adjustedWorkEnabled),
      adjustedWorkLeadDays: Value(adjustedWorkLeadDays),
      weeklyPreviewEnabled: Value(weeklyPreviewEnabled),
      weeklyPreviewWeekday: Value(weeklyPreviewWeekday),
      weeklyPreviewTime: Value(weeklyPreviewTime),
      countdownEnabled: Value(countdownEnabled),
      timeZoneId: Value(timeZoneId),
    );
  }

  factory ReminderSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      dailyNextDayEnabled: serializer.fromJson<bool>(
        json['dailyNextDayEnabled'],
      ),
      dailyNextDayTime: serializer.fromJson<String>(json['dailyNextDayTime']),
      adjustedWorkEnabled: serializer.fromJson<bool>(
        json['adjustedWorkEnabled'],
      ),
      adjustedWorkLeadDays: serializer.fromJson<int>(
        json['adjustedWorkLeadDays'],
      ),
      weeklyPreviewEnabled: serializer.fromJson<bool>(
        json['weeklyPreviewEnabled'],
      ),
      weeklyPreviewWeekday: serializer.fromJson<int>(
        json['weeklyPreviewWeekday'],
      ),
      weeklyPreviewTime: serializer.fromJson<String>(json['weeklyPreviewTime']),
      countdownEnabled: serializer.fromJson<bool>(json['countdownEnabled']),
      timeZoneId: serializer.fromJson<String>(json['timeZoneId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyNextDayEnabled': serializer.toJson<bool>(dailyNextDayEnabled),
      'dailyNextDayTime': serializer.toJson<String>(dailyNextDayTime),
      'adjustedWorkEnabled': serializer.toJson<bool>(adjustedWorkEnabled),
      'adjustedWorkLeadDays': serializer.toJson<int>(adjustedWorkLeadDays),
      'weeklyPreviewEnabled': serializer.toJson<bool>(weeklyPreviewEnabled),
      'weeklyPreviewWeekday': serializer.toJson<int>(weeklyPreviewWeekday),
      'weeklyPreviewTime': serializer.toJson<String>(weeklyPreviewTime),
      'countdownEnabled': serializer.toJson<bool>(countdownEnabled),
      'timeZoneId': serializer.toJson<String>(timeZoneId),
    };
  }

  ReminderSettingsRow copyWith({
    int? id,
    bool? dailyNextDayEnabled,
    String? dailyNextDayTime,
    bool? adjustedWorkEnabled,
    int? adjustedWorkLeadDays,
    bool? weeklyPreviewEnabled,
    int? weeklyPreviewWeekday,
    String? weeklyPreviewTime,
    bool? countdownEnabled,
    String? timeZoneId,
  }) => ReminderSettingsRow(
    id: id ?? this.id,
    dailyNextDayEnabled: dailyNextDayEnabled ?? this.dailyNextDayEnabled,
    dailyNextDayTime: dailyNextDayTime ?? this.dailyNextDayTime,
    adjustedWorkEnabled: adjustedWorkEnabled ?? this.adjustedWorkEnabled,
    adjustedWorkLeadDays: adjustedWorkLeadDays ?? this.adjustedWorkLeadDays,
    weeklyPreviewEnabled: weeklyPreviewEnabled ?? this.weeklyPreviewEnabled,
    weeklyPreviewWeekday: weeklyPreviewWeekday ?? this.weeklyPreviewWeekday,
    weeklyPreviewTime: weeklyPreviewTime ?? this.weeklyPreviewTime,
    countdownEnabled: countdownEnabled ?? this.countdownEnabled,
    timeZoneId: timeZoneId ?? this.timeZoneId,
  );
  ReminderSettingsRow copyWithCompanion(ReminderSettingsCompanion data) {
    return ReminderSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      dailyNextDayEnabled: data.dailyNextDayEnabled.present
          ? data.dailyNextDayEnabled.value
          : this.dailyNextDayEnabled,
      dailyNextDayTime: data.dailyNextDayTime.present
          ? data.dailyNextDayTime.value
          : this.dailyNextDayTime,
      adjustedWorkEnabled: data.adjustedWorkEnabled.present
          ? data.adjustedWorkEnabled.value
          : this.adjustedWorkEnabled,
      adjustedWorkLeadDays: data.adjustedWorkLeadDays.present
          ? data.adjustedWorkLeadDays.value
          : this.adjustedWorkLeadDays,
      weeklyPreviewEnabled: data.weeklyPreviewEnabled.present
          ? data.weeklyPreviewEnabled.value
          : this.weeklyPreviewEnabled,
      weeklyPreviewWeekday: data.weeklyPreviewWeekday.present
          ? data.weeklyPreviewWeekday.value
          : this.weeklyPreviewWeekday,
      weeklyPreviewTime: data.weeklyPreviewTime.present
          ? data.weeklyPreviewTime.value
          : this.weeklyPreviewTime,
      countdownEnabled: data.countdownEnabled.present
          ? data.countdownEnabled.value
          : this.countdownEnabled,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSettingsRow(')
          ..write('id: $id, ')
          ..write('dailyNextDayEnabled: $dailyNextDayEnabled, ')
          ..write('dailyNextDayTime: $dailyNextDayTime, ')
          ..write('adjustedWorkEnabled: $adjustedWorkEnabled, ')
          ..write('adjustedWorkLeadDays: $adjustedWorkLeadDays, ')
          ..write('weeklyPreviewEnabled: $weeklyPreviewEnabled, ')
          ..write('weeklyPreviewWeekday: $weeklyPreviewWeekday, ')
          ..write('weeklyPreviewTime: $weeklyPreviewTime, ')
          ..write('countdownEnabled: $countdownEnabled, ')
          ..write('timeZoneId: $timeZoneId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dailyNextDayEnabled,
    dailyNextDayTime,
    adjustedWorkEnabled,
    adjustedWorkLeadDays,
    weeklyPreviewEnabled,
    weeklyPreviewWeekday,
    weeklyPreviewTime,
    countdownEnabled,
    timeZoneId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderSettingsRow &&
          other.id == this.id &&
          other.dailyNextDayEnabled == this.dailyNextDayEnabled &&
          other.dailyNextDayTime == this.dailyNextDayTime &&
          other.adjustedWorkEnabled == this.adjustedWorkEnabled &&
          other.adjustedWorkLeadDays == this.adjustedWorkLeadDays &&
          other.weeklyPreviewEnabled == this.weeklyPreviewEnabled &&
          other.weeklyPreviewWeekday == this.weeklyPreviewWeekday &&
          other.weeklyPreviewTime == this.weeklyPreviewTime &&
          other.countdownEnabled == this.countdownEnabled &&
          other.timeZoneId == this.timeZoneId);
}

class ReminderSettingsCompanion extends UpdateCompanion<ReminderSettingsRow> {
  final Value<int> id;
  final Value<bool> dailyNextDayEnabled;
  final Value<String> dailyNextDayTime;
  final Value<bool> adjustedWorkEnabled;
  final Value<int> adjustedWorkLeadDays;
  final Value<bool> weeklyPreviewEnabled;
  final Value<int> weeklyPreviewWeekday;
  final Value<String> weeklyPreviewTime;
  final Value<bool> countdownEnabled;
  final Value<String> timeZoneId;
  const ReminderSettingsCompanion({
    this.id = const Value.absent(),
    this.dailyNextDayEnabled = const Value.absent(),
    this.dailyNextDayTime = const Value.absent(),
    this.adjustedWorkEnabled = const Value.absent(),
    this.adjustedWorkLeadDays = const Value.absent(),
    this.weeklyPreviewEnabled = const Value.absent(),
    this.weeklyPreviewWeekday = const Value.absent(),
    this.weeklyPreviewTime = const Value.absent(),
    this.countdownEnabled = const Value.absent(),
    this.timeZoneId = const Value.absent(),
  });
  ReminderSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyNextDayEnabled = const Value.absent(),
    this.dailyNextDayTime = const Value.absent(),
    this.adjustedWorkEnabled = const Value.absent(),
    this.adjustedWorkLeadDays = const Value.absent(),
    this.weeklyPreviewEnabled = const Value.absent(),
    this.weeklyPreviewWeekday = const Value.absent(),
    this.weeklyPreviewTime = const Value.absent(),
    this.countdownEnabled = const Value.absent(),
    this.timeZoneId = const Value.absent(),
  });
  static Insertable<ReminderSettingsRow> custom({
    Expression<int>? id,
    Expression<bool>? dailyNextDayEnabled,
    Expression<String>? dailyNextDayTime,
    Expression<bool>? adjustedWorkEnabled,
    Expression<int>? adjustedWorkLeadDays,
    Expression<bool>? weeklyPreviewEnabled,
    Expression<int>? weeklyPreviewWeekday,
    Expression<String>? weeklyPreviewTime,
    Expression<bool>? countdownEnabled,
    Expression<String>? timeZoneId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyNextDayEnabled != null)
        'daily_next_day_enabled': dailyNextDayEnabled,
      if (dailyNextDayTime != null) 'daily_next_day_time': dailyNextDayTime,
      if (adjustedWorkEnabled != null)
        'adjusted_work_enabled': adjustedWorkEnabled,
      if (adjustedWorkLeadDays != null)
        'adjusted_work_lead_days': adjustedWorkLeadDays,
      if (weeklyPreviewEnabled != null)
        'weekly_preview_enabled': weeklyPreviewEnabled,
      if (weeklyPreviewWeekday != null)
        'weekly_preview_weekday': weeklyPreviewWeekday,
      if (weeklyPreviewTime != null) 'weekly_preview_time': weeklyPreviewTime,
      if (countdownEnabled != null) 'countdown_enabled': countdownEnabled,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
    });
  }

  ReminderSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? dailyNextDayEnabled,
    Value<String>? dailyNextDayTime,
    Value<bool>? adjustedWorkEnabled,
    Value<int>? adjustedWorkLeadDays,
    Value<bool>? weeklyPreviewEnabled,
    Value<int>? weeklyPreviewWeekday,
    Value<String>? weeklyPreviewTime,
    Value<bool>? countdownEnabled,
    Value<String>? timeZoneId,
  }) {
    return ReminderSettingsCompanion(
      id: id ?? this.id,
      dailyNextDayEnabled: dailyNextDayEnabled ?? this.dailyNextDayEnabled,
      dailyNextDayTime: dailyNextDayTime ?? this.dailyNextDayTime,
      adjustedWorkEnabled: adjustedWorkEnabled ?? this.adjustedWorkEnabled,
      adjustedWorkLeadDays: adjustedWorkLeadDays ?? this.adjustedWorkLeadDays,
      weeklyPreviewEnabled: weeklyPreviewEnabled ?? this.weeklyPreviewEnabled,
      weeklyPreviewWeekday: weeklyPreviewWeekday ?? this.weeklyPreviewWeekday,
      weeklyPreviewTime: weeklyPreviewTime ?? this.weeklyPreviewTime,
      countdownEnabled: countdownEnabled ?? this.countdownEnabled,
      timeZoneId: timeZoneId ?? this.timeZoneId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyNextDayEnabled.present) {
      map['daily_next_day_enabled'] = Variable<bool>(dailyNextDayEnabled.value);
    }
    if (dailyNextDayTime.present) {
      map['daily_next_day_time'] = Variable<String>(dailyNextDayTime.value);
    }
    if (adjustedWorkEnabled.present) {
      map['adjusted_work_enabled'] = Variable<bool>(adjustedWorkEnabled.value);
    }
    if (adjustedWorkLeadDays.present) {
      map['adjusted_work_lead_days'] = Variable<int>(
        adjustedWorkLeadDays.value,
      );
    }
    if (weeklyPreviewEnabled.present) {
      map['weekly_preview_enabled'] = Variable<bool>(
        weeklyPreviewEnabled.value,
      );
    }
    if (weeklyPreviewWeekday.present) {
      map['weekly_preview_weekday'] = Variable<int>(weeklyPreviewWeekday.value);
    }
    if (weeklyPreviewTime.present) {
      map['weekly_preview_time'] = Variable<String>(weeklyPreviewTime.value);
    }
    if (countdownEnabled.present) {
      map['countdown_enabled'] = Variable<bool>(countdownEnabled.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyNextDayEnabled: $dailyNextDayEnabled, ')
          ..write('dailyNextDayTime: $dailyNextDayTime, ')
          ..write('adjustedWorkEnabled: $adjustedWorkEnabled, ')
          ..write('adjustedWorkLeadDays: $adjustedWorkLeadDays, ')
          ..write('weeklyPreviewEnabled: $weeklyPreviewEnabled, ')
          ..write('weeklyPreviewWeekday: $weeklyPreviewWeekday, ')
          ..write('weeklyPreviewTime: $weeklyPreviewTime, ')
          ..write('countdownEnabled: $countdownEnabled, ')
          ..write('timeZoneId: $timeZoneId')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _visualStyleMeta = const VerificationMeta(
    'visualStyle',
  );
  @override
  late final GeneratedColumn<String> visualStyle = GeneratedColumn<String>(
    'visual_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('classic'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('zh_CN'),
  );
  static const VerificationMeta _firstLaunchCompletedMeta =
      const VerificationMeta('firstLaunchCompleted');
  @override
  late final GeneratedColumn<bool> firstLaunchCompleted = GeneratedColumn<bool>(
    'first_launch_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("first_launch_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _desktopWidgetSizeMeta = const VerificationMeta(
    'desktopWidgetSize',
  );
  @override
  late final GeneratedColumn<String> desktopWidgetSize =
      GeneratedColumn<String>(
        'desktop_widget_size',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('small'),
      );
  static const VerificationMeta _desktopWidgetLargeDateShapeMeta =
      const VerificationMeta('desktopWidgetLargeDateShape');
  @override
  late final GeneratedColumn<String> desktopWidgetLargeDateShape =
      GeneratedColumn<String>(
        'desktop_widget_large_date_shape',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('roundedRectangle'),
      );
  static const VerificationMeta _desktopWidgetTodayHighlightStyleMeta =
      const VerificationMeta('desktopWidgetTodayHighlightStyle');
  @override
  late final GeneratedColumn<String> desktopWidgetTodayHighlightStyle =
      GeneratedColumn<String>(
        'desktop_widget_today_highlight_style',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('glowOutline'),
      );
  static const VerificationMeta _desktopWidgetOpacityMeta =
      const VerificationMeta('desktopWidgetOpacity');
  @override
  late final GeneratedColumn<double> desktopWidgetOpacity =
      GeneratedColumn<double>(
        'desktop_widget_opacity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _desktopWidgetAlwaysOnTopMeta =
      const VerificationMeta('desktopWidgetAlwaysOnTop');
  @override
  late final GeneratedColumn<bool> desktopWidgetAlwaysOnTop =
      GeneratedColumn<bool>(
        'desktop_widget_always_on_top',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("desktop_widget_always_on_top" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _desktopWidgetLockedMeta =
      const VerificationMeta('desktopWidgetLocked');
  @override
  late final GeneratedColumn<bool> desktopWidgetLocked = GeneratedColumn<bool>(
    'desktop_widget_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("desktop_widget_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _desktopLaunchAtStartupMeta =
      const VerificationMeta('desktopLaunchAtStartup');
  @override
  late final GeneratedColumn<bool> desktopLaunchAtStartup =
      GeneratedColumn<bool>(
        'desktop_launch_at_startup',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("desktop_launch_at_startup" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _calendarScrollAxisMeta =
      const VerificationMeta('calendarScrollAxis');
  @override
  late final GeneratedColumn<String> calendarScrollAxis =
      GeneratedColumn<String>(
        'calendar_scroll_axis',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('horizontal'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    visualStyle,
    locale,
    firstLaunchCompleted,
    desktopWidgetSize,
    desktopWidgetLargeDateShape,
    desktopWidgetTodayHighlightStyle,
    desktopWidgetOpacity,
    desktopWidgetAlwaysOnTop,
    desktopWidgetLocked,
    desktopLaunchAtStartup,
    calendarScrollAxis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('visual_style')) {
      context.handle(
        _visualStyleMeta,
        visualStyle.isAcceptableOrUnknown(
          data['visual_style']!,
          _visualStyleMeta,
        ),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('first_launch_completed')) {
      context.handle(
        _firstLaunchCompletedMeta,
        firstLaunchCompleted.isAcceptableOrUnknown(
          data['first_launch_completed']!,
          _firstLaunchCompletedMeta,
        ),
      );
    }
    if (data.containsKey('desktop_widget_size')) {
      context.handle(
        _desktopWidgetSizeMeta,
        desktopWidgetSize.isAcceptableOrUnknown(
          data['desktop_widget_size']!,
          _desktopWidgetSizeMeta,
        ),
      );
    }
    if (data.containsKey('desktop_widget_large_date_shape')) {
      context.handle(
        _desktopWidgetLargeDateShapeMeta,
        desktopWidgetLargeDateShape.isAcceptableOrUnknown(
          data['desktop_widget_large_date_shape']!,
          _desktopWidgetLargeDateShapeMeta,
        ),
      );
    }
    if (data.containsKey('desktop_widget_today_highlight_style')) {
      context.handle(
        _desktopWidgetTodayHighlightStyleMeta,
        desktopWidgetTodayHighlightStyle.isAcceptableOrUnknown(
          data['desktop_widget_today_highlight_style']!,
          _desktopWidgetTodayHighlightStyleMeta,
        ),
      );
    }
    if (data.containsKey('desktop_widget_opacity')) {
      context.handle(
        _desktopWidgetOpacityMeta,
        desktopWidgetOpacity.isAcceptableOrUnknown(
          data['desktop_widget_opacity']!,
          _desktopWidgetOpacityMeta,
        ),
      );
    }
    if (data.containsKey('desktop_widget_always_on_top')) {
      context.handle(
        _desktopWidgetAlwaysOnTopMeta,
        desktopWidgetAlwaysOnTop.isAcceptableOrUnknown(
          data['desktop_widget_always_on_top']!,
          _desktopWidgetAlwaysOnTopMeta,
        ),
      );
    }
    if (data.containsKey('desktop_widget_locked')) {
      context.handle(
        _desktopWidgetLockedMeta,
        desktopWidgetLocked.isAcceptableOrUnknown(
          data['desktop_widget_locked']!,
          _desktopWidgetLockedMeta,
        ),
      );
    }
    if (data.containsKey('desktop_launch_at_startup')) {
      context.handle(
        _desktopLaunchAtStartupMeta,
        desktopLaunchAtStartup.isAcceptableOrUnknown(
          data['desktop_launch_at_startup']!,
          _desktopLaunchAtStartupMeta,
        ),
      );
    }
    if (data.containsKey('calendar_scroll_axis')) {
      context.handle(
        _calendarScrollAxisMeta,
        calendarScrollAxis.isAcceptableOrUnknown(
          data['calendar_scroll_axis']!,
          _calendarScrollAxisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      visualStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visual_style'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      firstLaunchCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}first_launch_completed'],
      )!,
      desktopWidgetSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desktop_widget_size'],
      )!,
      desktopWidgetLargeDateShape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desktop_widget_large_date_shape'],
      )!,
      desktopWidgetTodayHighlightStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desktop_widget_today_highlight_style'],
      )!,
      desktopWidgetOpacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}desktop_widget_opacity'],
      )!,
      desktopWidgetAlwaysOnTop: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}desktop_widget_always_on_top'],
      )!,
      desktopWidgetLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}desktop_widget_locked'],
      )!,
      desktopLaunchAtStartup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}desktop_launch_at_startup'],
      )!,
      calendarScrollAxis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_scroll_axis'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final String themeMode;
  final String visualStyle;
  final String locale;
  final bool firstLaunchCompleted;
  final String desktopWidgetSize;
  final String desktopWidgetLargeDateShape;
  final String desktopWidgetTodayHighlightStyle;
  final double desktopWidgetOpacity;
  final bool desktopWidgetAlwaysOnTop;
  final bool desktopWidgetLocked;
  final bool desktopLaunchAtStartup;
  final String calendarScrollAxis;
  const AppSettingsRow({
    required this.id,
    required this.themeMode,
    required this.visualStyle,
    required this.locale,
    required this.firstLaunchCompleted,
    required this.desktopWidgetSize,
    required this.desktopWidgetLargeDateShape,
    required this.desktopWidgetTodayHighlightStyle,
    required this.desktopWidgetOpacity,
    required this.desktopWidgetAlwaysOnTop,
    required this.desktopWidgetLocked,
    required this.desktopLaunchAtStartup,
    required this.calendarScrollAxis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['visual_style'] = Variable<String>(visualStyle);
    map['locale'] = Variable<String>(locale);
    map['first_launch_completed'] = Variable<bool>(firstLaunchCompleted);
    map['desktop_widget_size'] = Variable<String>(desktopWidgetSize);
    map['desktop_widget_large_date_shape'] = Variable<String>(
      desktopWidgetLargeDateShape,
    );
    map['desktop_widget_today_highlight_style'] = Variable<String>(
      desktopWidgetTodayHighlightStyle,
    );
    map['desktop_widget_opacity'] = Variable<double>(desktopWidgetOpacity);
    map['desktop_widget_always_on_top'] = Variable<bool>(
      desktopWidgetAlwaysOnTop,
    );
    map['desktop_widget_locked'] = Variable<bool>(desktopWidgetLocked);
    map['desktop_launch_at_startup'] = Variable<bool>(desktopLaunchAtStartup);
    map['calendar_scroll_axis'] = Variable<String>(calendarScrollAxis);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      visualStyle: Value(visualStyle),
      locale: Value(locale),
      firstLaunchCompleted: Value(firstLaunchCompleted),
      desktopWidgetSize: Value(desktopWidgetSize),
      desktopWidgetLargeDateShape: Value(desktopWidgetLargeDateShape),
      desktopWidgetTodayHighlightStyle: Value(desktopWidgetTodayHighlightStyle),
      desktopWidgetOpacity: Value(desktopWidgetOpacity),
      desktopWidgetAlwaysOnTop: Value(desktopWidgetAlwaysOnTop),
      desktopWidgetLocked: Value(desktopWidgetLocked),
      desktopLaunchAtStartup: Value(desktopLaunchAtStartup),
      calendarScrollAxis: Value(calendarScrollAxis),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      visualStyle: serializer.fromJson<String>(json['visualStyle']),
      locale: serializer.fromJson<String>(json['locale']),
      firstLaunchCompleted: serializer.fromJson<bool>(
        json['firstLaunchCompleted'],
      ),
      desktopWidgetSize: serializer.fromJson<String>(json['desktopWidgetSize']),
      desktopWidgetLargeDateShape: serializer.fromJson<String>(
        json['desktopWidgetLargeDateShape'],
      ),
      desktopWidgetTodayHighlightStyle: serializer.fromJson<String>(
        json['desktopWidgetTodayHighlightStyle'],
      ),
      desktopWidgetOpacity: serializer.fromJson<double>(
        json['desktopWidgetOpacity'],
      ),
      desktopWidgetAlwaysOnTop: serializer.fromJson<bool>(
        json['desktopWidgetAlwaysOnTop'],
      ),
      desktopWidgetLocked: serializer.fromJson<bool>(
        json['desktopWidgetLocked'],
      ),
      desktopLaunchAtStartup: serializer.fromJson<bool>(
        json['desktopLaunchAtStartup'],
      ),
      calendarScrollAxis: serializer.fromJson<String>(
        json['calendarScrollAxis'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'visualStyle': serializer.toJson<String>(visualStyle),
      'locale': serializer.toJson<String>(locale),
      'firstLaunchCompleted': serializer.toJson<bool>(firstLaunchCompleted),
      'desktopWidgetSize': serializer.toJson<String>(desktopWidgetSize),
      'desktopWidgetLargeDateShape': serializer.toJson<String>(
        desktopWidgetLargeDateShape,
      ),
      'desktopWidgetTodayHighlightStyle': serializer.toJson<String>(
        desktopWidgetTodayHighlightStyle,
      ),
      'desktopWidgetOpacity': serializer.toJson<double>(desktopWidgetOpacity),
      'desktopWidgetAlwaysOnTop': serializer.toJson<bool>(
        desktopWidgetAlwaysOnTop,
      ),
      'desktopWidgetLocked': serializer.toJson<bool>(desktopWidgetLocked),
      'desktopLaunchAtStartup': serializer.toJson<bool>(desktopLaunchAtStartup),
      'calendarScrollAxis': serializer.toJson<String>(calendarScrollAxis),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    String? themeMode,
    String? visualStyle,
    String? locale,
    bool? firstLaunchCompleted,
    String? desktopWidgetSize,
    String? desktopWidgetLargeDateShape,
    String? desktopWidgetTodayHighlightStyle,
    double? desktopWidgetOpacity,
    bool? desktopWidgetAlwaysOnTop,
    bool? desktopWidgetLocked,
    bool? desktopLaunchAtStartup,
    String? calendarScrollAxis,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    visualStyle: visualStyle ?? this.visualStyle,
    locale: locale ?? this.locale,
    firstLaunchCompleted: firstLaunchCompleted ?? this.firstLaunchCompleted,
    desktopWidgetSize: desktopWidgetSize ?? this.desktopWidgetSize,
    desktopWidgetLargeDateShape:
        desktopWidgetLargeDateShape ?? this.desktopWidgetLargeDateShape,
    desktopWidgetTodayHighlightStyle:
        desktopWidgetTodayHighlightStyle ??
        this.desktopWidgetTodayHighlightStyle,
    desktopWidgetOpacity: desktopWidgetOpacity ?? this.desktopWidgetOpacity,
    desktopWidgetAlwaysOnTop:
        desktopWidgetAlwaysOnTop ?? this.desktopWidgetAlwaysOnTop,
    desktopWidgetLocked: desktopWidgetLocked ?? this.desktopWidgetLocked,
    desktopLaunchAtStartup:
        desktopLaunchAtStartup ?? this.desktopLaunchAtStartup,
    calendarScrollAxis: calendarScrollAxis ?? this.calendarScrollAxis,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      visualStyle: data.visualStyle.present
          ? data.visualStyle.value
          : this.visualStyle,
      locale: data.locale.present ? data.locale.value : this.locale,
      firstLaunchCompleted: data.firstLaunchCompleted.present
          ? data.firstLaunchCompleted.value
          : this.firstLaunchCompleted,
      desktopWidgetSize: data.desktopWidgetSize.present
          ? data.desktopWidgetSize.value
          : this.desktopWidgetSize,
      desktopWidgetLargeDateShape: data.desktopWidgetLargeDateShape.present
          ? data.desktopWidgetLargeDateShape.value
          : this.desktopWidgetLargeDateShape,
      desktopWidgetTodayHighlightStyle:
          data.desktopWidgetTodayHighlightStyle.present
          ? data.desktopWidgetTodayHighlightStyle.value
          : this.desktopWidgetTodayHighlightStyle,
      desktopWidgetOpacity: data.desktopWidgetOpacity.present
          ? data.desktopWidgetOpacity.value
          : this.desktopWidgetOpacity,
      desktopWidgetAlwaysOnTop: data.desktopWidgetAlwaysOnTop.present
          ? data.desktopWidgetAlwaysOnTop.value
          : this.desktopWidgetAlwaysOnTop,
      desktopWidgetLocked: data.desktopWidgetLocked.present
          ? data.desktopWidgetLocked.value
          : this.desktopWidgetLocked,
      desktopLaunchAtStartup: data.desktopLaunchAtStartup.present
          ? data.desktopLaunchAtStartup.value
          : this.desktopLaunchAtStartup,
      calendarScrollAxis: data.calendarScrollAxis.present
          ? data.calendarScrollAxis.value
          : this.calendarScrollAxis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('visualStyle: $visualStyle, ')
          ..write('locale: $locale, ')
          ..write('firstLaunchCompleted: $firstLaunchCompleted, ')
          ..write('desktopWidgetSize: $desktopWidgetSize, ')
          ..write('desktopWidgetLargeDateShape: $desktopWidgetLargeDateShape, ')
          ..write(
            'desktopWidgetTodayHighlightStyle: $desktopWidgetTodayHighlightStyle, ',
          )
          ..write('desktopWidgetOpacity: $desktopWidgetOpacity, ')
          ..write('desktopWidgetAlwaysOnTop: $desktopWidgetAlwaysOnTop, ')
          ..write('desktopWidgetLocked: $desktopWidgetLocked, ')
          ..write('desktopLaunchAtStartup: $desktopLaunchAtStartup, ')
          ..write('calendarScrollAxis: $calendarScrollAxis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    visualStyle,
    locale,
    firstLaunchCompleted,
    desktopWidgetSize,
    desktopWidgetLargeDateShape,
    desktopWidgetTodayHighlightStyle,
    desktopWidgetOpacity,
    desktopWidgetAlwaysOnTop,
    desktopWidgetLocked,
    desktopLaunchAtStartup,
    calendarScrollAxis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.visualStyle == this.visualStyle &&
          other.locale == this.locale &&
          other.firstLaunchCompleted == this.firstLaunchCompleted &&
          other.desktopWidgetSize == this.desktopWidgetSize &&
          other.desktopWidgetLargeDateShape ==
              this.desktopWidgetLargeDateShape &&
          other.desktopWidgetTodayHighlightStyle ==
              this.desktopWidgetTodayHighlightStyle &&
          other.desktopWidgetOpacity == this.desktopWidgetOpacity &&
          other.desktopWidgetAlwaysOnTop == this.desktopWidgetAlwaysOnTop &&
          other.desktopWidgetLocked == this.desktopWidgetLocked &&
          other.desktopLaunchAtStartup == this.desktopLaunchAtStartup &&
          other.calendarScrollAxis == this.calendarScrollAxis);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<String> visualStyle;
  final Value<String> locale;
  final Value<bool> firstLaunchCompleted;
  final Value<String> desktopWidgetSize;
  final Value<String> desktopWidgetLargeDateShape;
  final Value<String> desktopWidgetTodayHighlightStyle;
  final Value<double> desktopWidgetOpacity;
  final Value<bool> desktopWidgetAlwaysOnTop;
  final Value<bool> desktopWidgetLocked;
  final Value<bool> desktopLaunchAtStartup;
  final Value<String> calendarScrollAxis;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.visualStyle = const Value.absent(),
    this.locale = const Value.absent(),
    this.firstLaunchCompleted = const Value.absent(),
    this.desktopWidgetSize = const Value.absent(),
    this.desktopWidgetLargeDateShape = const Value.absent(),
    this.desktopWidgetTodayHighlightStyle = const Value.absent(),
    this.desktopWidgetOpacity = const Value.absent(),
    this.desktopWidgetAlwaysOnTop = const Value.absent(),
    this.desktopWidgetLocked = const Value.absent(),
    this.desktopLaunchAtStartup = const Value.absent(),
    this.calendarScrollAxis = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.visualStyle = const Value.absent(),
    this.locale = const Value.absent(),
    this.firstLaunchCompleted = const Value.absent(),
    this.desktopWidgetSize = const Value.absent(),
    this.desktopWidgetLargeDateShape = const Value.absent(),
    this.desktopWidgetTodayHighlightStyle = const Value.absent(),
    this.desktopWidgetOpacity = const Value.absent(),
    this.desktopWidgetAlwaysOnTop = const Value.absent(),
    this.desktopWidgetLocked = const Value.absent(),
    this.desktopLaunchAtStartup = const Value.absent(),
    this.calendarScrollAxis = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<String>? visualStyle,
    Expression<String>? locale,
    Expression<bool>? firstLaunchCompleted,
    Expression<String>? desktopWidgetSize,
    Expression<String>? desktopWidgetLargeDateShape,
    Expression<String>? desktopWidgetTodayHighlightStyle,
    Expression<double>? desktopWidgetOpacity,
    Expression<bool>? desktopWidgetAlwaysOnTop,
    Expression<bool>? desktopWidgetLocked,
    Expression<bool>? desktopLaunchAtStartup,
    Expression<String>? calendarScrollAxis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (visualStyle != null) 'visual_style': visualStyle,
      if (locale != null) 'locale': locale,
      if (firstLaunchCompleted != null)
        'first_launch_completed': firstLaunchCompleted,
      if (desktopWidgetSize != null) 'desktop_widget_size': desktopWidgetSize,
      if (desktopWidgetLargeDateShape != null)
        'desktop_widget_large_date_shape': desktopWidgetLargeDateShape,
      if (desktopWidgetTodayHighlightStyle != null)
        'desktop_widget_today_highlight_style':
            desktopWidgetTodayHighlightStyle,
      if (desktopWidgetOpacity != null)
        'desktop_widget_opacity': desktopWidgetOpacity,
      if (desktopWidgetAlwaysOnTop != null)
        'desktop_widget_always_on_top': desktopWidgetAlwaysOnTop,
      if (desktopWidgetLocked != null)
        'desktop_widget_locked': desktopWidgetLocked,
      if (desktopLaunchAtStartup != null)
        'desktop_launch_at_startup': desktopLaunchAtStartup,
      if (calendarScrollAxis != null)
        'calendar_scroll_axis': calendarScrollAxis,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<String>? visualStyle,
    Value<String>? locale,
    Value<bool>? firstLaunchCompleted,
    Value<String>? desktopWidgetSize,
    Value<String>? desktopWidgetLargeDateShape,
    Value<String>? desktopWidgetTodayHighlightStyle,
    Value<double>? desktopWidgetOpacity,
    Value<bool>? desktopWidgetAlwaysOnTop,
    Value<bool>? desktopWidgetLocked,
    Value<bool>? desktopLaunchAtStartup,
    Value<String>? calendarScrollAxis,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      visualStyle: visualStyle ?? this.visualStyle,
      locale: locale ?? this.locale,
      firstLaunchCompleted: firstLaunchCompleted ?? this.firstLaunchCompleted,
      desktopWidgetSize: desktopWidgetSize ?? this.desktopWidgetSize,
      desktopWidgetLargeDateShape:
          desktopWidgetLargeDateShape ?? this.desktopWidgetLargeDateShape,
      desktopWidgetTodayHighlightStyle:
          desktopWidgetTodayHighlightStyle ??
          this.desktopWidgetTodayHighlightStyle,
      desktopWidgetOpacity: desktopWidgetOpacity ?? this.desktopWidgetOpacity,
      desktopWidgetAlwaysOnTop:
          desktopWidgetAlwaysOnTop ?? this.desktopWidgetAlwaysOnTop,
      desktopWidgetLocked: desktopWidgetLocked ?? this.desktopWidgetLocked,
      desktopLaunchAtStartup:
          desktopLaunchAtStartup ?? this.desktopLaunchAtStartup,
      calendarScrollAxis: calendarScrollAxis ?? this.calendarScrollAxis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (visualStyle.present) {
      map['visual_style'] = Variable<String>(visualStyle.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (firstLaunchCompleted.present) {
      map['first_launch_completed'] = Variable<bool>(
        firstLaunchCompleted.value,
      );
    }
    if (desktopWidgetSize.present) {
      map['desktop_widget_size'] = Variable<String>(desktopWidgetSize.value);
    }
    if (desktopWidgetLargeDateShape.present) {
      map['desktop_widget_large_date_shape'] = Variable<String>(
        desktopWidgetLargeDateShape.value,
      );
    }
    if (desktopWidgetTodayHighlightStyle.present) {
      map['desktop_widget_today_highlight_style'] = Variable<String>(
        desktopWidgetTodayHighlightStyle.value,
      );
    }
    if (desktopWidgetOpacity.present) {
      map['desktop_widget_opacity'] = Variable<double>(
        desktopWidgetOpacity.value,
      );
    }
    if (desktopWidgetAlwaysOnTop.present) {
      map['desktop_widget_always_on_top'] = Variable<bool>(
        desktopWidgetAlwaysOnTop.value,
      );
    }
    if (desktopWidgetLocked.present) {
      map['desktop_widget_locked'] = Variable<bool>(desktopWidgetLocked.value);
    }
    if (desktopLaunchAtStartup.present) {
      map['desktop_launch_at_startup'] = Variable<bool>(
        desktopLaunchAtStartup.value,
      );
    }
    if (calendarScrollAxis.present) {
      map['calendar_scroll_axis'] = Variable<String>(calendarScrollAxis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('visualStyle: $visualStyle, ')
          ..write('locale: $locale, ')
          ..write('firstLaunchCompleted: $firstLaunchCompleted, ')
          ..write('desktopWidgetSize: $desktopWidgetSize, ')
          ..write('desktopWidgetLargeDateShape: $desktopWidgetLargeDateShape, ')
          ..write(
            'desktopWidgetTodayHighlightStyle: $desktopWidgetTodayHighlightStyle, ',
          )
          ..write('desktopWidgetOpacity: $desktopWidgetOpacity, ')
          ..write('desktopWidgetAlwaysOnTop: $desktopWidgetAlwaysOnTop, ')
          ..write('desktopWidgetLocked: $desktopWidgetLocked, ')
          ..write('desktopLaunchAtStartup: $desktopLaunchAtStartup, ')
          ..write('calendarScrollAxis: $calendarScrollAxis')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    attemptCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;
  const SyncQueueRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    required this.attemptCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueRow copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    DateTime? createdAt,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    attemptCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScheduleProfilesTable scheduleProfiles = $ScheduleProfilesTable(
    this,
  );
  late final $DayOverridesTable dayOverrides = $DayOverridesTable(this);
  late final $HolidayOverridesTable holidayOverrides = $HolidayOverridesTable(
    this,
  );
  late final $ReminderSettingsTable reminderSettings = $ReminderSettingsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scheduleProfiles,
    dayOverrides,
    holidayOverrides,
    reminderSettings,
    appSettings,
    syncQueue,
  ];
}

typedef $$ScheduleProfilesTableCreateCompanionBuilder =
    ScheduleProfilesCompanion Function({
      required String id,
      required String name,
      required String patternType,
      required String anchorDate,
      Value<String?> anchorWeekType,
      Value<String> cycleDaysJson,
      Value<bool> holidayOverridesEnabled,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ScheduleProfilesTableUpdateCompanionBuilder =
    ScheduleProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> patternType,
      Value<String> anchorDate,
      Value<String?> anchorWeekType,
      Value<String> cycleDaysJson,
      Value<bool> holidayOverridesEnabled,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ScheduleProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScheduleProfilesTable,
          ScheduleProfileRow
        > {
  $$ScheduleProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DayOverridesTable, List<DayOverrideRow>>
  _dayOverridesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dayOverrides,
    aliasName: $_aliasNameGenerator(
      db.scheduleProfiles.id,
      db.dayOverrides.profileId,
    ),
  );

  $$DayOverridesTableProcessedTableManager get dayOverridesRefs {
    final manager = $$DayOverridesTableTableManager(
      $_db,
      $_db.dayOverrides,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dayOverridesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScheduleProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleProfilesTable> {
  $$ScheduleProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternType => $composableBuilder(
    column: $table.patternType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorWeekType => $composableBuilder(
    column: $table.anchorWeekType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleDaysJson => $composableBuilder(
    column: $table.cycleDaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get holidayOverridesEnabled => $composableBuilder(
    column: $table.holidayOverridesEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dayOverridesRefs(
    Expression<bool> Function($$DayOverridesTableFilterComposer f) f,
  ) {
    final $$DayOverridesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayOverrides,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayOverridesTableFilterComposer(
            $db: $db,
            $table: $db.dayOverrides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleProfilesTable> {
  $$ScheduleProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternType => $composableBuilder(
    column: $table.patternType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorWeekType => $composableBuilder(
    column: $table.anchorWeekType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleDaysJson => $composableBuilder(
    column: $table.cycleDaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get holidayOverridesEnabled => $composableBuilder(
    column: $table.holidayOverridesEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleProfilesTable> {
  $$ScheduleProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get patternType => $composableBuilder(
    column: $table.patternType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorWeekType => $composableBuilder(
    column: $table.anchorWeekType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cycleDaysJson => $composableBuilder(
    column: $table.cycleDaysJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get holidayOverridesEnabled => $composableBuilder(
    column: $table.holidayOverridesEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> dayOverridesRefs<T extends Object>(
    Expression<T> Function($$DayOverridesTableAnnotationComposer a) f,
  ) {
    final $$DayOverridesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayOverrides,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayOverridesTableAnnotationComposer(
            $db: $db,
            $table: $db.dayOverrides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleProfilesTable,
          ScheduleProfileRow,
          $$ScheduleProfilesTableFilterComposer,
          $$ScheduleProfilesTableOrderingComposer,
          $$ScheduleProfilesTableAnnotationComposer,
          $$ScheduleProfilesTableCreateCompanionBuilder,
          $$ScheduleProfilesTableUpdateCompanionBuilder,
          (ScheduleProfileRow, $$ScheduleProfilesTableReferences),
          ScheduleProfileRow,
          PrefetchHooks Function({bool dayOverridesRefs})
        > {
  $$ScheduleProfilesTableTableManager(
    _$AppDatabase db,
    $ScheduleProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> patternType = const Value.absent(),
                Value<String> anchorDate = const Value.absent(),
                Value<String?> anchorWeekType = const Value.absent(),
                Value<String> cycleDaysJson = const Value.absent(),
                Value<bool> holidayOverridesEnabled = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleProfilesCompanion(
                id: id,
                name: name,
                patternType: patternType,
                anchorDate: anchorDate,
                anchorWeekType: anchorWeekType,
                cycleDaysJson: cycleDaysJson,
                holidayOverridesEnabled: holidayOverridesEnabled,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String patternType,
                required String anchorDate,
                Value<String?> anchorWeekType = const Value.absent(),
                Value<String> cycleDaysJson = const Value.absent(),
                Value<bool> holidayOverridesEnabled = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleProfilesCompanion.insert(
                id: id,
                name: name,
                patternType: patternType,
                anchorDate: anchorDate,
                anchorWeekType: anchorWeekType,
                cycleDaysJson: cycleDaysJson,
                holidayOverridesEnabled: holidayOverridesEnabled,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayOverridesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dayOverridesRefs) db.dayOverrides],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dayOverridesRefs)
                    await $_getPrefetchedData<
                      ScheduleProfileRow,
                      $ScheduleProfilesTable,
                      DayOverrideRow
                    >(
                      currentTable: table,
                      referencedTable: $$ScheduleProfilesTableReferences
                          ._dayOverridesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScheduleProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).dayOverridesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScheduleProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleProfilesTable,
      ScheduleProfileRow,
      $$ScheduleProfilesTableFilterComposer,
      $$ScheduleProfilesTableOrderingComposer,
      $$ScheduleProfilesTableAnnotationComposer,
      $$ScheduleProfilesTableCreateCompanionBuilder,
      $$ScheduleProfilesTableUpdateCompanionBuilder,
      (ScheduleProfileRow, $$ScheduleProfilesTableReferences),
      ScheduleProfileRow,
      PrefetchHooks Function({bool dayOverridesRefs})
    >;
typedef $$DayOverridesTableCreateCompanionBuilder =
    DayOverridesCompanion Function({
      required String id,
      required String date,
      required String profileId,
      required String kind,
      Value<int> overtimeMinutes,
      Value<String?> note,
      required String source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$DayOverridesTableUpdateCompanionBuilder =
    DayOverridesCompanion Function({
      Value<String> id,
      Value<String> date,
      Value<String> profileId,
      Value<String> kind,
      Value<int> overtimeMinutes,
      Value<String?> note,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$DayOverridesTableReferences
    extends BaseReferences<_$AppDatabase, $DayOverridesTable, DayOverrideRow> {
  $$DayOverridesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.scheduleProfiles.createAlias(
        $_aliasNameGenerator(db.dayOverrides.profileId, db.scheduleProfiles.id),
      );

  $$ScheduleProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ScheduleProfilesTableTableManager(
      $_db,
      $_db.scheduleProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DayOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $DayOverridesTable> {
  $$DayOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overtimeMinutes => $composableBuilder(
    column: $table.overtimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScheduleProfilesTableFilterComposer get profileId {
    final $$ScheduleProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.scheduleProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleProfilesTableFilterComposer(
            $db: $db,
            $table: $db.scheduleProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayOverridesTable> {
  $$DayOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overtimeMinutes => $composableBuilder(
    column: $table.overtimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScheduleProfilesTableOrderingComposer get profileId {
    final $$ScheduleProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.scheduleProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.scheduleProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayOverridesTable> {
  $$DayOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get overtimeMinutes => $composableBuilder(
    column: $table.overtimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ScheduleProfilesTableAnnotationComposer get profileId {
    final $$ScheduleProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.scheduleProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayOverridesTable,
          DayOverrideRow,
          $$DayOverridesTableFilterComposer,
          $$DayOverridesTableOrderingComposer,
          $$DayOverridesTableAnnotationComposer,
          $$DayOverridesTableCreateCompanionBuilder,
          $$DayOverridesTableUpdateCompanionBuilder,
          (DayOverrideRow, $$DayOverridesTableReferences),
          DayOverrideRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$DayOverridesTableTableManager(_$AppDatabase db, $DayOverridesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> overtimeMinutes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayOverridesCompanion(
                id: id,
                date: date,
                profileId: profileId,
                kind: kind,
                overtimeMinutes: overtimeMinutes,
                note: note,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String date,
                required String profileId,
                required String kind,
                Value<int> overtimeMinutes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String source,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayOverridesCompanion.insert(
                id: id,
                date: date,
                profileId: profileId,
                kind: kind,
                overtimeMinutes: overtimeMinutes,
                note: note,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DayOverridesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$DayOverridesTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$DayOverridesTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DayOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayOverridesTable,
      DayOverrideRow,
      $$DayOverridesTableFilterComposer,
      $$DayOverridesTableOrderingComposer,
      $$DayOverridesTableAnnotationComposer,
      $$DayOverridesTableCreateCompanionBuilder,
      $$DayOverridesTableUpdateCompanionBuilder,
      (DayOverrideRow, $$DayOverridesTableReferences),
      DayOverrideRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$HolidayOverridesTableCreateCompanionBuilder =
    HolidayOverridesCompanion Function({
      required String date,
      required String kind,
      required String title,
      required String region,
      required String dataVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HolidayOverridesTableUpdateCompanionBuilder =
    HolidayOverridesCompanion Function({
      Value<String> date,
      Value<String> kind,
      Value<String> title,
      Value<String> region,
      Value<String> dataVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HolidayOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $HolidayOverridesTable> {
  $$HolidayOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HolidayOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidayOverridesTable> {
  $$HolidayOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HolidayOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidayOverridesTable> {
  $$HolidayOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HolidayOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolidayOverridesTable,
          HolidayOverrideRow,
          $$HolidayOverridesTableFilterComposer,
          $$HolidayOverridesTableOrderingComposer,
          $$HolidayOverridesTableAnnotationComposer,
          $$HolidayOverridesTableCreateCompanionBuilder,
          $$HolidayOverridesTableUpdateCompanionBuilder,
          (
            HolidayOverrideRow,
            BaseReferences<
              _$AppDatabase,
              $HolidayOverridesTable,
              HolidayOverrideRow
            >,
          ),
          HolidayOverrideRow,
          PrefetchHooks Function()
        > {
  $$HolidayOverridesTableTableManager(
    _$AppDatabase db,
    $HolidayOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidayOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidayOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidayOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> dataVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidayOverridesCompanion(
                date: date,
                kind: kind,
                title: title,
                region: region,
                dataVersion: dataVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String kind,
                required String title,
                required String region,
                required String dataVersion,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HolidayOverridesCompanion.insert(
                date: date,
                kind: kind,
                title: title,
                region: region,
                dataVersion: dataVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HolidayOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolidayOverridesTable,
      HolidayOverrideRow,
      $$HolidayOverridesTableFilterComposer,
      $$HolidayOverridesTableOrderingComposer,
      $$HolidayOverridesTableAnnotationComposer,
      $$HolidayOverridesTableCreateCompanionBuilder,
      $$HolidayOverridesTableUpdateCompanionBuilder,
      (
        HolidayOverrideRow,
        BaseReferences<
          _$AppDatabase,
          $HolidayOverridesTable,
          HolidayOverrideRow
        >,
      ),
      HolidayOverrideRow,
      PrefetchHooks Function()
    >;
typedef $$ReminderSettingsTableCreateCompanionBuilder =
    ReminderSettingsCompanion Function({
      Value<int> id,
      Value<bool> dailyNextDayEnabled,
      Value<String> dailyNextDayTime,
      Value<bool> adjustedWorkEnabled,
      Value<int> adjustedWorkLeadDays,
      Value<bool> weeklyPreviewEnabled,
      Value<int> weeklyPreviewWeekday,
      Value<String> weeklyPreviewTime,
      Value<bool> countdownEnabled,
      Value<String> timeZoneId,
    });
typedef $$ReminderSettingsTableUpdateCompanionBuilder =
    ReminderSettingsCompanion Function({
      Value<int> id,
      Value<bool> dailyNextDayEnabled,
      Value<String> dailyNextDayTime,
      Value<bool> adjustedWorkEnabled,
      Value<int> adjustedWorkLeadDays,
      Value<bool> weeklyPreviewEnabled,
      Value<int> weeklyPreviewWeekday,
      Value<String> weeklyPreviewTime,
      Value<bool> countdownEnabled,
      Value<String> timeZoneId,
    });

class $$ReminderSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderSettingsTable> {
  $$ReminderSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyNextDayEnabled => $composableBuilder(
    column: $table.dailyNextDayEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyNextDayTime => $composableBuilder(
    column: $table.dailyNextDayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get adjustedWorkEnabled => $composableBuilder(
    column: $table.adjustedWorkEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adjustedWorkLeadDays => $composableBuilder(
    column: $table.adjustedWorkLeadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklyPreviewEnabled => $composableBuilder(
    column: $table.weeklyPreviewEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyPreviewWeekday => $composableBuilder(
    column: $table.weeklyPreviewWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weeklyPreviewTime => $composableBuilder(
    column: $table.weeklyPreviewTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countdownEnabled => $composableBuilder(
    column: $table.countdownEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderSettingsTable> {
  $$ReminderSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyNextDayEnabled => $composableBuilder(
    column: $table.dailyNextDayEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyNextDayTime => $composableBuilder(
    column: $table.dailyNextDayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get adjustedWorkEnabled => $composableBuilder(
    column: $table.adjustedWorkEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adjustedWorkLeadDays => $composableBuilder(
    column: $table.adjustedWorkLeadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklyPreviewEnabled => $composableBuilder(
    column: $table.weeklyPreviewEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyPreviewWeekday => $composableBuilder(
    column: $table.weeklyPreviewWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weeklyPreviewTime => $composableBuilder(
    column: $table.weeklyPreviewTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countdownEnabled => $composableBuilder(
    column: $table.countdownEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderSettingsTable> {
  $$ReminderSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get dailyNextDayEnabled => $composableBuilder(
    column: $table.dailyNextDayEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyNextDayTime => $composableBuilder(
    column: $table.dailyNextDayTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get adjustedWorkEnabled => $composableBuilder(
    column: $table.adjustedWorkEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get adjustedWorkLeadDays => $composableBuilder(
    column: $table.adjustedWorkLeadDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklyPreviewEnabled => $composableBuilder(
    column: $table.weeklyPreviewEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyPreviewWeekday => $composableBuilder(
    column: $table.weeklyPreviewWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weeklyPreviewTime => $composableBuilder(
    column: $table.weeklyPreviewTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get countdownEnabled => $composableBuilder(
    column: $table.countdownEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );
}

class $$ReminderSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderSettingsTable,
          ReminderSettingsRow,
          $$ReminderSettingsTableFilterComposer,
          $$ReminderSettingsTableOrderingComposer,
          $$ReminderSettingsTableAnnotationComposer,
          $$ReminderSettingsTableCreateCompanionBuilder,
          $$ReminderSettingsTableUpdateCompanionBuilder,
          (
            ReminderSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $ReminderSettingsTable,
              ReminderSettingsRow
            >,
          ),
          ReminderSettingsRow,
          PrefetchHooks Function()
        > {
  $$ReminderSettingsTableTableManager(
    _$AppDatabase db,
    $ReminderSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailyNextDayEnabled = const Value.absent(),
                Value<String> dailyNextDayTime = const Value.absent(),
                Value<bool> adjustedWorkEnabled = const Value.absent(),
                Value<int> adjustedWorkLeadDays = const Value.absent(),
                Value<bool> weeklyPreviewEnabled = const Value.absent(),
                Value<int> weeklyPreviewWeekday = const Value.absent(),
                Value<String> weeklyPreviewTime = const Value.absent(),
                Value<bool> countdownEnabled = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
              }) => ReminderSettingsCompanion(
                id: id,
                dailyNextDayEnabled: dailyNextDayEnabled,
                dailyNextDayTime: dailyNextDayTime,
                adjustedWorkEnabled: adjustedWorkEnabled,
                adjustedWorkLeadDays: adjustedWorkLeadDays,
                weeklyPreviewEnabled: weeklyPreviewEnabled,
                weeklyPreviewWeekday: weeklyPreviewWeekday,
                weeklyPreviewTime: weeklyPreviewTime,
                countdownEnabled: countdownEnabled,
                timeZoneId: timeZoneId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailyNextDayEnabled = const Value.absent(),
                Value<String> dailyNextDayTime = const Value.absent(),
                Value<bool> adjustedWorkEnabled = const Value.absent(),
                Value<int> adjustedWorkLeadDays = const Value.absent(),
                Value<bool> weeklyPreviewEnabled = const Value.absent(),
                Value<int> weeklyPreviewWeekday = const Value.absent(),
                Value<String> weeklyPreviewTime = const Value.absent(),
                Value<bool> countdownEnabled = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
              }) => ReminderSettingsCompanion.insert(
                id: id,
                dailyNextDayEnabled: dailyNextDayEnabled,
                dailyNextDayTime: dailyNextDayTime,
                adjustedWorkEnabled: adjustedWorkEnabled,
                adjustedWorkLeadDays: adjustedWorkLeadDays,
                weeklyPreviewEnabled: weeklyPreviewEnabled,
                weeklyPreviewWeekday: weeklyPreviewWeekday,
                weeklyPreviewTime: weeklyPreviewTime,
                countdownEnabled: countdownEnabled,
                timeZoneId: timeZoneId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderSettingsTable,
      ReminderSettingsRow,
      $$ReminderSettingsTableFilterComposer,
      $$ReminderSettingsTableOrderingComposer,
      $$ReminderSettingsTableAnnotationComposer,
      $$ReminderSettingsTableCreateCompanionBuilder,
      $$ReminderSettingsTableUpdateCompanionBuilder,
      (
        ReminderSettingsRow,
        BaseReferences<
          _$AppDatabase,
          $ReminderSettingsTable,
          ReminderSettingsRow
        >,
      ),
      ReminderSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<String> visualStyle,
      Value<String> locale,
      Value<bool> firstLaunchCompleted,
      Value<String> desktopWidgetSize,
      Value<String> desktopWidgetLargeDateShape,
      Value<String> desktopWidgetTodayHighlightStyle,
      Value<double> desktopWidgetOpacity,
      Value<bool> desktopWidgetAlwaysOnTop,
      Value<bool> desktopWidgetLocked,
      Value<bool> desktopLaunchAtStartup,
      Value<String> calendarScrollAxis,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<String> visualStyle,
      Value<String> locale,
      Value<bool> firstLaunchCompleted,
      Value<String> desktopWidgetSize,
      Value<String> desktopWidgetLargeDateShape,
      Value<String> desktopWidgetTodayHighlightStyle,
      Value<double> desktopWidgetOpacity,
      Value<bool> desktopWidgetAlwaysOnTop,
      Value<bool> desktopWidgetLocked,
      Value<bool> desktopLaunchAtStartup,
      Value<String> calendarScrollAxis,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualStyle => $composableBuilder(
    column: $table.visualStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get firstLaunchCompleted => $composableBuilder(
    column: $table.firstLaunchCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desktopWidgetSize => $composableBuilder(
    column: $table.desktopWidgetSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desktopWidgetLargeDateShape => $composableBuilder(
    column: $table.desktopWidgetLargeDateShape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desktopWidgetTodayHighlightStyle =>
      $composableBuilder(
        column: $table.desktopWidgetTodayHighlightStyle,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<double> get desktopWidgetOpacity => $composableBuilder(
    column: $table.desktopWidgetOpacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get desktopWidgetAlwaysOnTop => $composableBuilder(
    column: $table.desktopWidgetAlwaysOnTop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get desktopWidgetLocked => $composableBuilder(
    column: $table.desktopWidgetLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get desktopLaunchAtStartup => $composableBuilder(
    column: $table.desktopLaunchAtStartup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarScrollAxis => $composableBuilder(
    column: $table.calendarScrollAxis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualStyle => $composableBuilder(
    column: $table.visualStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get firstLaunchCompleted => $composableBuilder(
    column: $table.firstLaunchCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desktopWidgetSize => $composableBuilder(
    column: $table.desktopWidgetSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desktopWidgetLargeDateShape => $composableBuilder(
    column: $table.desktopWidgetLargeDateShape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desktopWidgetTodayHighlightStyle =>
      $composableBuilder(
        column: $table.desktopWidgetTodayHighlightStyle,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get desktopWidgetOpacity => $composableBuilder(
    column: $table.desktopWidgetOpacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get desktopWidgetAlwaysOnTop => $composableBuilder(
    column: $table.desktopWidgetAlwaysOnTop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get desktopWidgetLocked => $composableBuilder(
    column: $table.desktopWidgetLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get desktopLaunchAtStartup => $composableBuilder(
    column: $table.desktopLaunchAtStartup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarScrollAxis => $composableBuilder(
    column: $table.calendarScrollAxis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get visualStyle => $composableBuilder(
    column: $table.visualStyle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<bool> get firstLaunchCompleted => $composableBuilder(
    column: $table.firstLaunchCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get desktopWidgetSize => $composableBuilder(
    column: $table.desktopWidgetSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get desktopWidgetLargeDateShape => $composableBuilder(
    column: $table.desktopWidgetLargeDateShape,
    builder: (column) => column,
  );

  GeneratedColumn<String> get desktopWidgetTodayHighlightStyle =>
      $composableBuilder(
        column: $table.desktopWidgetTodayHighlightStyle,
        builder: (column) => column,
      );

  GeneratedColumn<double> get desktopWidgetOpacity => $composableBuilder(
    column: $table.desktopWidgetOpacity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get desktopWidgetAlwaysOnTop => $composableBuilder(
    column: $table.desktopWidgetAlwaysOnTop,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get desktopWidgetLocked => $composableBuilder(
    column: $table.desktopWidgetLocked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get desktopLaunchAtStartup => $composableBuilder(
    column: $table.desktopLaunchAtStartup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarScrollAxis => $composableBuilder(
    column: $table.calendarScrollAxis,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> visualStyle = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> firstLaunchCompleted = const Value.absent(),
                Value<String> desktopWidgetSize = const Value.absent(),
                Value<String> desktopWidgetLargeDateShape =
                    const Value.absent(),
                Value<String> desktopWidgetTodayHighlightStyle =
                    const Value.absent(),
                Value<double> desktopWidgetOpacity = const Value.absent(),
                Value<bool> desktopWidgetAlwaysOnTop = const Value.absent(),
                Value<bool> desktopWidgetLocked = const Value.absent(),
                Value<bool> desktopLaunchAtStartup = const Value.absent(),
                Value<String> calendarScrollAxis = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                visualStyle: visualStyle,
                locale: locale,
                firstLaunchCompleted: firstLaunchCompleted,
                desktopWidgetSize: desktopWidgetSize,
                desktopWidgetLargeDateShape: desktopWidgetLargeDateShape,
                desktopWidgetTodayHighlightStyle:
                    desktopWidgetTodayHighlightStyle,
                desktopWidgetOpacity: desktopWidgetOpacity,
                desktopWidgetAlwaysOnTop: desktopWidgetAlwaysOnTop,
                desktopWidgetLocked: desktopWidgetLocked,
                desktopLaunchAtStartup: desktopLaunchAtStartup,
                calendarScrollAxis: calendarScrollAxis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> visualStyle = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> firstLaunchCompleted = const Value.absent(),
                Value<String> desktopWidgetSize = const Value.absent(),
                Value<String> desktopWidgetLargeDateShape =
                    const Value.absent(),
                Value<String> desktopWidgetTodayHighlightStyle =
                    const Value.absent(),
                Value<double> desktopWidgetOpacity = const Value.absent(),
                Value<bool> desktopWidgetAlwaysOnTop = const Value.absent(),
                Value<bool> desktopWidgetLocked = const Value.absent(),
                Value<bool> desktopLaunchAtStartup = const Value.absent(),
                Value<String> calendarScrollAxis = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                visualStyle: visualStyle,
                locale: locale,
                firstLaunchCompleted: firstLaunchCompleted,
                desktopWidgetSize: desktopWidgetSize,
                desktopWidgetLargeDateShape: desktopWidgetLargeDateShape,
                desktopWidgetTodayHighlightStyle:
                    desktopWidgetTodayHighlightStyle,
                desktopWidgetOpacity: desktopWidgetOpacity,
                desktopWidgetAlwaysOnTop: desktopWidgetAlwaysOnTop,
                desktopWidgetLocked: desktopWidgetLocked,
                desktopLaunchAtStartup: desktopLaunchAtStartup,
                calendarScrollAxis: calendarScrollAxis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScheduleProfilesTableTableManager get scheduleProfiles =>
      $$ScheduleProfilesTableTableManager(_db, _db.scheduleProfiles);
  $$DayOverridesTableTableManager get dayOverrides =>
      $$DayOverridesTableTableManager(_db, _db.dayOverrides);
  $$HolidayOverridesTableTableManager get holidayOverrides =>
      $$HolidayOverridesTableTableManager(_db, _db.holidayOverrides);
  $$ReminderSettingsTableTableManager get reminderSettings =>
      $$ReminderSettingsTableTableManager(_db, _db.reminderSettings);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
