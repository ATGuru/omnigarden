// lib/features/plants/screens/plant_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../gardens/widgets/add_to_garden_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/plant.dart';
import '../providers/plant_providers.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  const PlantDetailScreen({super.key, required this.plantId});
  final String plantId;

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  int _activeStage = 0;

  @override
  Widget build(BuildContext context) {
    final plantAsync = ref.watch(plantProvider(widget.plantId));
    final zone = ref.watch(authStateNotifierProvider).value?.zone ?? 'Zone 6a';

    return plantAsync.when(
      loading: () => const _PlantDetailSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: OGErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(plantProvider(widget.plantId)),
        ),
      ),
      data: (plant) => _PlantDetailContent(
        plant: plant,
        zone: zone,
        activeStage: _activeStage,
        onStageChanged: (i) => setState(() => _activeStage = i),
      ),
    );
  }
}

// ── Main content scaffold ─────────────────────────────────
class _PlantDetailContent extends StatelessWidget {
  const _PlantDetailContent({
    required this.plant,
    required this.zone,
    required this.activeStage,
    required this.onStageChanged,
  });
  final Plant plant;
  final String zone;
  final int activeStage;
  final ValueChanged<int> onStageChanged;

  @override
  Widget build(BuildContext context) {
    final calendar = plant.calendarByZone[zone];

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColors.soil
        : AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.fern,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: BackButton(color: AppColors.cream),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddToGardenSheet(plantId: plant.id),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '+ Add to Garden',
                        style: AppTypography.monoS(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A6E2A), Color(0xFF2D4A1A)],
                  ),
                ),
                child: Center(
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
              collapseMode: CollapseMode.none,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(16),
              child: Container(
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.parchment,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name + zone tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.commonName,
                            style: AppTypography.plantName(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plant.latinName,
                            style: AppTypography.bodyS().copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.warmGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Zone compatibility chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.sprout.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.sprout.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        '$zone ✓',
                        style: AppTypography.monoS(color: AppColors.moss),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats row
                _StatsRow(plant: plant),
                const SizedBox(height: 28),

                // Growth stage carousel
                if (plant.stages.isNotEmpty) ...[
                  SectionLabel(label: 'Growth Stages'),
                  const SizedBox(height: 14),
                  _StageCarousel(
                    stages: plant.stages,
                    activeIndex: activeStage,
                    onChanged: onStageChanged,
                  ),
                  const SizedBox(height: 12),

                  // Active stage description
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _StageDescription(
                      key: ValueKey(activeStage),
                      stage: plant.stages[activeStage],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Zone calendar
                if (calendar != null) ...[
                  SectionLabel(label: 'Your $zone Timeline'),
                  const SizedBox(height: 14),
                  _ZoneCalendarBar(calendar: calendar),
                  const SizedBox(height: 28),
                ],

                // Varieties
                if (plant.varieties.isNotEmpty) ...[
                  SectionLabel(label: 'Varieties'),
                  const SizedBox(height: 14),
                  _VarietiesTabs(varieties: plant.varieties),
                  const SizedBox(height: 28),
                ],

                // Info tabs
                _InfoTabs(plant: plant),
                const SizedBox(height: 28),

                // Companions
                if (plant.companions.isNotEmpty) ...[
                  SectionLabel(label: 'Companion Plants'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: plant.companions
                        .map((c) => OGTag(label: c))
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(emoji: '☀️', label: plant.sunRequirement),
        const SizedBox(width: 10),
        _StatPill(emoji: '💧', label: plant.waterNeeds),
        const SizedBox(width: 10),
        _StatPill(emoji: '📏', label: plant.matureHeight),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              label.length > 10 ? '${label.substring(0, 8)}…' : label,
              style: AppTypography.monoS(color: AppColors.warmGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stage carousel ────────────────────────────────────────
class _StageCarousel extends StatelessWidget {
  const _StageCarousel({
    required this.stages,
    required this.activeIndex,
    required this.onChanged,
  });
  final List<PlantStage> stages;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final stage    = stages[i];
          final isActive = i == activeIndex;

          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color: isActive ? (isDark ? AppColors.fern : AppColors.ink) : (isDark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(
                  color: isActive ? AppColors.leaf : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.leaf.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  // Emoji area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isActive
                              ? [AppColors.fern, AppColors.moss]
                              : [AppColors.moss.withOpacity(0.5),
                                 AppColors.fern.withOpacity(0.5)],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusSM - 1),
                        ),
                      ),
                      child: Center(
                        child: Text(stage.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                  // Label
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: Column(
                      children: [
                        Text(
                          stage.name,
                          style: AppTypography.monoS(color: isActive ? AppColors.cream : (isDark ? AppColors.cream : AppColors.ink))
                              .copyWith(fontSize: 9, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          stage.weekRange,
                          style: AppTypography.monoS(color: isActive ? AppColors.cream : (isDark ? AppColors.cream : AppColors.ink))
                              .copyWith(fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Stage description card ────────────────────────────────
class _StageDescription extends StatelessWidget {
  const _StageDescription({super.key, required this.stage});
  final PlantStage stage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stage.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.name,
                  style: AppTypography.labelM(color: isDark ? AppColors.cream : AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.description,
                  style: AppTypography.bodyS(color: isDark ? AppColors.cream : AppColors.ink)
                      .copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zone calendar bar ─────────────────────────────────────
class _ZoneCalendarBar extends StatelessWidget {
  const _ZoneCalendarBar({required this.calendar});
  final PlantCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          _CalBarRow(
            label: 'Indoor Start',
            value: calendar.indoorStart,
            color: AppColors.leaf,
            startFraction: 0.0,
            widthFraction: 0.30,
          ),
          const SizedBox(height: 8),
          _CalBarRow(
            label: 'Transplant',
            value: calendar.transplant,
            color: AppColors.sprout,
            startFraction: 0.30,
            widthFraction: 0.25,
          ),
          const SizedBox(height: 8),
          _CalBarRow(
            label: 'Harvest',
            value: calendar.harvest,
            color: AppColors.terracotta,
            startFraction: 0.50,
            widthFraction: 0.40,
          ),
        ],
      ),
    );
  }
}

class _CalBarRow extends StatelessWidget {
  const _CalBarRow({
    required this.label,
    required this.value,
    required this.color,
    required this.startFraction,
    required this.widthFraction,
  });
  final String label;
  final String value;
  final Color color;
  final double startFraction;
  final double widthFraction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.monoS(color: isDark ? AppColors.cream : AppColors.ink)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 9)),
              Text(value, style: AppTypography.monoS()
                  .copyWith(fontSize: 8.5)),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final trackWidth = constraints.maxWidth;
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.mist,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Fill
                  Positioned(
                    left: trackWidth * startFraction,
                    child: Container(
                      height: 8,
                      width: trackWidth * widthFraction,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────
class _PlantDetailSkeleton extends StatelessWidget {
  const _PlantDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColors.soil
        : AppColors.parchment,
      body: Column(
        children: [
          Container(
            height: 220,
            color: AppColors.fern.withOpacity(0.4),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 28),
                const SizedBox(height: 8),
                SkeletonBox(width: 120, height: 14),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: SkeletonBox(width: double.infinity, height: 70)),
                    const SizedBox(width: 10),
                    Expanded(child: SkeletonBox(width: double.infinity, height: 70)),
                    const SizedBox(width: 10),
                    Expanded(child: SkeletonBox(width: double.infinity, height: 70)),
                  ],
                ),
                const SizedBox(height: 24),
                SkeletonBox(width: double.infinity, height: 100, radius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VarietiesTabs extends StatefulWidget {
  const _VarietiesTabs({required this.varieties});
  final List<PlantVariety> varieties;

  @override
  State<_VarietiesTabs> createState() => _VarietiesTabsState();
}

class _VarietiesTabsState extends State<_VarietiesTabs> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chip row
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.varieties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = i == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.terracotta
                        : (isDark
                            ? AppColors.surfaceDark
                            : Colors.white),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: selected
                          ? AppColors.terracotta
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                    ),
                  ),
                  child: Text(
                    widget.varieties[i].name,
                    style: AppTypography.monoS(
                      color: selected
                          ? Colors.white
                          : AppColors.warmGray,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Selected variety detail card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(_selected),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.varieties[_selected].name,
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                if (widget.varieties[_selected].daysToMaturity != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⏱ ${widget.varieties[_selected].daysToMaturity}',
                    style: AppTypography.monoS(color: AppColors.terracotta),
                  ),
                ],
                if (widget.varieties[_selected].description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.varieties[_selected].description!,
                    style: AppTypography.bodyS(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cream,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2E2E2A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTabs extends StatefulWidget {
  const _InfoTabs({required this.plant});
  final Plant plant;

  @override
  State<_InfoTabs> createState() => _InfoTabsState();
}

class _InfoTabsState extends State<_InfoTabs> {
  int? _selected;

  static const _tabs = [
    {'emoji': '💧', 'label': 'Watering'},
    {'emoji': '🪱', 'label': 'Soil'},
    {'emoji': '🐛', 'label': 'Pests'},
    {'emoji': '🌾', 'label': 'Harvest'},
  ];

  String? _contentFor(int index) {
    switch (index) {
      case 0: return widget.plant.wateringTips;
      case 1: return widget.plant.soilRequirements;
      case 2: return widget.plant.pestsDiseases;
      case 3: return widget.plant.harvestingTips;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab row
        Row(
          children: List.generate(_tabs.length, (i) {
            final isSelected = _selected == i;
            final hasData = _contentFor(i) != null;
            return Expanded(
              child: GestureDetector(
                onTap: hasData
                    ? () => setState(() =>
                        _selected = _selected == i ? null : i)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.terracotta
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isSelected
                            ? AppColors.terracotta
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _tabs[i]['emoji']!,
                        style: TextStyle(
                          fontSize: 20,
                          color: hasData ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tabs[i]['label']!,
                        style: AppTypography.monoS(
                          color: isSelected
                              ? Colors.white
                              : (hasData
                                  ? (isDark ? AppColors.cream : AppColors.ink)
                                  : AppColors.warmGray),
                        ).copyWith(fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        // Content panel
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selected != null && _contentFor(_selected!) != null
              ? Container(
                  key: ValueKey(_selected),
                  margin: const EdgeInsets.only(top: 12),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.cream,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    _contentFor(_selected!)!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.cream : const Color(0xFF2E2E2A),
                      height: 1.6,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}
