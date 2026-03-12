import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../plants/models/plant.dart';
import '../../plants/providers/plant_providers.dart';
import '../../../shared/utils/supabase_service.dart';

final _client = Supabase.instance.client;

// Fetch all plants the user has added across all gardens
final userCalendarPlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return [];

  // Get all plant IDs from user's gardens
  final res = await _client
      .from('garden_plants')
      .select('plant_id, gardens!inner(user_id)')
      .eq('gardens.user_id', userId);

  final plantIds = (res as List)
      .map((r) => r['plant_id'] as String)
      .toSet()
      .toList();

  if (plantIds.isEmpty) return [];

  // Fetch full plant data for each
  final plants = await Future.wait<Plant>(
    plantIds.map((id) => ref.read(plantServiceProvider).getPlant(id)),
  );

  return plants.toList();
});

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(userCalendarPlantsProvider);
    final zone = ref.watch(authStateNotifierProvider).value?.zone ?? 'Zone 6a';
    final currentMonth = DateTime.now().month;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planting Calendar',
                    style: AppTypography.displayM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ZoneBadge(zone: zone),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Month header strip
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final isCurrent = i + 1 == currentMonth;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.terracotta
                          : AppColors.surfaceDark,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.terracotta
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Text(
                      _months[i],
                      style: AppTypography.monoS(
                        color: isCurrent
                            ? Colors.white
                            : AppColors.warmGray,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            Expanded(
              child: plantsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => OGErrorState(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(userCalendarPlantsProvider),
                ),
                data: (plants) => plants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📅',
                                style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text(
                              'No plants added yet',
                              style: AppTypography.displayM(
                                  color: AppColors.warmGray),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search a plant → tap Add to Garden\n→ your planting dates appear here.',
                              style: AppTypography.bodyS(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: plants.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (_, i) => _CalendarPlantRow(
                          plant: plants[i],
                          zone: zone,
                          currentMonth: currentMonth,
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

// ── Calendar plant row ────────────────────────────────────

class _CalendarPlantRow extends StatelessWidget {
  const _CalendarPlantRow({
    required this.plant,
    required this.zone,
    required this.currentMonth,
  });
  final Plant plant;
  final String zone;
  final int currentMonth;

  // Very rough month index from a date string like "Mar 1" or "Apr 25"
  int? _monthIndex(String? dateStr) {
    if (dateStr == null || dateStr == 'N/A') return null;
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    final lower = dateStr.toLowerCase();
    for (int i = 0; i < months.length; i++) {
      if (lower.contains(months[i])) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendar = plant.calendarByZone[zone];

    final indoorMonth    = _monthIndex(calendar?.indoorStart);
    final transplantMonth = _monthIndex(calendar?.transplant);
    final harvestStart   = _monthIndex(calendar?.harvest);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant name row
          Row(
            children: [
              Text(plant.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                plant.commonName,
                style: AppTypography.sectionTitle(
                  color: isDark ? AppColors.cream : AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 12-month bar
          Row(
            children: List.generate(12, (i) {
              final isCurrent  = i + 1 == currentMonth;
              final isIndoor   = indoorMonth == i;
              final isTransplant = transplantMonth == i;
              final isHarvest  = harvestStart == i;

              Color barColor = isDark
                  ? AppColors.surfaceDark
                  : AppColors.mist;
              if (isIndoor)    barColor = AppColors.leaf;
              if (isTransplant) barColor = AppColors.sprout;
              if (isHarvest)   barColor = AppColors.terracotta;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 20,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                    border: isCurrent
                        ? Border.all(color: AppColors.cream, width: 1.5)
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Legend
          if (calendar != null)
            Row(
              children: [
                if (calendar.indoorStart != 'N/A')
                  _LegendDot(
                      color: AppColors.leaf,
                      label: 'Start ${calendar.indoorStart}'),
                if (calendar.indoorStart != 'N/A')
                  const SizedBox(width: 10),
                _LegendDot(
                    color: AppColors.sprout,
                    label: 'Transplant ${calendar.transplant}'),
                const SizedBox(width: 10),
                _LegendDot(
                    color: AppColors.terracotta,
                    label: 'Harvest'),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.monoS()),
      ],
    );
  }
}
