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
  if (cache != null) {
    final cached = cache.get<List>(CacheService.searchKey(query));
    if (cached != null) {
      return cached
        .map((p) => _mapPlant(Map<String, dynamic>.from(p)))
        .toList();
    }
  }

  // Fetch all matches
  final results = await Future.wait([
    _client
        .from('plants')
        .select('*, plant_stages(*), plant_calendar(*), plant_varieties(*)')
        .ilike('common_name', '%$query%')
        .limit(50),
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

  final queryLower = query.toLowerCase();

  // Sort: exact match first, then starts with, then word boundary match, then substring match
  combined.sort((a, b) {
    final aName = (a['common_name'] as String).toLowerCase();
    final bName = (b['common_name'] as String).toLowerCase();

    int score(String name) {
      if (name == queryLower) return 0;                          // exact match
      if (name.startsWith(queryLower)) return 1;                // prefix match
      if (name.split(' ').any((w) => w == queryLower)) return 2; // whole word match
      if (name.split(' ').any((w) => w.startsWith(queryLower))) return 3; // word prefix
      return 4;                                                  // substring match
    }

    final diff = score(aName).compareTo(score(bName));
    if (diff != 0) return diff;
    return aName.compareTo(bName); // alphabetical within same score
  });

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
        .contains('plant_calendar', [{'zone': zone}])
        .limit(6);

    return (res as List).map((p) => _mapPlant(p)).toList();
  }

  Plant _mapPlant(Map<String, dynamic> p) {
    // RAW PLANT DATA: ${p['common_name']} | watering: ${p['watering_tips']} | soil: ${p['soil_requirements']}
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
      propagationTips: p['propagation_tips'],
      fertilizingTips: p['fertilizing_tips'],
      pruningTips: p['pruning_tips'],
      spacing: p['spacing'],
      plantingDepth: p['planting_depth'],
      frostTolerance: p['frost_tolerance'],
      containerGrowing: p['container_growing'],
      commonMistakes: p['common_mistakes'],
      funFact: p['fun_fact'],
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
