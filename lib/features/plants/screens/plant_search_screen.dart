// lib/features/plants/screens/plant_search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../providers/plant_providers.dart';
import '../models/plant.dart';

// ── Search Filters Model ───────────────────────────────────────

class SearchFilters {
  final List<String> categories;
  final String? sunRequirement;
  final String? waterNeed;
  final List<String> plantingMethods;
  final int minDaysToHarvest;
  final int maxDaysToHarvest;
  final String companionPlants;
  final bool zoneCompatibleOnly;

  const SearchFilters({
    this.categories = const [],
    this.sunRequirement,
    this.waterNeed,
    this.plantingMethods = const [],
    this.minDaysToHarvest = 0,
    this.maxDaysToHarvest = 365,
    this.companionPlants = '',
    this.zoneCompatibleOnly = false,
  });

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      sunRequirement != null ||
      waterNeed != null ||
      plantingMethods.isNotEmpty ||
      minDaysToHarvest > 0 ||
      companionPlants.isNotEmpty ||
      zoneCompatibleOnly;

  int get activeCount {
    int count = 0;
    if (categories.isNotEmpty) count++;
    if (sunRequirement != null) count++;
    if (waterNeed != null) count++;
    if (plantingMethods.isNotEmpty) count++;
    if (minDaysToHarvest > 0) count++;
    if (companionPlants.isNotEmpty) count++;
    if (zoneCompatibleOnly) count++;
    return count;
  }

  SearchFilters copyWith({
    List<String>? categories,
    String? sunRequirement,
    bool clearSun = false,
    String? waterNeed,
    bool clearWater = false,
    List<String>? plantingMethods,
    int? minDaysToHarvest,
    int? maxDaysToHarvest,
    String? companionPlants,
    bool? zoneCompatibleOnly,
  }) {
    return SearchFilters(
      categories: categories ?? this.categories,
      sunRequirement: clearSun ? null : sunRequirement ?? this.sunRequirement,
      waterNeed: clearWater ? null : waterNeed ?? this.waterNeed,
      plantingMethods: plantingMethods ?? this.plantingMethods,
      minDaysToHarvest: minDaysToHarvest ?? this.minDaysToHarvest,
      maxDaysToHarvest: maxDaysToHarvest ?? this.maxDaysToHarvest,
      companionPlants: companionPlants ?? this.companionPlants,
      zoneCompatibleOnly: zoneCompatibleOnly ?? this.zoneCompatibleOnly,
    );
  }
}

// ── Plant Search Screen ────────────────────────────────────────

class PlantSearchScreen extends ConsumerStatefulWidget {
  const PlantSearchScreen({super.key});

