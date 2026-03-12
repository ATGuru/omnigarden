// lib/features/gardens/models/garden_plant.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'garden_plant.freezed.dart';
part 'garden_plant.g.dart';

@freezed
class GardenPlant with _$GardenPlant {
  const factory GardenPlant({
    required String id,
    required String gardenId,
    required String plantId,
    required String gardenName,
    DateTime? plantedAt,
    String? notes,
    DateTime? createdAt,
  }) = _GardenPlant;

  factory GardenPlant.fromJson(Map<String, dynamic> json) => _$GardenPlantFromJson(json);
}
