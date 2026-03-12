// lib/features/plants/providers/plant_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/plant.dart';
import '../../../shared/utils/supabase_service.dart';
import '../../../shared/utils/cache_provider.dart';
import '../../auth/providers/auth_provider.dart';

part 'plant_providers.g.dart';

// ── Search query state ────────────────────────────────────
@riverpod
class PlantSearchQuery extends _$PlantSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

// ── Search results ────────────────────────────────────────
@riverpod
Future<List<Plant>> plantSearchResults(PlantSearchResultsRef ref) async {
  final query = ref.watch(plantSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final service = ref.read(plantServiceProvider);
  final cache   = ref.read(cacheServiceProvider);

  final exact = await service.searchPlants(query, cache: cache);
  if (exact.isNotEmpty) return exact;

  final words = query.trim().split(' ').where((w) => w.length > 2).toList();
  if (words.isEmpty) return [];

  return service.searchPlants(words.first, cache: cache);
}

// ── Single plant by ID ────────────────────────────────────
@riverpod
Future<Plant> plant(PlantRef ref, String id) =>
    ref.read(plantServiceProvider).getPlant(id);

// ── Featured / "Start Soon" for dashboard ─────────────────
@riverpod
Future<List<Plant>> featuredPlants(FeaturedPlantsRef ref) async {
  final zone = ref.watch(authStateNotifierProvider).value?.zone ?? 'Zone 6a';
  return ref.read(plantServiceProvider).getFeaturedPlants(zone: zone);
}

// ── Recent searches (local, no backend) ───────────────────
@riverpod
class RecentSearches extends _$RecentSearches {
  static const _maxRecent = 8;

  @override
  List<String> build() => [];

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    state = [q, ...state.where((s) => s != q)].take(_maxRecent).toList();
  }

  void remove(String query) {
    state = state.where((s) => s != query).toList();
  }

  void clear() => state = [];
}