  @override
  ConsumerState<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends ConsumerState<PlantSearchScreen> {
  final _ctrl = TextEditingController();
  SearchFilters _filters = const SearchFilters();

  Future<void> _refresh() async {
    ref.invalidate(plantSearchResultsProvider);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        filters: _filters,
        onApply: (filters) {
          setState(() => _filters = filters);
        },
        onClear: () {
          setState(() => _filters = const SearchFilters());
        },
      ),
    );
  }

  void _submit(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    ref.read(plantSearchQueryProvider.notifier).update(q);
    ref.read(recentSearchesProvider.notifier).add(q);
  }

  void _clear() {
    _ctrl.clear();
    ref.read(plantSearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final query   = ref.watch(plantSearchQueryProvider);
    final recents = ref.watch(recentSearchesProvider);
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Search Plants',
                    style: AppTypography.displayM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filters.hasActiveFilters
                            ? AppColors.terracotta.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _filters.hasActiveFilters
                              ? AppColors.terracotta
                              : AppColors.borderDark,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune,
                            color: _filters.hasActiveFilters
                                ? AppColors.terracotta
                                : AppColors.warmGray,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Filters',
                            style: AppTypography.bodyS(
                              color: _filters.hasActiveFilters
                                  ? AppColors.terracotta
                                  : AppColors.warmGray,
                            ),
                          ),
                          if (_filters.hasActiveFilters) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.terracotta,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_filters.activeCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: _submit,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          ref.read(plantSearchQueryProvider.notifier).clear();
                        } else {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (_ctrl.text == v) {
                              ref.read(plantSearchQueryProvider.notifier).state = v;
                            }
                          });
                        }
                        setState(() {}); // rebuild for suffix button
                      },
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      style: AppTypography.bodyM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'jalapeño, tomato, blackberry...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 14, right: 8),
                          child: Text('🔍', style: TextStyle(fontSize: 18)),
                        ),
                        prefixIconConstraints: const BoxConstraints(),
                        suffixIcon: query.isNotEmpty
                            ? GestureDetector(
                                onTap: _clear,
                                child: const Icon(Icons.close,
                                    color: AppColors.warmGray, size: 18),
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (_ctrl.text.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _submit(_ctrl.text),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.terracotta,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                        child: const Icon(Icons.search, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Active filter chips
            if (_filters.hasActiveFilters) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final cat in _filters.categories)
                      _ActiveFilterChip(
                        label: cat,
                        onRemove: () => setState(() => _filters = _filters.copyWith(
                          categories: _filters.categories.where((c) => c != cat).toList(),
                        )),
                      ),
                    if (_filters.sunRequirement != null)
                      _ActiveFilterChip(
                        label: _filters.sunRequirement!,
                        onRemove: () => setState(() => _filters = _filters.copyWith(clearSun: true)),
                      ),
                    if (_filters.waterNeed != null)
                      _ActiveFilterChip(
                        label: _filters.waterNeed!,
                        onRemove: () => setState(() => _filters = _filters.copyWith(clearWater: true)),
                      ),
                    if (_filters.zoneCompatibleOnly)
                      _ActiveFilterChip(
                        label: 'Zone compatible',
                        onRemove: () => setState(() => _filters = _filters.copyWith(zoneCompatibleOnly: false)),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Body
            Expanded(
              child: query.isEmpty
                  ? _RecentSearches(
                      recents: recents,
                      onTap: (q) {
                        _ctrl.text = q;
                        _submit(q);
                      },
                      onClear: (q) =>
                          ref.read(recentSearchesProvider.notifier).remove(q),
                    )
                  : _SearchResults(query: query, filters: _filters, onRefresh: _refresh),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active Filter Chip ─────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.terracotta),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.bodyS(color: AppColors.terracotta)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: AppColors.terracotta, size: 12),
          ),
        ],
      ),
    );
  }
}

