import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';

class GardenPlanScreen extends ConsumerStatefulWidget {
  const GardenPlanScreen({
    super.key,
    required this.gardenId,
    required this.gardenName,
  });
  final String gardenId;
  final String gardenName;

  @override
  ConsumerState<GardenPlanScreen> createState() => _GardenPlanScreenState();
}

class _GardenPlanScreenState extends ConsumerState<GardenPlanScreen> {
  final _widthCtrl  = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _client     = Supabase.instance.client;

  List<Map<String, dynamic>> _gardenPlants = [];
  Set<String> _selectedPlantIds            = {};
  Map<String, int> _quantities                = {};
  Map<String, dynamic>? _plan;
  bool _loading     = false;
  bool _generating  = false;
  bool _saving      = false;
  bool _autoSaving  = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _widthCtrl.dispose();
    _lengthCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Load garden dimensions + existing plan
      final garden = await _client
          .from('gardens')
          .select('bed_width_ft, bed_length_ft, layout_plan')
          .eq('id', widget.gardenId)
          .single();

      if (garden['bed_width_ft'] != null) {
        _widthCtrl.text  = garden['bed_width_ft'].toString();
        _lengthCtrl.text = garden['bed_length_ft'].toString();
      }
      if (garden['layout_plan'] != null) {
        _plan = Map<String, dynamic>.from(garden['layout_plan']);
      }

      // Load plants in this garden
      final plants = await _client
          .from('garden_plants')
          .select('id, plant_id, custom_name, plants(common_name, emoji, mature_height, companions)')
          .eq('garden_id', widget.gardenId);

