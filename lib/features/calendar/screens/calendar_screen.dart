import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../../shared/utils/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../plants/models/plant.dart';
import '../../plants/providers/plant_providers.dart';

final _client = Supabase.instance.client;

final userCalendarPlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return [];

  final res = await _client
      .from('garden_plants')
      .select('plant_id, gardens!inner(user_id)')
      .eq('gardens.user_id', userId);

  final plantIds = (res as List)
      .map((r) => r['plant_id'] as String)
      .toSet()
      .toList();

  if (plantIds.isEmpty) return [];

  final plants = await Future.wait<Plant>(
    plantIds.map((id) => ref.read(plantServiceProvider).getPlant(id)),
  );

  return plants.toList();
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  static const _fullMonths = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  Future<void> _refresh() async {
    ref.invalidate(userCalendarPlantsProvider);
    ref.invalidate(authStateNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(userCalendarPlantsProvider);
    final authState = ref.watch(authStateNotifierProvider).value;
    final locationText = authState?.location ?? authState?.zone ?? 'your area';
    final currentMonth = DateTime.now().month;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        title: Text(
          'Planting Calendar',
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planting Calendar',
                        style: AppTypography.displayM(
                          color: isDark ? AppColors.cream : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ZoneBadge(zone: locationText),
                    ],
                  ),
                ],
              ),
            ),

            // Month column headers
            Padding(
              padding: const EdgeInsets.fromLTRB(100, 0, 16, 8),
              child: Row(
                children: List.generate(12, (i) {
                  final isCurrent = i + 1 == currentMonth;
                  return Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.terracotta.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _months[i],
                        style: AppTypography.monoS(
                          color: isCurrent
                              ? AppColors.terracotta
                              : AppColors.warmGray,
                        ).copyWith(fontSize: 9),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: plantsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => OGErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(userCalendarPlantsProvider),
                ),
                data: (plants) => plants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📅', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text('No plants added yet',
                                style: AppTypography.displayM(
                                    color: AppColors.warmGray)),
                            const SizedBox(height: 8),
                            Text(
                              'Search a plant → tap Add to Garden\n→ your planting dates appear here.',
                              style: AppTypography.bodyS(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Legend
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Row(
                              children: [
                                _LegendDot(color: AppColors.frost, label: 'Indoors'),
                                const SizedBox(width: 14),
                                _LegendDot(color: AppColors.terracotta, label: 'Transplant'),
                                const SizedBox(width: 14),
                                _LegendDot(color: AppColors.leaf, label: 'Direct sow'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.terracotta,
                              backgroundColor: AppColors.charcoal,
                              onRefresh: _refresh,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(0, 8, 16, 80),
                                itemCount: plants.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) => _CalendarRow(
                                  plant: plants[i],
                                  zone: authState?.zone ?? 'Zone 6a',
                                  currentMonth: currentMonth,
                                  months: _months,
                                  fullMonths: _fullMonths,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calendar Row ──────────────────────────────────────────

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.plant,
    required this.zone,
    required this.currentMonth,
    required this.months,
    required this.fullMonths,
  });

  final Plant plant;
  final String zone;
  final int currentMonth;
  final List<String> months;
  final List<String> fullMonths;

  int? _monthIndex(String? s) {
    if (s == null || s == 'N/A') return null;
    const m = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];
    final lower = s.toLowerCase();
    for (int i = 0; i < m.length; i++) {
      if (lower.contains(m[i])) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendar = plant.calendarByZone[zone];

    final indoorMonth     = _monthIndex(calendar?.indoorStart);
    final transplantMonth = _monthIndex(calendar?.transplant);
    final harvestMonth    = _monthIndex(calendar?.harvest);

    return InkWell(
      onTap: () => _showDetail(context, calendar),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Plant name column (fixed 100px)
            SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Text(plant.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        plant.commonName,
                        style: AppTypography.monoS(
                          color: isDark ? AppColors.cream : AppColors.ink,
                        ).copyWith(fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 12 month cells
            ...List.generate(12, (i) {
              final isIndoor     = indoorMonth == i;
              final isTransplant = transplantMonth == i;
              final isHarvest    = harvestMonth == i;
              final isCurrent    = i + 1 == currentMonth;

              Color? cellColor;
              if (isIndoor)     cellColor = AppColors.frost;
              if (isTransplant) cellColor = AppColors.terracotta;
              if (isHarvest)    cellColor = AppColors.leaf;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 28,
                  decoration: BoxDecoration(
                    color: cellColor ?? (isDark
                        ? AppColors.surfaceDark.withOpacity(0.4)
                        : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(3),
                    border: isCurrent
                        ? Border.all(color: AppColors.terracotta, width: 1.5)
                        : null,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, PlantCalendar? calendar) {
    if (calendar == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plant.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(plant.commonName, style: AppTypography.displayM()),
              ],
            ),
            const SizedBox(height: 20),
            if (calendar.indoorStart != 'N/A')
              _DetailRow('🌱', 'Start indoors', calendar.indoorStart, AppColors.frost),
            const SizedBox(height: 12),
            _DetailRow('🪴', 'Transplant', calendar.transplant, AppColors.terracotta),
            const SizedBox(height: 12),
            _DetailRow('🌾', 'Harvest', calendar.harvest, AppColors.leaf),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.emoji, this.label, this.value, this.color);
  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(emoji)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.monoS(color: AppColors.warmGray)),
            Text(value, style: AppTypography.labelM(color: AppColors.cream)),
          ],
        ),
      ],
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTypography.monoS()),
      ],
    );
  }
}
