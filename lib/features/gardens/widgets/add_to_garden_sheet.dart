import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../providers/garden_provider.dart';

class AddToGardenSheet extends ConsumerStatefulWidget {
  const AddToGardenSheet({super.key, required this.plantId});
  final String plantId;

  @override
  ConsumerState<AddToGardenSheet> createState() => _AddToGardenSheetState();
}

class _AddToGardenSheetState extends ConsumerState<AddToGardenSheet> {
  String? _selectedGardenId;
  bool _saving = false;

  Future<void> _save() async {
    if (_selectedGardenId == null) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('garden_plants').insert({
        'garden_id': _selectedGardenId,
        'plant_id': widget.plantId,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌿 Added! Check the Calendar tab for planting dates.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (e.toString().contains('23505')) {
        // already in garden — treat as success
        if (mounted) Navigator.pop(context);
        return;
      }
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gardensAsync = ref.watch(gardenNotifierProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 24, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to Garden', style: AppTypography.displayM()),
          const SizedBox(height: 6),
          Text(
            'Choose which garden to add this plant to.',
            style: AppTypography.bodyS(),
          ),
          const SizedBox(height: 20),

          gardensAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => OGErrorState(message: e.toString()),
            data: (gardens) => gardens.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text(
                          'No gardens yet.\nCreate one in the Gardens tab first.',
                          style: AppTypography.bodyS(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: gardens.map((g) {
                      final selected = _selectedGardenId == g.id;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedGardenId = g.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.terracotta.withOpacity(0.15)
                                : AppColors.surfaceDark,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: selected
                                  ? AppColors.terracotta
                                  : AppColors.borderDark,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(g.emoji,
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Text(
                                g.name,
                                style: AppTypography.labelM(
                                    color: AppColors.cream),
                              ),
                              const Spacer(),
                              if (selected)
                                const Icon(Icons.check_circle,
                                    color: AppColors.terracotta, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 20),
          OGButton(
            label: 'Add to Garden',
            onPressed: _selectedGardenId != null ? _save : null,
            isLoading: _saving,
          ),
        ],
      ),
    );
  }
}
