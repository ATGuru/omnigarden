// lib/features/gardens/models/journal_entry.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

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

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}
