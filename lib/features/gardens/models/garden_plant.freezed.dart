// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'garden_plant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GardenPlant _$GardenPlantFromJson(Map<String, dynamic> json) {
  return _GardenPlant.fromJson(json);
}

/// @nodoc
mixin _$GardenPlant {
  String get id => throw _privateConstructorUsedError;
  String get gardenId => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  String get gardenName => throw _privateConstructorUsedError;
  DateTime? get plantedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GardenPlantCopyWith<GardenPlant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GardenPlantCopyWith<$Res> {
  factory $GardenPlantCopyWith(
          GardenPlant value, $Res Function(GardenPlant) then) =
      _$GardenPlantCopyWithImpl<$Res, GardenPlant>;
  @useResult
  $Res call(
      {String id,
      String gardenId,
      String plantId,
      String gardenName,
      DateTime? plantedAt,
      String? notes,
      DateTime? createdAt});
}

/// @nodoc
class _$GardenPlantCopyWithImpl<$Res, $Val extends GardenPlant>
    implements $GardenPlantCopyWith<$Res> {
  _$GardenPlantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gardenId = null,
    Object? plantId = null,
    Object? gardenName = null,
    Object? plantedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gardenId: null == gardenId
          ? _value.gardenId
          : gardenId // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      gardenName: null == gardenName
          ? _value.gardenName
          : gardenName // ignore: cast_nullable_to_non_nullable
              as String,
      plantedAt: freezed == plantedAt
          ? _value.plantedAt
          : plantedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GardenPlantImplCopyWith<$Res>
    implements $GardenPlantCopyWith<$Res> {
  factory _$$GardenPlantImplCopyWith(
          _$GardenPlantImpl value, $Res Function(_$GardenPlantImpl) then) =
      __$$GardenPlantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String gardenId,
      String plantId,
      String gardenName,
      DateTime? plantedAt,
      String? notes,
      DateTime? createdAt});
}

/// @nodoc
class __$$GardenPlantImplCopyWithImpl<$Res>
    extends _$GardenPlantCopyWithImpl<$Res, _$GardenPlantImpl>
    implements _$$GardenPlantImplCopyWith<$Res> {
  __$$GardenPlantImplCopyWithImpl(
      _$GardenPlantImpl _value, $Res Function(_$GardenPlantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gardenId = null,
    Object? plantId = null,
    Object? gardenName = null,
    Object? plantedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$GardenPlantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gardenId: null == gardenId
          ? _value.gardenId
          : gardenId // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      gardenName: null == gardenName
          ? _value.gardenName
          : gardenName // ignore: cast_nullable_to_non_nullable
              as String,
      plantedAt: freezed == plantedAt
          ? _value.plantedAt
          : plantedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GardenPlantImpl implements _GardenPlant {
  const _$GardenPlantImpl(
      {required this.id,
      required this.gardenId,
      required this.plantId,
      required this.gardenName,
      this.plantedAt,
      this.notes,
      this.createdAt});

  factory _$GardenPlantImpl.fromJson(Map<String, dynamic> json) =>
      _$$GardenPlantImplFromJson(json);

  @override
  final String id;
  @override
  final String gardenId;
  @override
  final String plantId;
  @override
  final String gardenName;
  @override
  final DateTime? plantedAt;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'GardenPlant(id: $id, gardenId: $gardenId, plantId: $plantId, gardenName: $gardenName, plantedAt: $plantedAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GardenPlantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gardenId, gardenId) ||
                other.gardenId == gardenId) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.gardenName, gardenName) ||
                other.gardenName == gardenName) &&
            (identical(other.plantedAt, plantedAt) ||
                other.plantedAt == plantedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, gardenId, plantId,
      gardenName, plantedAt, notes, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GardenPlantImplCopyWith<_$GardenPlantImpl> get copyWith =>
      __$$GardenPlantImplCopyWithImpl<_$GardenPlantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GardenPlantImplToJson(
      this,
    );
  }
}

abstract class _GardenPlant implements GardenPlant {
  const factory _GardenPlant(
      {required final String id,
      required final String gardenId,
      required final String plantId,
      required final String gardenName,
      final DateTime? plantedAt,
      final String? notes,
      final DateTime? createdAt}) = _$GardenPlantImpl;

  factory _GardenPlant.fromJson(Map<String, dynamic> json) =
      _$GardenPlantImpl.fromJson;

  @override
  String get id;
  @override
  String get gardenId;
  @override
  String get plantId;
  @override
  String get gardenName;
  @override
  DateTime? get plantedAt;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$GardenPlantImplCopyWith<_$GardenPlantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
