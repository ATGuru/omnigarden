// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JournalEntryImpl _$$JournalEntryImplFromJson(Map<String, dynamic> json) =>
    _$JournalEntryImpl(
      id: json['id'] as String,
      gardenId: json['gardenId'] as String,
      plantId: json['plantId'] as String?,
      entryDate: DateTime.parse(json['entryDate'] as String),
      note: json['note'] as String?,
      wateringMl: (json['wateringMl'] as num?)?.toInt(),
      photoUrl: json['photoUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$JournalEntryImplToJson(_$JournalEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gardenId': instance.gardenId,
      'plantId': instance.plantId,
      'entryDate': instance.entryDate.toIso8601String(),
      'note': instance.note,
      'wateringMl': instance.wateringMl,
      'photoUrl': instance.photoUrl,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
