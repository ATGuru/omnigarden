// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Plant _$PlantFromJson(Map<String, dynamic> json) {
  return _Plant.fromJson(json);
}

/// @nodoc
mixin _$Plant {
  String get id => throw _privateConstructorUsedError;
  String get commonName => throw _privateConstructorUsedError;
  String get latinName => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get sunRequirement => throw _privateConstructorUsedError;
  String get waterNeeds => throw _privateConstructorUsedError;
  String get matureHeight => throw _privateConstructorUsedError;
  List<String> get companions => throw _privateConstructorUsedError;
  int get daysToMaturity => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get pestsDiseases => throw _privateConstructorUsedError;
  String? get soilRequirements => throw _privateConstructorUsedError;
  String? get wateringTips => throw _privateConstructorUsedError;
  String? get harvestingTips => throw _privateConstructorUsedError;
  List<PlantStage> get stages => throw _privateConstructorUsedError;
  Map<String, PlantCalendar> get calendarByZone =>
      throw _privateConstructorUsedError;
  List<PlantVariety> get varieties => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlantCopyWith<Plant> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCopyWith<$Res> {
  factory $PlantCopyWith(Plant value, $Res Function(Plant) then) =
      _$PlantCopyWithImpl<$Res, Plant>;
  @useResult
  $Res call(
      {String id,
      String commonName,
      String latinName,
      String emoji,
      String sunRequirement,
      String waterNeeds,
      String matureHeight,
      List<String> companions,
      int daysToMaturity,
      String? imageUrl,
      String? pestsDiseases,
      String? soilRequirements,
      String? wateringTips,
      String? harvestingTips,
      List<PlantStage> stages,
      Map<String, PlantCalendar> calendarByZone,
      List<PlantVariety> varieties});
}

/// @nodoc
class _$PlantCopyWithImpl<$Res, $Val extends Plant>
    implements $PlantCopyWith<$Res> {
  _$PlantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? commonName = null,
    Object? latinName = null,
    Object? emoji = null,
    Object? sunRequirement = null,
    Object? waterNeeds = null,
    Object? matureHeight = null,
    Object? companions = null,
    Object? daysToMaturity = null,
    Object? imageUrl = freezed,
    Object? pestsDiseases = freezed,
    Object? soilRequirements = freezed,
    Object? wateringTips = freezed,
    Object? harvestingTips = freezed,
    Object? stages = null,
    Object? calendarByZone = null,
    Object? varieties = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      latinName: null == latinName
          ? _value.latinName
          : latinName // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      sunRequirement: null == sunRequirement
          ? _value.sunRequirement
          : sunRequirement // ignore: cast_nullable_to_non_nullable
              as String,
      waterNeeds: null == waterNeeds
          ? _value.waterNeeds
          : waterNeeds // ignore: cast_nullable_to_non_nullable
              as String,
      matureHeight: null == matureHeight
          ? _value.matureHeight
          : matureHeight // ignore: cast_nullable_to_non_nullable
              as String,
      companions: null == companions
          ? _value.companions
          : companions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      daysToMaturity: null == daysToMaturity
          ? _value.daysToMaturity
          : daysToMaturity // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pestsDiseases: freezed == pestsDiseases
          ? _value.pestsDiseases
          : pestsDiseases // ignore: cast_nullable_to_non_nullable
              as String?,
      soilRequirements: freezed == soilRequirements
          ? _value.soilRequirements
          : soilRequirements // ignore: cast_nullable_to_non_nullable
              as String?,
      wateringTips: freezed == wateringTips
          ? _value.wateringTips
          : wateringTips // ignore: cast_nullable_to_non_nullable
              as String?,
      harvestingTips: freezed == harvestingTips
          ? _value.harvestingTips
          : harvestingTips // ignore: cast_nullable_to_non_nullable
              as String?,
      stages: null == stages
          ? _value.stages
          : stages // ignore: cast_nullable_to_non_nullable
              as List<PlantStage>,
      calendarByZone: null == calendarByZone
          ? _value.calendarByZone
          : calendarByZone // ignore: cast_nullable_to_non_nullable
              as Map<String, PlantCalendar>,
      varieties: null == varieties
          ? _value.varieties
          : varieties // ignore: cast_nullable_to_non_nullable
              as List<PlantVariety>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantImplCopyWith<$Res> implements $PlantCopyWith<$Res> {
  factory _$$PlantImplCopyWith(
          _$PlantImpl value, $Res Function(_$PlantImpl) then) =
      __$$PlantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String commonName,
      String latinName,
      String emoji,
      String sunRequirement,
      String waterNeeds,
      String matureHeight,
      List<String> companions,
      int daysToMaturity,
      String? imageUrl,
      String? pestsDiseases,
      String? soilRequirements,
      String? wateringTips,
      String? harvestingTips,
      List<PlantStage> stages,
      Map<String, PlantCalendar> calendarByZone,
      List<PlantVariety> varieties});
}

