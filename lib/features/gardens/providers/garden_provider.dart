import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden.dart';
import '../../../shared/utils/garden_scheduler.dart';

part 'garden_provider.g.dart';

final _client = Supabase.instance.client;

// ── Gardens ───────────────────────────────────────────────

@riverpod
Future<List<Garden>> gardens(GardensRef ref) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return [];

  final res = await _client
      .from('gardens')
      .select('id, user_id, name, emoji, zip, zone, location, cover_photo_url, created_at')
      .eq('user_id', userId)
      .order('created_at');

  return (res as List).map((g) => Garden(
    id: g['id'],
    userId: g['user_id'],
    name: g['name'],
    emoji: g['emoji'] ?? '🌿',
    createdAt: DateTime.tryParse(g['created_at'] ?? ''),
  )).toList();
}

@riverpod
class GardenNotifier extends _$GardenNotifier {
  @override
  Future<List<Garden>> build() => ref.watch(gardensProvider.future);

  Future<void> createGarden({
    required String name,
    required String emoji,
    String? zip,
    String? zone,
    String? location,
    String? coverPhotoUrl,
  }) async {
    // Check if user is authenticated
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please sign in to create a garden.');
    }
    
    final userId = currentUser.id;

    await _client.from('gardens').insert({
      'user_id': userId, // Ensure this matches currentUser.id exactly
      'name': name,
      'emoji': emoji,
      'zip': zip,
      'zone': zone,
      'location': location,
      'cover_photo_url': coverPhotoUrl,
    });

    // Schedule planting reminders for all gardens
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final zone = prefs.getString('user_zone') ?? 'Zone 6a';
      ref.read(gardenSchedulerProvider).scheduleAll(user.id, zone);
    }

    ref.invalidateSelf();
  }

  Future<void> updateGarden({
    required String gardenId,
    required String name,
  }) async {
    // Check if user is authenticated
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please sign in to update garden.');
    }
    
    await _client.from('gardens').update({
      'id': gardenId,
      'name': name,
    }).eq('user_id', currentUser.id);

    ref.invalidateSelf();
  }

  Future<void> deleteGarden(String id) async {
    await _client.from('gardens').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

// ── Journal Entries ───────────────────────────────────────

@riverpod
Future<List<JournalEntry>> journalEntries(
  JournalEntriesRef ref,
  String gardenId,
) async {
  final res = await _client
      .from('journal_entries')
      .select()
      .eq('garden_id', gardenId)
      .order('entry_date', ascending: false);

  return (res as List).map((e) => JournalEntry(
    id: e['id'],
    gardenId: e['garden_id'],
    plantId: e['plant_id'],
    entryDate: DateTime.parse(e['entry_date']),
    note: e['note'],
    wateringMl: e['watering_ml'],
    photoUrl: e['photo_url'],
    tags: List<String>.from(e['tags'] ?? []),
    createdAt: DateTime.tryParse(e['created_at'] ?? ''),
  )).toList();
}

@riverpod
class JournalNotifier extends _$JournalNotifier {
  @override
  Future<List<JournalEntry>> build(String gardenId) =>
      ref.watch(journalEntriesProvider(gardenId).future);

  Future<void> addEntry({
    required String gardenId,
    String? plantId,
    required DateTime entryDate,
    String? note,
    int? wateringMl,
    String? photoUrl,
    List<String> tags = const [],
  }) async {
    await _client.from('journal_entries').insert({
      'garden_id': gardenId,
      'plant_id': plantId,
      'entry_date': entryDate.toIso8601String().split('T').first,
      'note': note,
      'watering_ml': wateringMl,
      'photo_url': photoUrl,
      'tags': tags,
    });

    ref.invalidateSelf();
  }

  Future<void> deleteEntry(String id) async {
    await _client.from('journal_entries').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

// ── Garden Plants ─────────────────────────────────────────

@riverpod
Future<List<String>> gardenPlantIds(
  GardenPlantIdsRef ref,
  String gardenId,
) async {
  final res = await _client
      .from('garden_plants')
      .select('plant_id')
      .eq('garden_id', gardenId);

  return (res as List).map((r) => r['plant_id'] as String).toList();
}

@riverpod
class GardenPlantNotifier extends _$GardenPlantNotifier {
  @override
  Future<List<String>> build(String gardenId) =>
      ref.watch(gardenPlantIdsProvider(gardenId).future);

  Future<void> addPlant(String plantId) async {
    await _client.from('garden_plants').upsert({
      'garden_id': gardenId,
      'plant_id': plantId,
    });
    
    // Schedule planting reminders for all gardens
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final zone = prefs.getString('user_zone') ?? 'Zone 6a';
      ref.read(gardenSchedulerProvider).scheduleAll(user.id, zone);
    }
    
    ref.invalidateSelf();
  }

  Future<void> removePlant(String plantId) async {
    await _client
        .from('garden_plants')
        .delete()
        .eq('garden_id', gardenId)
        .eq('plant_id', plantId);
    ref.invalidateSelf();
  }
}