      setState(() {
        _gardenPlants     = List<Map<String, dynamic>>.from(plants);
        _selectedPlantIds = _gardenPlants.map((p) => p['plant_id'] as String).toSet();
        _quantities = {
          for (final p in _gardenPlants)
            p['plant_id'] as String: 1
        };
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _generatePlan() async {
    final width  = double.tryParse(_widthCtrl.text.trim());
    final length = double.tryParse(_lengthCtrl.text.trim());

    if (width == null || length == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid bed dimensions')),
      );
      return;
    }

    if (_selectedPlantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one plant')),
      );
      return;
    }

    setState(() => _generating = true);

    try {
      // Save dimensions
      await _client.from('gardens').update({
        'bed_width_ft':  width,
        'bed_length_ft': length,
      }).eq('id', widget.gardenId);

      // Fetch full plant data for selected plants
      final selectedPlants = _gardenPlants
          .where((p) => _selectedPlantIds.contains(p['plant_id']))
          .toList();

      final plantIds = selectedPlants.map((p) => p['plant_id']).toList();

      final plantData = await _client
          .from('plants')
          .select('id, common_name, emoji, mature_height, companions, pests_diseases, watering_tips, soil_requirements')
          .inFilter('id', plantIds);

      final plantMap = <String, Map<String, dynamic>>{};
      for (final p in (plantData as List)) {
        plantMap[p['id'] as String] = Map<String, dynamic>.from(p);
      }

      // ── Build grid ────────────────────────────────────
      // Each cell = ~1 sq ft. Grid cols = width, rows = length
      final cols = width.round().clamp(1, 20);
      final rows = length.round().clamp(1, 20);

      // Spacing rules (ft) — rough defaults by height keyword
      int _spacingCells(Map<String, dynamic> plant) {
        final height = (plant['mature_height'] as String? ?? '').toLowerCase();
        if (height.contains('tall') || height.contains('6') || height.contains('5')) return 2;
        if (height.contains('medium') || height.contains('3') || height.contains('4')) return 2;
        return 1;
      }

      // Sort: tall plants first (go to back/top of grid)
      final sorted = selectedPlants.toList()
        ..sort((a, b) {
          final pa = plantMap[a['plant_id']] ?? {};
          final pb = plantMap[b['plant_id']] ?? {};
          final ha = (pa['mature_height'] as String? ?? '');
          final hb = (pb['mature_height'] as String? ?? '');
          return hb.compareTo(ha);
        });

      final gridEmoji  = List.generate(rows, (_) => List.filled(cols, ''));
      final gridLabels = List.generate(rows, (_) => List.filled(cols, ''));

      for (final item in sorted) {
        final plant   = plantMap[item['plant_id']] ?? {};
        final emoji   = plant['emoji'] as String? ?? '🌱';
        final name    = (item['custom_name'] as String?) ?? (plant['common_name'] as String? ?? '');
        final spacing = _spacingCells(plant);
        final quantity = _quantities[item['plant_id'] as String] ?? 1;

        int placed = 0;
        for (int r = 0; r < rows && placed < quantity; r += spacing) {
          for (int c = 0; c < cols && placed < quantity; c += spacing) {
            if (gridEmoji[r][c].isEmpty) {
              gridEmoji[r][c]  = emoji;
              gridLabels[r][c] = name;
              placed++;
            }
          }
        }
      }

      // ── Spacing guide ─────────────────────────────────
      final spacingGuide = <Map<String, String>>[];
      for (final item in sorted) {
        final plant   = plantMap[item['plant_id']] ?? {};
        final name    = (item['custom_name'] as String?) ?? (plant['common_name'] as String? ?? '');
        final emoji   = plant['emoji'] as String? ?? '🌱';
        final height  = (plant['mature_height'] as String? ?? 'Varies');
        final spacing = _spacingCells(plant);
        spacingGuide.add({
          'plant':   '$emoji $name',
          'spacing': '${spacing * 12} inches apart',
          'rows':    '${spacing * 18} inches between rows',
          'height':  height,
        });
      }

      // ── Watch for ─────────────────────────────────────
      final watchFor = <Map<String, String>>[];
      for (final item in sorted) {
        final plant = plantMap[item['plant_id']] ?? {};
        final name  = (item['custom_name'] as String?) ??
                      (plant['common_name'] as String? ?? '');
        final emoji = plant['emoji'] as String? ?? '🌱';
        final pests = plant['pests_diseases'] as String?;
        if (pests != null && pests.isNotEmpty) {
          // Split on periods or newlines to get individual issues
          final issues = pests
              .split(RegExp(r'[.\n]'))
              .map((s) => s.trim())
              .where((s) => s.length > 10)
              .take(2)
              .toList();
          for (final issue in issues) {
            watchFor.add({
              'issue':   issue,
              'affects': '$emoji $name',
              'signs':   'Monitor regularly',
            });
          }
        }
      }

      // ── Companion notes ───────────────────────────────
      final companionNotes = <String>[];
      final allNames = sorted.map((item) {
        final plant = plantMap[item['plant_id']] ?? {};
        return (plant['common_name'] as String? ?? '').toLowerCase();
      }).toSet();

      for (final item in sorted) {
        final plant      = plantMap[item['plant_id']] ?? {};
        final name       = plant['common_name'] as String? ?? '';
        final companions = List<String>.from(plant['companions'] ?? []);
        final matches    = companions
            .where((c) => allNames.contains(c.toLowerCase()))
            .toList();
        if (matches.isNotEmpty) {
          companionNotes.add(
            '$name pairs well with ${matches.join(', ')} — keep them adjacent.',
          );
        }
      }

      // ── Preventative care ─────────────────────────────
      final preventative = <Map<String, String>>[
        {
          'action':  'Plant marigolds around perimeter',
          'benefit': 'Natural pest deterrent for aphids and whiteflies',
        },
        {
          'action':  'Mulch 2–3 inches around all plants',
          'benefit': 'Retains moisture, prevents soil splash and fungal issues',
        },
        {
          'action':  'Water at the base, not on leaves',
          'benefit': 'Reduces risk of blight and fungal disease',
        },
        {
          'action':  'Check undersides of leaves weekly',
          'benefit': 'Early detection of aphids, mites, and eggs',
        },
      ];

      // Add soil-specific tips from plant data
      for (final item in sorted.take(2)) {
        final plant    = plantMap[item['plant_id']] ?? {};
        final soilTip  = plant['soil_requirements'] as String?;
        final name     = plant['common_name'] as String? ?? '';
        if (soilTip != null && soilTip.isNotEmpty) {
          preventative.add({
            'action':  'Soil prep for $name',
            'benefit': soilTip.split('.').first.trim(),
          });
        }
      }

      final rationale = companionNotes.isNotEmpty
          ? 'Tall plants are placed toward the north to avoid shading shorter plants. ${companionNotes.join(' ')} Bed size: ${width}ft × ${length}ft (${(width * length).round()} sq ft).'
          : 'Tall plants are placed toward the north to avoid shading shorter plants. Plants are spaced based on their mature size. Bed size: ${width}ft × ${length}ft (${(width * length).round()} sq ft).';

      setState(() => _plan = {
        'grid':              gridEmoji,
        'grid_labels':       gridLabels,
        'layout_rationale':  rationale,
        'spacing_guide':     spacingGuide,
        'watch_for':         watchFor,
        'preventative_care': preventative,
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating plan: $e')),
        );
      }
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _savePlan() async {
    if (_plan == null) return;
    setState(() => _saving = true);
    try {
      await _client.from('gardens').update({
        'layout_plan': _plan,
      }).eq('id', widget.gardenId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Plan saved!')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _autoSavePlan(Map<String, dynamic> updatedPlan) async {
    if (_autoSaving) return; // Prevent concurrent saves
    
    setState(() {
      _plan = updatedPlan;
      _autoSaving = true;
    });

    try {
      await _client.from('gardens').update({
        'layout_plan': updatedPlan,
      }).eq('id', widget.gardenId);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layout saved automatically'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auto-save failed: $e')),
        );
      }
    } finally {
      setState(() => _autoSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // ── Dimensions ────────────────────────────────
        SectionLabel(label: 'Bed Dimensions'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OGTextField(
                controller: _widthCtrl,
                hint: 'Width (ft)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Text('×', style: AppTypography.displayM(
              color: isDark ? AppColors.cream : AppColors.ink,
            )),
            const SizedBox(width: 12),
            Expanded(
              child: OGTextField(
                controller: _lengthCtrl,
                hint: 'Length (ft)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Plant selection ───────────────────────────
        SectionLabel(label: 'Plants to Include'),
        const SizedBox(height: 10),
        if (_gardenPlants.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Text(
              'Add plants to your garden first',
              style: AppTypography.bodyS(color: AppColors.warmGray),
            ),
          )
        else
          ..._gardenPlants.map((item) {
            final plant     = item['plants'] as Map<String, dynamic>;
            final plantId   = item['plant_id'] as String;
            final name      = item['custom_name'] ?? plant['common_name'];
            final emoji     = plant['emoji'] ?? '🌱';
            final selected  = _selectedPlantIds.contains(plantId);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.fern.withOpacity(0.15)
                    : (isDark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: selected
                      ? AppColors.leaf
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedPlantIds.remove(plantId);
                      } else {
                        _selectedPlantIds.add(plantId);
                      }
                    }),
                    child: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? AppColors.leaf : AppColors.warmGray,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.labelM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                    ),
                  ),
                  // Quantity stepper
                  if (selected) ...[
                    GestureDetector(
                      onTap: () => setState(() {
                        final current = _quantities[plantId] ?? 1;
                        if (current > 1) _quantities[plantId] = current - 1;
                      }),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.fern.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.remove, size: 14, color: AppColors.leaf),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_quantities[plantId] ?? 1}',
                      style: AppTypography.labelM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        final current = _quantities[plantId] ?? 1;
                        _quantities[plantId] = current + 1;
                      }),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.fern.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add, size: 14, color: AppColors.leaf),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 24),

        // ── Generate button ───────────────────────────
        OGButton(
          label: _plan != null ? '🔄 Regenerate Plan' : '✨ Generate Plan',
          onPressed: _generating ? null : _generatePlan,
          isLoading: _generating,
        ),

        if (_generating) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Claude is planning your garden...',
              style: AppTypography.bodyS(color: AppColors.warmGray),
            ),
          ),
        ],

        // ── Plan output ───────────────────────────────
        if (_plan != null) ...[
          const SizedBox(height: 32),

          // Save button
          OGButton(
            label: '💾 Save Plan',
            onPressed: _saving ? null : _savePlan,
            isLoading: _saving,
          ),
          const SizedBox(height: 24),

          // Grid
          SectionLabel(label: 'Layout Grid (Drag & Drop)'),
          const SizedBox(height: 10),
          _DragDropGardenGrid(
            plan: _plan!,
            isDark: isDark,
            onLayoutChanged: _autoSavePlan,
          ),
          const SizedBox(height: 24),

          // Layout rationale
          if (_plan!['layout_rationale'] != null) ...[
            SectionLabel(label: 'Layout Rationale'),
            const SizedBox(height: 10),
            _PlanCard(
              content: _plan!['layout_rationale'] as String,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],

          // Spacing guide
          if (_plan!['spacing_guide'] != null) ...[
            SectionLabel(label: 'Spacing Guide'),
            const SizedBox(height: 10),
            ...(_plan!['spacing_guide'] as List).map((s) =>
              _SpacingRow(item: Map<String, dynamic>.from(s), isDark: isDark),
            ),
            const SizedBox(height: 24),
          ],

          // Watch for
          if (_plan!['watch_for'] != null) ...[
            SectionLabel(label: '👀 Watch For'),
            const SizedBox(height: 10),
            ...(_plan!['watch_for'] as List).map((w) =>
              _WatchForCard(item: Map<String, dynamic>.from(w), isDark: isDark),
            ),
            const SizedBox(height: 24),
          ],

          // Preventative care
          if (_plan!['preventative_care'] != null) ...[
            SectionLabel(label: '🛡️ Preventative Care'),
            const SizedBox(height: 10),
            ...(_plan!['preventative_care'] as List).map((p) =>
              _PreventativeCard(item: Map<String, dynamic>.from(p), isDark: isDark),
            ),
            const SizedBox(height: 24),
          ],
        ],

        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Drag & Drop Grid widget ────────────────────────────────────
class _DragDropGardenGrid extends StatefulWidget {
  const _DragDropGardenGrid({
    required this.plan,
    required this.isDark,
    required this.onLayoutChanged,
  });
  final Map<String, dynamic> plan;
  final bool isDark;
  final Function(Map<String, dynamic>) onLayoutChanged;

  @override
  State<_DragDropGardenGrid> createState() => _DragDropGardenGridState();
}

class _DragDropGardenGridState extends State<_DragDropGardenGrid> {
  late List<List<String>> _grid;
  late List<List<String>> _gridLabels;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  @override
  void didUpdateWidget(_DragDropGardenGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) _initializeGrid();
  }

  void _initializeGrid() {
    final raw       = widget.plan['grid'] as List?;
    final rawLabels = widget.plan['grid_labels'] as List?;
    if (raw == null || raw.isEmpty) {
      _grid       = [];
      _gridLabels = [];
      return;
    }
    _grid = List.generate(
      raw.length,
      (i) => List<String>.from(raw[i] as List),
    );
    _gridLabels = List.generate(
      raw.length,
      (i) => rawLabels != null
          ? List<String>.from(rawLabels[i] as List)
          : List.filled((raw[i] as List).length, ''),
    );
  }

  int get _cols => _grid.isEmpty ? 0 : _grid[0].length;

  void _swap(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    final fromRow = fromIndex ~/ _cols;
    final fromCol = fromIndex % _cols;
    final toRow   = toIndex ~/ _cols;
    final toCol   = toIndex % _cols;

    setState(() {
      final tempEmoji = _grid[toRow][toCol];
      final tempLabel = _gridLabels[toRow][toCol];
      _grid[toRow][toCol]       = _grid[fromRow][fromCol];
      _gridLabels[toRow][toCol] = _gridLabels[fromRow][fromCol];
      _grid[fromRow][fromCol]       = tempEmoji;
      _gridLabels[fromRow][fromCol] = tempLabel;
    });

    final updated = Map<String, dynamic>.from(widget.plan);
    updated['grid']        = _grid;
    updated['grid_labels'] = _gridLabels;
    widget.onLayoutChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_grid.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth - 48; // 24 container padding × 2
      final cellSize = (availableWidth / _cols).clamp(28.0, 52.0);
      
      return Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⬆ North  •  long-press a plant to drag it',
                style: AppTypography.monoS(color: AppColors.warmGray)
                    .copyWith(fontSize: 9),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Grid rows
              ...List.generate(_grid.length, (row) {
                return SizedBox(
                  width: (_cols * (cellSize + 4)), // cellSize + margin*2 per cell
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_cols, (col) {
                      final emoji    = _grid[row][col];
                      final label    = _gridLabels[row][col];
                      final index    = row * _cols + col;
                      final hasPlant = emoji.isNotEmpty;
                      final hovered  = _hoveredIndex == index;

                      return SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: DragTarget<int>(
                          onWillAcceptWithDetails: (details) => details.data != index,
                          onAcceptWithDetails: (details) {
                            setState(() => _hoveredIndex = null);
                            _swap(details.data, index);
                          },
                          onMove: (details) {
                            if (_hoveredIndex != index) {
                              setState(() => _hoveredIndex = index);
                            }
                          },
                          onLeave: (_) {
                            if (_hoveredIndex == index) {
                              setState(() => _hoveredIndex = null);
                            }
                          },
                          builder: (context, candidateData, _) {
                            final isTarget = candidateData.isNotEmpty || hovered;

                            final cell = Container(
                              width:  cellSize,
                              height: cellSize,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isTarget
                                    ? AppColors.fern.withOpacity(0.35)
                                    : hasPlant
                                        ? AppColors.fern.withOpacity(0.12)
                                        : (widget.isDark
                                            ? AppColors.soil
                                            : AppColors.parchment),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isTarget
                                      ? AppColors.leaf
                                      : (widget.isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                                  width: isTarget ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: hasPlant
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            emoji,
                                            style: TextStyle(
                                              fontSize: (cellSize * 0.4).clamp(14.0, 24.0),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (label.isNotEmpty && cellSize > 40)
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: (cellSize * 0.12).clamp(6.0, 9.0),
                                                color: AppColors.warmGray,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      )
                                    : Text(
                                        '·',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: widget.isDark
                                              ? AppColors.warmGray.withOpacity(0.4)
                                              : AppColors.borderLight,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            );

                            if (!hasPlant) return cell;

                            return LongPressDraggable<int>(
                              data: index,
                              hapticFeedbackOnStart: true,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width:  cellSize + 8,
                                  height: cellSize + 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.fern.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          emoji,
                                          style: TextStyle(
                                            fontSize: (cellSize * 0.45).clamp(16.0, 28.0),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (label.isNotEmpty)
                                          Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(
                                width:  cellSize,
                                height: cellSize,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.fern.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.leaf.withOpacity(0.4),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: TextStyle(
                                      fontSize: (cellSize * 0.4).clamp(14.0, 24.0),
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              child: cell,
                            );
                          },
                        ),
                      );
                    }),
                  ),
                );
              }),

              const SizedBox(height: 4),
              Text(
                '⬇ South',
                style: AppTypography.monoS(color: AppColors.warmGray)
                    .copyWith(fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Supporting cards ──────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.content, required this.isDark});
  final String content;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 13,
          height: 1.6,
          color: isDark ? AppColors.cream : const Color(0xFF2E2E2A),
        ),
      ),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.item, required this.isDark});
  final Map<String, dynamic> item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['plant'] ?? '',
            style: AppTypography.labelM(
              color: isDark ? AppColors.cream : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '↔ ${item['spacing'] ?? ''}  •  ↕ ${item['rows'] ?? ''}',
            style: AppTypography.monoS(color: AppColors.warmGray)
                .copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WatchForCard extends StatelessWidget {
  const _WatchForCard({required this.item, required this.isDark});
  final Map<String, dynamic> item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.rust.withOpacity(0.1)
            : AppColors.rust.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppColors.rust.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ ${item['issue'] ?? ''}',
            style: AppTypography.labelM(color: AppColors.rust),
          ),
          const SizedBox(height: 4),
          Text(
            item['affects'] ?? '',
            style: AppTypography.monoS(color: AppColors.warmGray)
                .copyWith(fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            item['signs'] ?? '',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? AppColors.cream : const Color(0xFF2E2E2A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreventativeCard extends StatelessWidget {
  const _PreventativeCard({required this.item, required this.isDark});
  final Map<String, dynamic> item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.leaf.withOpacity(0.1)
            : AppColors.leaf.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppColors.leaf.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ ${item['action'] ?? ''}',
            style: AppTypography.labelM(
              color: isDark ? AppColors.sprout : AppColors.moss,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['benefit'] ?? '',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? AppColors.cream : const Color(0xFF2E2E2A),
            ),
          ),
        ],
      ),
    );
  }
}
