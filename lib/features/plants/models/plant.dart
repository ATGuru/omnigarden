// lib/features/plants/models/plant.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant.freezed.dart';
part 'plant.g.dart';

@freezed
class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String commonName,
    required String latinName,
    required String emoji,
    required String sunRequirement,
    required String waterNeeds,
    required String matureHeight,
    @Default([]) List<String> companions,
    required int daysToMaturity,
    String? imageUrl,
    String? pestsDiseases,
    String? soilRequirements,
    String? wateringTips,
    String? harvestingTips,
    String? propagationTips,
    String? fertilizingTips,
    String? pruningTips,
    String? spacing,
    String? plantingDepth,
    String? frostTolerance,
    String? containerGrowing,
    String? commonMistakes,
    String? funFact,
    @Default([]) List<PlantStage> stages,
    @Default({}) Map<String, PlantCalendar> calendarByZone,
    @Default([]) List<PlantVariety> varieties,
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}

@freezed
class PlantCalendar with _$PlantCalendar {
  const factory PlantCalendar({
    required String indoorStart,
    required String transplant,
    required String harvest,
  }) = _PlantCalendar;

  factory PlantCalendar.fromJson(Map<String, dynamic> json) =>
      _$PlantCalendarFromJson(json);
}

@freezed
class PlantStage with _$PlantStage {
  const factory PlantStage({
    required String name,
    required String emoji,
    required String weekRange,
    required String description,
    String? imageUrl,
  }) = _PlantStage;

  factory PlantStage.fromJson(Map<String, dynamic> json) =>
      _$PlantStageFromJson(json);
}

@freezed
class PlantVariety with _$PlantVariety {
  const factory PlantVariety({
    required String id,
    required String name,
    String? description,
    String? daysToMaturity,
  }) = _PlantVariety;

  factory PlantVariety.fromJson(Map<String, dynamic> json) =>
      _$PlantVarietyFromJson(json);
}
