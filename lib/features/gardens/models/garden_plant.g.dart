// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GardenPlantImpl _$$GardenPlantImplFromJson(Map<String, dynamic> json) =>
    _$GardenPlantImpl(
      id: json['id'] as String,
      gardenId: json['gardenId'] as String,
      plantId: json['plantId'] as String,
      gardenName: json['gardenName'] as String,
      plantedAt: json['plantedAt'] == null
          ? null
          : DateTime.parse(json['plantedAt'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GardenPlantImplToJson(_$GardenPlantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gardenId': instance.gardenId,
      'plantId': instance.plantId,
      'gardenName': instance.gardenName,
      'plantedAt': instance.plantedAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
