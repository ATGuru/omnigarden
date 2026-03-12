import 'package:freezed_annotation/freezed_annotation.dart';

part 'garden.freezed.dart';
part 'garden.g.dart';

@freezed
class Garden with _$Garden {
  const factory Garden({
    required String id,
    required String userId,
    required String name,
    @Default('🌿') String emoji,
    String? zip,
    String? zone,
    String? location,
    String? coverPhotoUrl,
    DateTime? createdAt,
  }) = _Garden;

  factory Garden.fromJson(Map<String, dynamic> json) => _$GardenFromJson(json);
}

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String gardenId,
    String? plantId,
    required DateTime entryDate,
    String? note,
    int? wateringMl,
    String? photoUrl,
    @Default([]) List<String> tags,
    DateTime? createdAt,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}
