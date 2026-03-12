// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) {
  return _JournalEntry.fromJson(json);
}

/// @nodoc
mixin _$JournalEntry {
  String get id => throw _privateConstructorUsedError;
  String get gardenId => throw _privateConstructorUsedError;
  String? get plantId => throw _privateConstructorUsedError;
  DateTime get entryDate => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int? get wateringMl => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JournalEntryCopyWith<JournalEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryCopyWith<$Res> {
  factory $JournalEntryCopyWith(
          JournalEntry value, $Res Function(JournalEntry) then) =
      _$JournalEntryCopyWithImpl<$Res, JournalEntry>;
  @useResult
  $Res call(
      {String id,
      String gardenId,
      String? plantId,
      DateTime entryDate,
      String? note,
      int? wateringMl,
      String? photoUrl,
      List<String> tags,
      DateTime? createdAt});
}

/// @nodoc
class _$JournalEntryCopyWithImpl<$Res, $Val extends JournalEntry>
    implements $JournalEntryCopyWith<$Res> {
  _$JournalEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gardenId = null,
    Object? plantId = freezed,
    Object? entryDate = null,
    Object? note = freezed,
    Object? wateringMl = freezed,
    Object? photoUrl = freezed,
    Object? tags = null,
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
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      entryDate: null == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      wateringMl: freezed == wateringMl
          ? _value.wateringMl
          : wateringMl // ignore: cast_nullable_to_non_nullable
              as int?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JournalEntryImplCopyWith<$Res>
    implements $JournalEntryCopyWith<$Res> {
  factory _$$JournalEntryImplCopyWith(
          _$JournalEntryImpl value, $Res Function(_$JournalEntryImpl) then) =
      __$$JournalEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String gardenId,
      String? plantId,
      DateTime entryDate,
      String? note,
      int? wateringMl,
      String? photoUrl,
      List<String> tags,
      DateTime? createdAt});
}

/// @nodoc
class __$$JournalEntryImplCopyWithImpl<$Res>
    extends _$JournalEntryCopyWithImpl<$Res, _$JournalEntryImpl>
    implements _$$JournalEntryImplCopyWith<$Res> {
  __$$JournalEntryImplCopyWithImpl(
      _$JournalEntryImpl _value, $Res Function(_$JournalEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gardenId = null,
    Object? plantId = freezed,
    Object? entryDate = null,
    Object? note = freezed,
    Object? wateringMl = freezed,
    Object? photoUrl = freezed,
    Object? tags = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$JournalEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gardenId: null == gardenId
          ? _value.gardenId
          : gardenId // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      entryDate: null == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      wateringMl: freezed == wateringMl
          ? _value.wateringMl
          : wateringMl // ignore: cast_nullable_to_non_nullable
              as int?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalEntryImpl implements _JournalEntry {
  const _$JournalEntryImpl(
      {required this.id,
      required this.gardenId,
      this.plantId,
      required this.entryDate,
      this.note,
      this.wateringMl,
      this.photoUrl,
      final List<String> tags = const [],
      this.createdAt})
      : _tags = tags;

  factory _$JournalEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String gardenId;
  @override
  final String? plantId;
  @override
  final DateTime entryDate;
  @override
  final String? note;
  @override
  final int? wateringMl;
  @override
  final String? photoUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'JournalEntry(id: $id, gardenId: $gardenId, plantId: $plantId, entryDate: $entryDate, note: $note, wateringMl: $wateringMl, photoUrl: $photoUrl, tags: $tags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gardenId, gardenId) ||
                other.gardenId == gardenId) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.wateringMl, wateringMl) ||
                other.wateringMl == wateringMl) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      gardenId,
      plantId,
      entryDate,
      note,
      wateringMl,
      photoUrl,
      const DeepCollectionEquality().hash(_tags),
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      __$$JournalEntryImplCopyWithImpl<_$JournalEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryImplToJson(
      this,
    );
  }
}

abstract class _JournalEntry implements JournalEntry {
  const factory _JournalEntry(
      {required final String id,
      required final String gardenId,
      final String? plantId,
      required final DateTime entryDate,
      final String? note,
      final int? wateringMl,
      final String? photoUrl,
      final List<String> tags,
      final DateTime? createdAt}) = _$JournalEntryImpl;

  factory _JournalEntry.fromJson(Map<String, dynamic> json) =
      _$JournalEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get gardenId;
  @override
  String? get plantId;
  @override
  DateTime get entryDate;
  @override
  String? get note;
  @override
  int? get wateringMl;
  @override
  String? get photoUrl;
  @override
  List<String> get tags;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
