// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GardenImpl _$$GardenImplFromJson(Map<String, dynamic> json) => _$GardenImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🌿',
      zip: json['zip'] as String?,
      zone: json['zone'] as String?,
      location: json['location'] as String?,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GardenImplToJson(_$GardenImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'emoji': instance.emoji,
      'zip': instance.zip,
      'zone': instance.zone,
      'location': instance.location,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

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
