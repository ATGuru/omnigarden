// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlantImpl _$$PlantImplFromJson(Map<String, dynamic> json) => _$PlantImpl(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      latinName: json['latinName'] as String,
      emoji: json['emoji'] as String,
      sunRequirement: json['sunRequirement'] as String,
      waterNeeds: json['waterNeeds'] as String,
      matureHeight: json['matureHeight'] as String,
      companions: (json['companions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      daysToMaturity: (json['daysToMaturity'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      pestsDiseases: json['pestsDiseases'] as String?,
      soilRequirements: json['soilRequirements'] as String?,
      wateringTips: json['wateringTips'] as String?,
      harvestingTips: json['harvestingTips'] as String?,
      propagationTips: json['propagationTips'] as String?,
      fertilizingTips: json['fertilizingTips'] as String?,
      pruningTips: json['pruningTips'] as String?,
      spacing: json['spacing'] as String?,
      plantingDepth: json['plantingDepth'] as String?,
      frostTolerance: json['frostTolerance'] as String?,
      containerGrowing: json['containerGrowing'] as String?,
      commonMistakes: json['commonMistakes'] as String?,
      funFact: json['funFact'] as String?,
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => PlantStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      calendarByZone: (json['calendarByZone'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, PlantCalendar.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      varieties: (json['varieties'] as List<dynamic>?)
              ?.map((e) => PlantVariety.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PlantImplToJson(_$PlantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'commonName': instance.commonName,
      'latinName': instance.latinName,
      'emoji': instance.emoji,
      'sunRequirement': instance.sunRequirement,
      'waterNeeds': instance.waterNeeds,
      'matureHeight': instance.matureHeight,
      'companions': instance.companions,
      'daysToMaturity': instance.daysToMaturity,
      'imageUrl': instance.imageUrl,
      'pestsDiseases': instance.pestsDiseases,
      'soilRequirements': instance.soilRequirements,
      'wateringTips': instance.wateringTips,
      'harvestingTips': instance.harvestingTips,
      'propagationTips': instance.propagationTips,
      'fertilizingTips': instance.fertilizingTips,
      'pruningTips': instance.pruningTips,
      'spacing': instance.spacing,
      'plantingDepth': instance.plantingDepth,
      'frostTolerance': instance.frostTolerance,
      'containerGrowing': instance.containerGrowing,
      'commonMistakes': instance.commonMistakes,
      'funFact': instance.funFact,
      'stages': instance.stages,
      'calendarByZone': instance.calendarByZone,
      'varieties': instance.varieties,
    };

_$PlantCalendarImpl _$$PlantCalendarImplFromJson(Map<String, dynamic> json) =>
    _$PlantCalendarImpl(
      indoorStart: json['indoorStart'] as String,
      transplant: json['transplant'] as String,
      harvest: json['harvest'] as String,
    );

Map<String, dynamic> _$$PlantCalendarImplToJson(_$PlantCalendarImpl instance) =>
    <String, dynamic>{
      'indoorStart': instance.indoorStart,
      'transplant': instance.transplant,
      'harvest': instance.harvest,
    };

_$PlantStageImpl _$$PlantStageImplFromJson(Map<String, dynamic> json) =>
    _$PlantStageImpl(
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      weekRange: json['weekRange'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$PlantStageImplToJson(_$PlantStageImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'emoji': instance.emoji,
      'weekRange': instance.weekRange,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
    };

_$PlantVarietyImpl _$$PlantVarietyImplFromJson(Map<String, dynamic> json) =>
    _$PlantVarietyImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      daysToMaturity: json['daysToMaturity'] as String?,
    );

Map<String, dynamic> _$$PlantVarietyImplToJson(_$PlantVarietyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'daysToMaturity': instance.daysToMaturity,
    };
