// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../plants/providers/plant_providers.dart';
import '../../plants/models/plant.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateNotifierProvider);
    final zone = authAsync.value?.zone ?? 'Zone 6a';
    final zip  = authAsync.value?.zip ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _DashboardHero(zone: zone, zip: zip),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Quick action grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
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
    const SizedBox(height: 8),
    _QuickActionRow(
      emoji: '🏆',
      title: "Chelle's Garden",
      subtitle: 'Coming soon',
      onTap: null,
    ),
  ],
),
                  const SizedBox(height: 28),
                  SectionLabel(label: 'Start Soon in $zone'),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Featured plants list
          _FeaturedPlantsSliver(zone: zone),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Hero section ─────────────────────────────────────────
class _DashboardHero extends ConsumerWidget {
  const _DashboardHero({required this.zone, required this.zip});
  final String zone;
  final String zip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month    = DateTime.now().month;
    final greeting = AppConstants.dashboardGreetings[month] ?? '';
    final frost    = AppConstants.frostDates[zone];
    final isDark   = ref.watch(themeMode_Provider.select((mode) => mode == ThemeMode.dark));

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.moss,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        // Theme toggle
        IconButton(
          icon: Text(isDark ? '☀️' : '🌑', style: const TextStyle(fontSize: 20)),
          tooltip: 'Toggle theme',
          onPressed: () => ref.read(themeMode_Provider.notifier).toggle(),
        ),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.cream),
          onPressed: () {},
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
                  // Zone + ZIP badge
                  ZoneBadge(zone: '$zone${zip.isNotEmpty ? ' · $zip' : ''}'),
                  const SizedBox(height: 12),

                  // Greeting
                  Text(
                    greeting,
                    style: AppTypography.displayM(color: AppColors.cream),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Frost chip
                  if (frost != null)
                    FrostChip(
                      label: 'Last frost',
                      date: frost['last'] ?? '—',
                    ),
                ],
              ),
            ),
          ),
        ),
        // Curved bottom
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
              color: onTap != null ? AppColors.warmGray : AppColors.borderDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured plants sliver ────────────────────────────────
class _FeaturedPlantsSliver extends ConsumerWidget {
  const _FeaturedPlantsSliver({required this.zone});
  final String zone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(featuredPlantsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: plantsAsync.when(
        loading: () => SliverList(
          delegate: SliverChildListDelegate([
            for (int i = 0; i < 4; i++) ...[
              _PlantChipSkeleton(),
              const SizedBox(height: 10),
            ],
          ]),
        ),
        error: (e, _) => SliverToBoxAdapter(
          child: OGErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(featuredPlantsProvider),
          ),
        ),
        data: (plants) => SliverToBoxAdapter(
          child: SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: plants.length,
              itemBuilder: (_, i) {
                final plant = plants[i];
                return GestureDetector(
                  onTap: () => context.push('/plant/${plant.id}'),
                  child: Container(
                    width: 72,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.fern.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                          ),
                          child: Center(
                            child: Text(
                              plant.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plant.commonName,
                          style: AppTypography.monoS(
                            color: isDark ? AppColors.cream : AppColors.ink,
                          ).copyWith(fontSize: 9),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantChip extends StatelessWidget {
  const _PlantChip({required this.plant, required this.zone});
  final Plant plant;
  final String zone;

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final calendar = plant.calendarByZone[zone];

    return GestureDetector(
      onTap: () => context.push(AppRoutes.plantDetailPath(plant.id)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Text(plant.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.commonName,
                    style: AppTypography.sectionTitle(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  if (calendar != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Indoor start: ${calendar.indoorStart}',
                      style: AppTypography.bodyS(),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.leaf,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '+ Add',
                style: AppTypography.monoS(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantChipSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, radius: 8),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: 160, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
