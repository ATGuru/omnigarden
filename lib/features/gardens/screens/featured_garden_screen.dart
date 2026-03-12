import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../models/featured_garden.dart';

class FeaturedGardenScreen extends ConsumerWidget {
  const FeaturedGardenScreen({super.key, required this.garden});
  final FeaturedGarden garden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverColor = _parseColor(garden.coverColor);

    return Scaffold(
      backgroundColor: isDark ? AppColors.soil : AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: coverColor,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: BackButton(color: AppColors.cream),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      coverColor,
                      coverColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(garden.emoji,
                            style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(
                          garden.name,
                          style:
                              AppTypography.displayM(color: AppColors.cream),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${garden.ownerName}',
                          style: AppTypography.bodyS(color: AppColors.cream)
                              .copyWith(color: AppColors.cream.withOpacity(0.8)),
                        ),
                        if (garden.location != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '📍 ${garden.location}',
                            style: AppTypography.monoS(color: AppColors.cream)
                                .copyWith(
                                    fontSize: 10,
                                    color:
                                        AppColors.cream.withOpacity(0.7)),
                          ),
                        ],
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
                  color: isDark ? AppColors.soil : AppColors.parchment,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Description
                if (garden.description != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Text(
                      garden.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF2E2E2A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Plants
                if (garden.plants.isNotEmpty) ...[
                  SectionLabel(label: "What's Growing"),
                  const SizedBox(height: 14),
                  ...garden.plants.map((fp) => GestureDetector(
                        onTap: () => context.push('/plant/${fp.plantId}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.fern.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSM),
                                ),
                                child: Center(
                                  child: Text(fp.emoji,
                                      style: const TextStyle(
                                          fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fp.commonName,
                                      style: AppTypography.labelM(
                                        color: isDark
                                            ? AppColors.cream
                                            : AppColors.ink,
                                      ),
                                    ),
                                    if (fp.note != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        fp.note!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          color: Color(0xFF8A8580),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.warmGray, size: 18),
                            ],
                          ),
                        ),
                      )),
                ],
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.bark;
    }
  }
}