// ── Filter Sheet ───────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.filters,
    required this.onApply,
    required this.onClear,
  });
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;
  final VoidCallback onClear;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SearchFilters _local;

  static const _categories = [
    'Vegetables', 'Fruits', 'Herbs', 'Flowers',
    'Trees', 'Shrubs', 'Vines', 'Cover Crops',
  ];
  static const _sunOptions    = ['Full Sun', 'Part Shade', 'Full Shade'];
  static const _waterOptions  = ['Low', 'Medium', 'High'];
  static const _methodOptions = ['Direct Sow', 'Start Indoors', 'Transplant'];

  @override
  void initState() {
    super.initState();
    _local = widget.filters;
  }

  void _toggleCategory(String cat) {
    final list = List<String>.from(_local.categories);
    list.contains(cat) ? list.remove(cat) : list.add(cat);
    setState(() => _local = _local.copyWith(categories: list));
  }

  void _toggleMethod(String m) {
    final list = List<String>.from(_local.plantingMethods);
    list.contains(m) ? list.remove(m) : list.add(m);
    setState(() => _local = _local.copyWith(plantingMethods: list));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warmGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Text('Filter Plants', style: AppTypography.displayM()),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          widget.onClear();
                          Navigator.pop(context);
                        },
                        child: Text('Clear All',
                            style: AppTypography.bodyS(color: AppColors.rust)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Text('CATEGORY', style: AppTypography.monoS(color: AppColors.warmGray)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.map((cat) {
                      final selected = _local.categories.contains(cat);
                      return GestureDetector(
                        onTap: () => _toggleCategory(cat),
                        child: _FilterPill(label: cat, selected: selected),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Sun
                  Text('SUN REQUIREMENTS', style: AppTypography.monoS(color: AppColors.warmGray)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _sunOptions.map((s) {
                      final selected = _local.sunRequirement == s;
                      return GestureDetector(
                        onTap: () => setState(() => _local = _local.copyWith(
                          sunRequirement: selected ? null : s,
                          clearSun: selected,
                        )),
                        child: _FilterPill(label: s, selected: selected),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Water
                  Text('WATER NEEDS', style: AppTypography.monoS(color: AppColors.warmGray)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _waterOptions.map((w) {
                      final selected = _local.waterNeed == w;
                      return GestureDetector(
                        onTap: () => setState(() => _local = _local.copyWith(
                          waterNeed: selected ? null : w,
                          clearWater: selected,
                        )),
                        child: _FilterPill(label: w, selected: selected),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Planting method
                  Text('PLANTING METHOD', style: AppTypography.monoS(color: AppColors.warmGray)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _methodOptions.map((m) {
                      final selected = _local.plantingMethods.contains(m);
                      return GestureDetector(
                        onTap: () => _toggleMethod(m),
                        child: _FilterPill(label: m, selected: selected),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Zone compatible
                  Text('ZONE COMPATIBILITY', style: AppTypography.monoS(color: AppColors.warmGray)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _local = _local.copyWith(
                      zoneCompatibleOnly: !_local.zoneCompatibleOnly,
                    )),
                    child: _FilterPill(
                      label: 'My zone only',
                      selected: _local.zoneCompatibleOnly,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: OGButton(
              label: 'Apply Filters',
              onPressed: () {
                widget.onApply(_local);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.terracotta.withOpacity(0.15) : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.terracotta : AppColors.borderDark,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyS(
          color: selected ? AppColors.terracotta : AppColors.warmGray,
        ),
      ),
    );
  }
}

// ── Recent Searches ────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.recents,
    required this.onTap,
    required this.onClear,
  });
  final List<String> recents;
  final void Function(String) onTap;
  final void Function(String) onClear;

  @override
  Widget build(BuildContext context) {
    if (recents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Search for any plant',
                style: AppTypography.displayM(color: AppColors.warmGray)),
            const SizedBox(height: 8),
            Text('Vegetables, herbs, fruits, flowers.', style: AppTypography.bodyS()),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recents.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SectionLabel(
              label: 'Recent',
              trailing: TextButton(
                onPressed: () {},
                child: Text('Clear',
                    style: AppTypography.monoS(color: AppColors.terracotta)),
              ),
            ),
          );
        }
        final q = recents[i - 1];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Text('🕐', style: TextStyle(fontSize: 16)),
          title: Text(q, style: AppTypography.bodyM(color: AppColors.cream)),
          trailing: GestureDetector(
            onTap: () => onClear(q),
            child: const Icon(Icons.close, size: 16, color: AppColors.warmGray),
          ),
          onTap: () => onTap(q),
        );
      },
    );
  }
}

// ── Search Results ─────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.filters, required this.onRefresh});
  final String query;
  final SearchFilters filters;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(plantSearchResultsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return resultsAsync.when(
      loading: () => _ResultsSkeletonList(),
      error: (e, _) => OGErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(plantSearchResultsProvider),
      ),
      data: (plants) {
        if (plants.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🥀', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('No results for "$query"',
                    style: AppTypography.displayM(color: AppColors.warmGray)),
                const SizedBox(height: 8),
                Text('Try a common name or variety.', style: AppTypography.bodyS()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('${plants.length} results', style: AppTypography.monoS()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.terracotta,
                backgroundColor: AppColors.charcoal,
                onRefresh: () async => onRefresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: plants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final plant = plants[i];
                    return GestureDetector(
                      onTap: () => context.push('/plant/${plant.id}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.fern.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                              ),
                              child: Center(
                                child: Text(plant.emoji,
                                    style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plant.commonName,
                                      style: AppTypography.labelM(
                                        color: isDark ? AppColors.cream : AppColors.ink,
                                      )),
                                  const SizedBox(height: 2),
                                  if (plant.latinName.isNotEmpty)
                                    Text(
                                      plant.latinName,
                                      style: AppTypography.bodyS().copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 10,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plant.daysToMaturity} days',
                                    style: AppTypography.bodyS(
                                      color: AppColors.warmGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.warmGray, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultsSkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SkeletonBox(width: 40, height: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 120, height: 12),
                const SizedBox(height: 6),
                SkeletonBox(width: 80, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
