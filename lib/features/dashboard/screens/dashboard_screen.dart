import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../../shared/utils/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../plants/models/plant.dart';
import '../../plants/providers/plant_providers.dart';
import '../../gardens/providers/featured_garden_provider.dart';
import '../../gardens/models/featured_garden.dart';
import '../../gardens/screens/featured_garden_screen.dart';

final _client = Supabase.instance.client;

// Fetch plants from user's gardens with their garden name and indoor start date
final startingSoonProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return [];

  final zone = ref.read(authStateNotifierProvider).value?.zone ?? 'Zone 6a';

  // Get all garden plants with garden name
  final res = await _client
      .from('garden_plants')
      .select('plant_id, gardens!inner(id, name, emoji, user_id)')
      .eq('gardens.user_id', userId);

  if ((res as List).isEmpty) return [];

  // Get unique plant IDs
  final plantIds = res.map((r) => r['plant_id'] as String).toSet().toList();

  // Fetch full plant data
  final plants = await Future.wait<Plant>(
    plantIds.map((id) => ref.read(plantServiceProvider).getPlant(id)),
  );

  // Map plant to garden name + calendar data
  final results = <Map<String, dynamic>>[];
  for (final r in res) {
    final plant = plants.firstWhere(
      (p) => p.id == r['plant_id'],
      orElse: () => plants.first,
    );
    final garden = r['gardens'] as Map<String, dynamic>;
    final calendar = plant.calendarByZone[zone];
    if (calendar != null && calendar.indoorStart != 'N/A') {
      results.add({
        'plant': plant,
        'gardenName': garden['name'],
        'gardenEmoji': garden['emoji'],
        'indoorStart': calendar.indoorStart,
        'transplant': calendar.transplant,
        'harvest': calendar.harvest,
      });
    }
  }

  // Sort by month of indoor start
  const months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];
  final currentMonth = DateTime.now().month - 1;
  results.sort((a, b) {
    int monthOf(String s) {
      final lower = s.toLowerCase();
      for (int i = 0; i < months.length; i++) {
        if (lower.contains(months[i])) return i;
      }
      return 12;
    }
    final am = monthOf(a['indoorStart']);
    final bm = monthOf(b['indoorStart']);
    // Sort by proximity to current month
    final ad = (am - currentMonth + 12) % 12;
    final bd = (bm - currentMonth + 12) % 12;
    return ad.compareTo(bd);
  });

  return results;
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _refresh() async {
    ref.invalidate(authStateNotifierProvider);
    ref.invalidate(featuredPlantsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateNotifierProvider);
    final zone     = authAsync.value?.zone ?? 'Zone 6a';
    final zip      = authAsync.value?.zip ?? '';
    final location = authAsync.value?.location;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        title: Text(
          'Dashboard',
          style: AppTypography.displayM(color: AppColors.cream),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.warmGray,
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.terracotta,
        backgroundColor: AppColors.charcoal,
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
          _DashboardHero(zone: zone, zip: zip, location: location),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _QuickActionRow(
                        emoji: '🔍',
                        title: 'Search Plants',
                        subtitle: '12,000+ varieties',
                        onTap: () => context.go('/search'),
                      ),
                      const SizedBox(height: 8),
                      _QuickActionRow(
                        emoji: '📅',
                        title: 'My Calendar',
                        subtitle: 'Your planting windows',
                        onTap: () => context.go('/calendar'),
                      ),
                      const SizedBox(height: 8),
                      _QuickActionRow(
                        emoji: '🌿',
                        title: 'My Gardens',
                        subtitle: 'Track your plants',
                        onTap: () => context.go('/gardens'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // Starting soon section
          _StartingSoonSliver(),

          // Featured gardens section
          _FeaturedGardensSliver(),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────
class _DashboardHero extends ConsumerWidget {
  const _DashboardHero({required this.zone, required this.zip, required this.location});
  final String zone;
  final String zip;
  final String? location;

  Map<String, String> _getSeasonalTip(String? location) {
    final month = DateTime.now().month;
    final place = location ?? 'your zone';
    String season;
    if (month == 12 || month <= 2) season = 'Planning season';
    else if (month <= 4) season = 'Seed starting season';
    else if (month <= 6) season = 'Planting season';
    else if (month <= 8) season = 'Growing season';
    else if (month <= 10) season = 'Harvest season';
    else season = 'End of season';
    return {
      'headline': '$season in $place.',
      'tagline': 'Every great harvest starts right now.',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateNotifierProvider);
    final zone     = authAsync.value?.zone ?? 'Zone 6a';
    final zip      = authAsync.value?.zip ?? '';
    final location = authAsync.value?.location;
    
    final month = DateTime.now().month;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tip = _getSeasonalTip(location);
    final frost = AppConstants.frostDates[zone];

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.moss,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        IconButton(
          icon: Text(isDark ? '☀️' : '🌑', style: const TextStyle(fontSize: 20)),
          onPressed: () => ref.read(themeMode_Provider.notifier).toggle(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.cream),
          onPressed: () => context.push('/settings'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.fern, AppColors.moss],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ZoneBadge(zone: location ?? zone),
                  const SizedBox(height: 12),
                  Text(
                    tip['headline']!,
                    style: AppTypography.displayM(color: AppColors.cream),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip['tagline']!,
                    style: AppTypography.bodyS(color: AppColors.cream.withOpacity(0.9)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (frost != null)
                    FrostChip(label: 'Last frost', date: frost['last'] ?? '—'),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.none,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(16),
        child: Container(
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
      ),
    );
  }
}

// ── Starting soon sliver ──────────────────────────────────
class _StartingSoonSliver extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(startingSoonProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: plantsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(label: 'Start Soon'),
                const SizedBox(height: 14),
                ...items.map((item) {
                  final plant = item['plant'] as Plant;
                  return GestureDetector(
                    onTap: () => context.push('/plant/${plant.id}'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.fern.withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSM),
                            ),
                            child: Center(
                              child: Text(plant.emoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plant.commonName,
                                  style: AppTypography.labelM(
                                    color: isDark
                                        ? AppColors.cream
                                        : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '${item['gardenEmoji']} ${item['gardenName']}',
                                      style: AppTypography.bodyS(),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                        color: AppColors.warmGray,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '🌱 Start ${item['indoorStart']}',
                                      style: AppTypography.monoS(
                                              color: AppColors.leaf)
                                          .copyWith(fontSize: 10),
                                    ),
                                  ],
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
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Quick action row ──────────────────────────────────────
class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.fern.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodyS()),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: onTap != null
                  ? AppColors.warmGray
                  : AppColors.borderDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured Gardens ────────────────────────────────────────
class _FeaturedGardensSliver extends StatelessWidget {
  const _FeaturedGardensSliver();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(label: 'Featured Gardens'),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                // Could show a dialog or navigate to coming soon page
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.moss.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '🌱',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coming soon',
                              style: AppTypography.bodyM(
                                color: isDark ? AppColors.cream : AppColors.soil,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inspiring gardens from real growers.',
                              style: AppTypography.bodyS(
                                color: isDark ? AppColors.cream : AppColors.warmGray,
                              ).copyWith(
                                color: (isDark ? AppColors.cream : AppColors.warmGray)
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? AppColors.cream : AppColors.warmGray,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
