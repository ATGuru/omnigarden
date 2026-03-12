class FeaturedGarden {
  final String id;
  final String name;
  final String ownerName;
  final String? description;
  final String? location;
  final String emoji;
  final String coverColor;
  final int sortOrder;
  final List<FeaturedGardenPlant> plants;

  const FeaturedGarden({
    required this.id,
    required this.name,
    required this.ownerName,
    this.description,
    this.location,
    required this.emoji,
    required this.coverColor,
    required this.sortOrder,
    this.plants = const [],
  });
}

class FeaturedGardenPlant {
  final String plantId;
  final String commonName;
  final String emoji;
  final String? note;
  final int sortOrder;

  const FeaturedGardenPlant({
    required this.plantId,
    required this.commonName,
    required this.emoji,
    this.note,
    required this.sortOrder,
  });
}