/// @nodoc
class __$$PlantImplCopyWithImpl<$Res>
    extends _$PlantCopyWithImpl<$Res, _$PlantImpl>
    implements _$$PlantImplCopyWith<$Res> {
  __$$PlantImplCopyWithImpl(
      _$PlantImpl _value, $Res Function(_$PlantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? commonName = null,
    Object? latinName = null,
    Object? emoji = null,
    Object? sunRequirement = null,
    Object? waterNeeds = null,
    Object? matureHeight = null,
    Object? companions = null,
    Object? daysToMaturity = null,
    Object? imageUrl = freezed,
    Object? pestsDiseases = freezed,
    Object? soilRequirements = freezed,
    Object? wateringTips = freezed,
    Object? harvestingTips = freezed,
    Object? stages = null,
    Object? calendarByZone = null,
    Object? varieties = null,
  }) {
    return _then(_$PlantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      latinName: null == latinName
          ? _value.latinName
          : latinName // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      sunRequirement: null == sunRequirement
          ? _value.sunRequirement
          : sunRequirement // ignore: cast_nullable_to_non_nullable
              as String,
      waterNeeds: null == waterNeeds
          ? _value.waterNeeds
          : waterNeeds // ignore: cast_nullable_to_non_nullable
              as String,
      matureHeight: null == matureHeight
          ? _value.matureHeight
          : matureHeight // ignore: cast_nullable_to_non_nullable
              as String,
      companions: null == companions
          ? _value._companions
          : companions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      daysToMaturity: null == daysToMaturity
          ? _value.daysToMaturity
          : daysToMaturity // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pestsDiseases: freezed == pestsDiseases
          ? _value.pestsDiseases
          : pestsDiseases // ignore: cast_nullable_to_non_nullable
              as String?,
      soilRequirements: freezed == soilRequirements
          ? _value.soilRequirements
          : soilRequirements // ignore: cast_nullable_to_non_nullable
              as String?,
      wateringTips: freezed == wateringTips
          ? _value.wateringTips
          : wateringTips // ignore: cast_nullable_to_non_nullable
              as String?,
      harvestingTips: freezed == harvestingTips
          ? _value.harvestingTips
          : harvestingTips // ignore: cast_nullable_to_non_nullable
              as String?,
      stages: null == stages
          ? _value._stages
          : stages // ignore: cast_nullable_to_non_nullable
              as List<PlantStage>,
      calendarByZone: null == calendarByZone
          ? _value._calendarByZone
          : calendarByZone // ignore: cast_nullable_to_non_nullable
              as Map<String, PlantCalendar>,
      varieties: null == varieties
          ? _value._varieties
          : varieties // ignore: cast_nullable_to_non_nullable
              as List<PlantVariety>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantImpl implements _Plant {
  const _$PlantImpl(
      {required this.id,
      required this.commonName,
      required this.latinName,
      required this.emoji,
      required this.sunRequirement,
      required this.waterNeeds,
      required this.matureHeight,
      final List<String> companions = const [],
      required this.daysToMaturity,
      this.imageUrl,
      this.pestsDiseases,
      this.soilRequirements,
      this.wateringTips,
      this.harvestingTips,
      final List<PlantStage> stages = const [],
      final Map<String, PlantCalendar> calendarByZone = const {},
      final List<PlantVariety> varieties = const []})
      : _companions = companions,
        _stages = stages,
        _calendarByZone = calendarByZone,
        _varieties = varieties;

  factory _$PlantImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantImplFromJson(json);

  @override
  final String id;
  @override
  final String commonName;
  @override
  final String latinName;
  @override
  final String emoji;
  @override
  final String sunRequirement;
  @override
  final String waterNeeds;
  @override
  final String matureHeight;
  final List<String> _companions;
  @override
  @JsonKey()
  List<String> get companions {
    if (_companions is EqualUnmodifiableListView) return _companions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_companions);
  }

  @override
  final int daysToMaturity;
  @override
  final String? imageUrl;
  @override
  final String? pestsDiseases;
  @override
  final String? soilRequirements;
  @override
  final String? wateringTips;
  @override
  final String? harvestingTips;
  final List<PlantStage> _stages;
  @override
  @JsonKey()
  List<PlantStage> get stages {
    if (_stages is EqualUnmodifiableListView) return _stages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stages);
  }

  final Map<String, PlantCalendar> _calendarByZone;
  @override
  @JsonKey()
  Map<String, PlantCalendar> get calendarByZone {
    if (_calendarByZone is EqualUnmodifiableMapView) return _calendarByZone;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_calendarByZone);
  }

  final List<PlantVariety> _varieties;
  @override
  @JsonKey()
  List<PlantVariety> get varieties {
    if (_varieties is EqualUnmodifiableListView) return _varieties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_varieties);
  }

  @override
  String toString() {
    return 'Plant(id: $id, commonName: $commonName, latinName: $latinName, emoji: $emoji, sunRequirement: $sunRequirement, waterNeeds: $waterNeeds, matureHeight: $matureHeight, companions: $companions, daysToMaturity: $daysToMaturity, imageUrl: $imageUrl, pestsDiseases: $pestsDiseases, soilRequirements: $soilRequirements, wateringTips: $wateringTips, harvestingTips: $harvestingTips, stages: $stages, calendarByZone: $calendarByZone, varieties: $varieties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.latinName, latinName) ||
                other.latinName == latinName) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.sunRequirement, sunRequirement) ||
                other.sunRequirement == sunRequirement) &&
            (identical(other.waterNeeds, waterNeeds) ||
                other.waterNeeds == waterNeeds) &&
            (identical(other.matureHeight, matureHeight) ||
                other.matureHeight == matureHeight) &&
            const DeepCollectionEquality()
                .equals(other._companions, _companions) &&
            (identical(other.daysToMaturity, daysToMaturity) ||
                other.daysToMaturity == daysToMaturity) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.pestsDiseases, pestsDiseases) ||
                other.pestsDiseases == pestsDiseases) &&
            (identical(other.soilRequirements, soilRequirements) ||
                other.soilRequirements == soilRequirements) &&
            (identical(other.wateringTips, wateringTips) ||
                other.wateringTips == wateringTips) &&
            (identical(other.harvestingTips, harvestingTips) ||
                other.harvestingTips == harvestingTips) &&
            const DeepCollectionEquality().equals(other._stages, _stages) &&
            const DeepCollectionEquality()
                .equals(other._calendarByZone, _calendarByZone) &&
            const DeepCollectionEquality()
                .equals(other._varieties, _varieties));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      commonName,
      latinName,
      emoji,
      sunRequirement,
      waterNeeds,
      matureHeight,
      const DeepCollectionEquality().hash(_companions),
      daysToMaturity,
      imageUrl,
      pestsDiseases,
      soilRequirements,
      wateringTips,
      harvestingTips,
      const DeepCollectionEquality().hash(_stages),
      const DeepCollectionEquality().hash(_calendarByZone),
      const DeepCollectionEquality().hash(_varieties));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantImplCopyWith<_$PlantImpl> get copyWith =>
      __$$PlantImplCopyWithImpl<_$PlantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantImplToJson(
      this,
    );
  }
}

