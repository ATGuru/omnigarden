import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../../shared/utils/moon_service.dart';

class GardenLunarScreen extends ConsumerStatefulWidget {
  const GardenLunarScreen({super.key, required this.gardenId});
  final String gardenId;

  @override
  ConsumerState<GardenLunarScreen> createState() => _GardenLunarScreenState();
}

class _GardenLunarScreenState extends ConsumerState<GardenLunarScreen> {
  late DateTime _selectedDate;
  late MoonPhase _selectedPhase;
  late List<Map<String, dynamic>> _calendar;

  @override
  void initState() {
    super.initState();
    _selectedDate  = DateTime.now();
    _selectedPhase = MoonService.forDate(_selectedDate);
    _calendar      = MoonService.next30Days();
  }

  void _selectDate(DateTime date, MoonPhase phase) {
    setState(() {
      _selectedDate  = date;
      _selectedPhase = phase;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today  = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // ── Today's phase hero ────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFF2C3E6B), const Color(0xFF1A2440)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          child: Column(
            children: [
              Text(
                _selectedPhase.emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedPhase.name,
                style: AppTypography.displayM(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedPhase.illumination.toStringAsFixed(0)}% illuminated',
                style: AppTypography.monoS(color: Colors.white70)
                    .copyWith(fontSize: 11),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _selectedPhase.recommendation,
                  style: AppTypography.labelM(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedPhase.recommendationDetail,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                style: AppTypography.monoS(color: Colors.white38)
                    .copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── 30-day calendar strip ─────────────────────
        SectionLabel(label: '30-Day Moon Calendar'),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _calendar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final item    = _calendar[i];
              final date    = item['date'] as DateTime;
              final phase   = item['phase'] as MoonPhase;
              final isToday = date.day   == today.day &&
                              date.month == today.month;
              final isSelected = date.day   == _selectedDate.day &&
                                 date.month == _selectedDate.month;

              return GestureDetector(
                onTap: () => _selectDate(date, phase),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : (isDark
                            ? AppColors.surfaceDark
                            : Colors.white),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isSelected
                            ? Colors.white54
                            : isToday
                                ? AppColors.terracotta
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                      width: isSelected || isToday ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(phase.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                        _monthAbbr(date.month),
                        style: AppTypography.monoS(
                                color: AppColors.warmGray)
                            .copyWith(fontSize: 8),
                      ),
                      Text(
                        '${date.day}',
                        style: AppTypography.monoS(
                          color: isToday
                              ? AppColors.terracotta
                              : (isDark
                                  ? AppColors.cream
                                  : AppColors.ink),
                        ).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // ── Best days this month ──────────────────────
        SectionLabel(label: 'Best Days This Month'),
        const SizedBox(height: 10),
        ..._buildBestDays(isDark),

        const SizedBox(height: 24),

        // ── What is Lunar Gardening? ─────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is Lunar Gardening?',
                style: AppTypography.displayM(
                  color: isDark ? AppColors.cream : AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lunar gardening is the practice of timing your planting, pruning, and harvesting with the phases of the moon. The gravitational pull of the moon affects moisture in soil much like it affects ocean tides. During a waxing moon, sap and moisture rise — ideal for planting above-ground crops. During a waning moon, energy moves downward into roots — ideal for root vegetables and pruning. Use the calendar above to plan your garden tasks around the moon\'s natural rhythm.',
                style: AppTypography.bodyM(
                  color: isDark ? AppColors.cream : AppColors.ink,
                ).copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  List<Widget> _buildBestDays(bool isDark) {
    // Group calendar by recommendation
    final groups = <String, List<DateTime>>{};
    for (final item in _calendar) {
      final phase = item['phase'] as MoonPhase;
      final date  = item['date'] as DateTime;
      groups.putIfAbsent(phase.recommendation, () => []).add(date);
    }

    return groups.entries.map((entry) {
      final dates = entry.value;
      final phase = MoonService.forDate(dates.first);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phase.emoji,
                  style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppTypography.labelM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height:4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: dates.map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.fern.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_monthAbbr(d.month)} ${d.day}',
                        style: AppTypography.monoS(
                                color: AppColors.leaf)
                            .copyWith(fontSize: 10),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _monthAbbr(int month) {
    const abbrs = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return abbrs[month];
  }
}
