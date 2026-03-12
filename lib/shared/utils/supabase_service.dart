import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/models/app_user.dart';
import '../../features/plants/models/plant.dart';
import 'cache_service.dart';

part 'supabase_service.g.dart';

final _client = Supabase.instance.client;

// ── Auth ─────────────────────────────────────────────────

class AuthService {
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return AppUser(id: res.user!.id, email: email);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return AppUser(id: res.user!.id, email: res.user!.email ?? email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AppUser?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(id: user.id, email: user.email ?? '');
  }
}

// ── Plants ───────────────────────────────────────────────

class PlantService {
  Future<List<Plant>> searchPlants(String query, {CacheService? cache}) async {
  // Try cache first
  if (cache != null) {
    final cached = cache.get<List>(CacheService.searchKey(query));
    if (cached != null) {
      return cached
          .map((p) => _mapPlant(Map<String, dynamic>.from(p)))
          .toList();
    }
  }

  final results = await Future.wait([
    _client
        .from('plants')
        .select('*, plant_stages(*), plant_calendar(*), plant_varieties(*)')
        .ilike('common_name', '%$query%')
        .limit(30),
    _client
        .from('plants')
        .select('*, plant_stages(*), plant_calendar(*), plant_varieties(*)')
        .ilike('latin_name', '%$query%')
        .limit(10),
  ]);

  final seen = <String>{};
  final combined = <Map<String, dynamic>>[];

  for (final list in results) {
    for (final p in (list as List)) {
      final id = p['id'] as String;
      if (seen.add(id)) combined.add(Map<String, dynamic>.from(p));
    }
  }

  combined.sort((a, b) {
    final aStarts = (a['common_name'] as String)
        .toLowerCase()
        .startsWith(query.toLowerCase());
    final bStarts = (b['common_name'] as String)
        .toLowerCase()
        .startsWith(query.toLowerCase());
    if (aStarts && !bStarts) return -1;
    if (!aStarts && bStarts) return 1;
    return (a['common_name'] as String)
        .compareTo(b['common_name'] as String);
  });

  // Save raw maps to cache
  if (cache != null && combined.isNotEmpty) {
    await cache.set(CacheService.searchKey(query), combined);
  }

  return combined.map(_mapPlant).toList();
}

  Future<Plant> getPlant(String id) async {
    final res = await _client
        .from('plants')
        .select('*, plant_stages(*), plant_calendar(*), plant_varieties(*)')
        .eq('id', id)
        .single();

    return _mapPlant(res);
  }

  Future<List<Plant>> getFeaturedPlants({required String zone}) async {
    final res = await _client
        .from('plants')
        .select('*, plant_stages(*), plant_calendar(*), plant_varieties(*)')
        .limit(6);

    return (res as List).map((p) => _mapPlant(p)).toList();
  }

  Plant _mapPlant(Map<String, dynamic> p) {
    print('🌱 RAW PLANT DATA: ${p['common_name']} | watering: ${p['watering_tips']} | soil: ${p['soil_requirements']}');
    final stagesList = (p['plant_stages'] as List? ?? [])
      ..sort((a, b) =>
          (a['stage_order'] as int).compareTo(b['stage_order'] as int));

    final stages = stagesList.map((s) => PlantStage(
      name: s['name'],
      emoji: s['emoji'],
      weekRange: s['week_range'],
      description: s['description'],
      imageUrl: s['image_url'],
    )).toList();

    final calList = p['plant_calendar'] as List? ?? [];
    final calendarByZone = <String, PlantCalendar>{};
    for (final c in calList) {
      calendarByZone[c['zone']] = PlantCalendar(
        indoorStart: c['indoor_start'],
        transplant: c['transplant'],
        harvest: c['harvest'],
      );
    }

    final varietyList = p['plant_varieties'] as List? ?? [];
    final varieties = varietyList.map((v) => PlantVariety(
      id: v['id'],
      name: v['name'],
      description: v['description'],
      daysToMaturity: v['days_to_maturity'],
    )).toList();

    return Plant(
      id: p['id'],
      commonName: p['common_name'],
      latinName: p['latin_name'],
      emoji: p['emoji'],
      sunRequirement: p['sun_requirement'],
      waterNeeds: p['water_needs'],
      matureHeight: p['mature_height'],
      companions: List<String>.from(p['companions'] ?? []),
      daysToMaturity: p['days_to_maturity'],
      imageUrl: p['image_url'],
      pestsDiseases: p['pests_diseases'],
      soilRequirements: p['soil_requirements'],
      wateringTips: p['watering_tips'],
      harvestingTips: p['harvesting_tips'],
      stages: stages,
      calendarByZone: calendarByZone,
      varieties: varieties,
    );
  }
}

// ── Providers ─────────────────────────────────────────────

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

@riverpod
PlantService plantService(PlantServiceRef ref) => PlantService();
