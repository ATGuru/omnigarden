import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/featured_garden.dart';

part 'featured_garden_provider.g.dart';

@riverpod
Future<List<FeaturedGarden>> featuredGardens(FeaturedGardensRef ref) async {
  final client = Supabase.instance.client;

  final res = await client
      .from('featured_gardens')
      .select('*, featured_garden_plants(*, plants(id, common_name, emoji))')
      .eq('is_featured', true)
      .order('sort_order');

  return (res as List).map((g) {
    final plantsList = (g['featured_garden_plants'] as List? ?? [])
      ..sort((a, b) =>
          (a['sort_order'] as int).compareTo(b['sort_order'] as int));

    final plants = plantsList.map((fp) {
      final plant = fp['plants'] as Map<String, dynamic>;
      return FeaturedGardenPlant(
        plantId: plant['id'],
        commonName: plant['common_name'],
        emoji: plant['emoji'] ?? '🌱',
        note: fp['note'],
        sortOrder: fp['sort_order'],
      );
    }).toList();

    return FeaturedGarden(
      id: g['id'],
      name: g['name'],
      ownerName: g['owner_name'],
      description: g['description'],
      location: g['location'],
      emoji: g['emoji'] ?? '🌿',
      coverColor: g['cover_color'] ?? '#3D5229',
      sortOrder: g['sort_order'],
      plants: plants,
    );
  }).toList();
}