abstract class _Plant implements Plant {
  const factory _Plant(
      {required final String id,
      required final String commonName,
      required final String latinName,
      required final String emoji,
      required final String sunRequirement,
      required final String waterNeeds,
      required final String matureHeight,
      final List<String> companions,
      required final int daysToMaturity,
      final String? imageUrl,
      final String? pestsDiseases,
      final String? soilRequirements,
      final String? wateringTips,
      final String? harvestingTips,
      final List<PlantStage> stages,
      final Map<String, PlantCalendar> calendarByZone,
      final List<PlantVariety> varieties}) = _$PlantImpl;

  factory _Plant.fromJson(Map<String, dynamic> json) = _$PlantImpl.fromJson;

  @override
  String get id;
  @override
  String get commonName;
  @override
  String get latinName;
  @override
  String get emoji;
  @override
  String get sunRequirement;
  @override
  String get waterNeeds;
  @override
  String get matureHeight;
  @override
  List<String> get companions;
  @override
  int get daysToMaturity;
  @override
  String? get imageUrl;
  @override
  String? get pestsDiseases;
  @override
  String? get soilRequirements;
  @override
  String? get wateringTips;
  @override
  String? get harvestingTips;
  @override
  List<PlantStage> get stages;
  @override
  Map<String, PlantCalendar> get calendarByZone;
  @override
  List<PlantVariety> get varieties;
  @override
  @JsonKey(ignore: true)
  _$$PlantImplCopyWith<_$PlantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantCalendar _$PlantCalendarFromJson(Map<String, dynamic> json) {
  return _PlantCalendar.fromJson(json);
}

/// @nodoc
mixin _$PlantCalendar {
  String get indoorStart => throw _privateConstructorUsedError;
  String get transplant => throw _privateConstructorUsedError;
  String get harvest => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlantCalendarCopyWith<PlantCalendar> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCalendarCopyWith<$Res> {
  factory $PlantCalendarCopyWith(
          PlantCalendar value, $Res Function(PlantCalendar) then) =
      _$PlantCalendarCopyWithImpl<$Res, PlantCalendar>;
  @useResult
  $Res call({String indoorStart, String transplant, String harvest});
}

/// @nodoc
class _$PlantCalendarCopyWithImpl<$Res, $Val extends PlantCalendar>
    implements $PlantCalendarCopyWith<$Res> {
  _$PlantCalendarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? indoorStart = null,
    Object? transplant = null,
    Object? harvest = null,
  }) {
    return _then(_value.copyWith(
      indoorStart: null == indoorStart
          ? _value.indoorStart
          : indoorStart // ignore: cast_nullable_to_non_nullable
              as String,
      transplant: null == transplant
          ? _value.transplant
          : transplant // ignore: cast_nullable_to_non_nullable
              as String,
      harvest: null == harvest
          ? _value.harvest
          : harvest // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantCalendarImplCopyWith<$Res>
    implements $PlantCalendarCopyWith<$Res> {
  factory _$$PlantCalendarImplCopyWith(
          _$PlantCalendarImpl value, $Res Function(_$PlantCalendarImpl) then) =
      __$$PlantCalendarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String indoorStart, String transplant, String harvest});
}

/// @nodoc
class __$$PlantCalendarImplCopyWithImpl<$Res>
    extends _$PlantCalendarCopyWithImpl<$Res, _$PlantCalendarImpl>
    implements _$$PlantCalendarImplCopyWith<$Res> {
  __$$PlantCalendarImplCopyWithImpl(
      _$PlantCalendarImpl _value, $Res Function(_$PlantCalendarImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? indoorStart = null,
    Object? transplant = null,
    Object? harvest = null,
  }) {
    return _then(_$PlantCalendarImpl(
      indoorStart: null == indoorStart
          ? _value.indoorStart
          : indoorStart // ignore: cast_nullable_to_non_nullable
              as String,
      transplant: null == transplant
          ? _value.transplant
          : transplant // ignore: cast_nullable_to_non_nullable
              as String,
      harvest: null == harvest
          ? _value.harvest
          : harvest // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantCalendarImpl implements _PlantCalendar {
  const _$PlantCalendarImpl(
      {required this.indoorStart,
      required this.transplant,
      required this.harvest});

  factory _$PlantCalendarImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantCalendarImplFromJson(json);

  @override
  final String indoorStart;
  @override
  final String transplant;
  @override
  final String harvest;

  @override
  String toString() {
    return 'PlantCalendar(indoorStart: $indoorStart, transplant: $transplant, harvest: $harvest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantCalendarImpl &&
            (identical(other.indoorStart, indoorStart) ||
                other.indoorStart == indoorStart) &&
            (identical(other.transplant, transplant) ||
                other.transplant == transplant) &&
            (identical(other.harvest, harvest) || other.harvest == harvest));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, indoorStart, transplant, harvest);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantCalendarImplCopyWith<_$PlantCalendarImpl> get copyWith =>
      __$$PlantCalendarImplCopyWithImpl<_$PlantCalendarImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantCalendarImplToJson(
      this,
    );
  }
}

abstract class _PlantCalendar implements PlantCalendar {
  const factory _PlantCalendar(
      {required final String indoorStart,
      required final String transplant,
      required final String harvest}) = _$PlantCalendarImpl;

  factory _PlantCalendar.fromJson(Map<String, dynamic> json) =
      _$PlantCalendarImpl.fromJson;

  @override
  String get indoorStart;
  @override
  String get transplant;
  @override
  String get harvest;
  @override
  @JsonKey(ignore: true)
  _$$PlantCalendarImplCopyWith<_$PlantCalendarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantStage _$PlantStageFromJson(Map<String, dynamic> json) {
  return _PlantStage.fromJson(json);
}

/// @nodoc
mixin _$PlantStage {
  String get name => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get weekRange => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlantStageCopyWith<PlantStage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantStageCopyWith<$Res> {
  factory $PlantStageCopyWith(
          PlantStage value, $Res Function(PlantStage) then) =
      _$PlantStageCopyWithImpl<$Res, PlantStage>;
  @useResult
  $Res call(
      {String name,
      String emoji,
      String weekRange,
      String description,
      String? imageUrl});
}

/// @nodoc
class _$PlantStageCopyWithImpl<$Res, $Val extends PlantStage>
    implements $PlantStageCopyWith<$Res> {
  _$PlantStageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? emoji = null,
    Object? weekRange = null,
    Object? description = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      weekRange: null == weekRange
          ? _value.weekRange
          : weekRange // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantStageImplCopyWith<$Res>
    implements $PlantStageCopyWith<$Res> {
  factory _$$PlantStageImplCopyWith(
          _$PlantStageImpl value, $Res Function(_$PlantStageImpl) then) =
      __$$PlantStageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String emoji,
      String weekRange,
      String description,
      String? imageUrl});
}

/// @nodoc
class __$$PlantStageImplCopyWithImpl<$Res>
    extends _$PlantStageCopyWithImpl<$Res, _$PlantStageImpl>
    implements _$$PlantStageImplCopyWith<$Res> {
  __$$PlantStageImplCopyWithImpl(
      _$PlantStageImpl _value, $Res Function(_$PlantStageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? emoji = null,
    Object? weekRange = null,
    Object? description = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$PlantStageImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      weekRange: null == weekRange
          ? _value.weekRange
          : weekRange // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantStageImpl implements _PlantStage {
  const _$PlantStageImpl(
      {required this.name,
      required this.emoji,
      required this.weekRange,
      required this.description,
      this.imageUrl});

  factory _$PlantStageImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantStageImplFromJson(json);

  @override
  final String name;
  @override
  final String emoji;
  @override
  final String weekRange;
  @override
  final String description;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'PlantStage(name: $name, emoji: $emoji, weekRange: $weekRange, description: $description, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantStageImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.weekRange, weekRange) ||
                other.weekRange == weekRange) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, emoji, weekRange, description, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantStageImplCopyWith<_$PlantStageImpl> get copyWith =>
      __$$PlantStageImplCopyWithImpl<_$PlantStageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantStageImplToJson(
      this,
    );
  }
}

abstract class _PlantStage implements PlantStage {
  const factory _PlantStage(
      {required final String name,
      required final String emoji,
      required final String weekRange,
      required final String description,
      final String? imageUrl}) = _$PlantStageImpl;

  factory _PlantStage.fromJson(Map<String, dynamic> json) =
      _$PlantStageImpl.fromJson;

  @override
  String get name;
  @override
  String get emoji;
  @override
  String get weekRange;
  @override
  String get description;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$PlantStageImplCopyWith<_$PlantStageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantVariety _$PlantVarietyFromJson(Map<String, dynamic> json) {
  return _PlantVariety.fromJson(json);
}

/// @nodoc
mixin _$PlantVariety {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get daysToMaturity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlantVarietyCopyWith<PlantVariety> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantVarietyCopyWith<$Res> {
  factory $PlantVarietyCopyWith(
          PlantVariety value, $Res Function(PlantVariety) then) =
      _$PlantVarietyCopyWithImpl<$Res, PlantVariety>;
  @useResult
  $Res call(
      {String id, String name, String? description, String? daysToMaturity});
}

/// @nodoc
class _$PlantVarietyCopyWithImpl<$Res, $Val extends PlantVariety>
    implements $PlantVarietyCopyWith<$Res> {
  _$PlantVarietyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? daysToMaturity = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      daysToMaturity: freezed == daysToMaturity
          ? _value.daysToMaturity
          : daysToMaturity // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantVarietyImplCopyWith<$Res>
    implements $PlantVarietyCopyWith<$Res> {
  factory _$$PlantVarietyImplCopyWith(
          _$PlantVarietyImpl value, $Res Function(_$PlantVarietyImpl) then) =
      __$$PlantVarietyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, String? description, String? daysToMaturity});
}

/// @nodoc
class __$$PlantVarietyImplCopyWithImpl<$Res>
    extends _$PlantVarietyCopyWithImpl<$Res, _$PlantVarietyImpl>
    implements _$$PlantVarietyImplCopyWith<$Res> {
  __$$PlantVarietyImplCopyWithImpl(
      _$PlantVarietyImpl _value, $Res Function(_$PlantVarietyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? daysToMaturity = freezed,
  }) {
    return _then(_$PlantVarietyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      daysToMaturity: freezed == daysToMaturity
          ? _value.daysToMaturity
          : daysToMaturity // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantVarietyImpl implements _PlantVariety {
  const _$PlantVarietyImpl(
      {required this.id,
      required this.name,
      this.description,
      this.daysToMaturity});

  factory _$PlantVarietyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantVarietyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? daysToMaturity;

  @override
  String toString() {
    return 'PlantVariety(id: $id, name: $name, description: $description, daysToMaturity: $daysToMaturity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantVarietyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.daysToMaturity, daysToMaturity) ||
                other.daysToMaturity == daysToMaturity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, daysToMaturity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantVarietyImplCopyWith<_$PlantVarietyImpl> get copyWith =>
      __$$PlantVarietyImplCopyWithImpl<_$PlantVarietyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantVarietyImplToJson(
      this,
    );
  }
}

abstract class _PlantVariety implements PlantVariety {
  const factory _PlantVariety(
      {required final String id,
      required final String name,
      final String? description,
      final String? daysToMaturity}) = _$PlantVarietyImpl;

  factory _PlantVariety.fromJson(Map<String, dynamic> json) =
      _$PlantVarietyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get daysToMaturity;
  @override
  @JsonKey(ignore: true)
  _$$PlantVarietyImplCopyWith<_$PlantVarietyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
