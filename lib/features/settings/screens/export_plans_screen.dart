import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/gardens/providers/garden_provider.dart';
import '../utils/export_service.dart';

class ExportPlansScreen extends ConsumerWidget {
  const ExportPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardensAsync = ref.watch(gardenNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        title: Text('Export Garden Plans', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: gardensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (gardens) => gardens.isEmpty
          ? Center(child: Text('No gardens yet.', style: AppTypography.bodyM()))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: gardens.length,
              itemBuilder: (_, i) {
                final garden = gardens[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: ListTile(
                    leading: Text(garden.emoji, style: const TextStyle(fontSize: 28)),
                    title: Text(garden.name, style: AppTypography.labelM(color: AppColors.cream)),
                    subtitle: Text(garden.location ?? garden.zone ?? '', style: AppTypography.bodyS()),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.terracotta),
                      onPressed: () async {
                        try {
                          final result = await Supabase.instance.client
                              .from('gardens')
                              .select('layout_plan, bed_width_ft, bed_length_ft')
                              .eq('id', garden.id)
                              .single();

                          final layout = result['layout_plan'] as Map<String, dynamic>? ?? {};
                          final emojiGrid = (layout['grid'] as List? ?? [])
                              .map((row) => List<String>.from(row as List))
                              .toList();
                          final labelGrid = (layout['grid_labels'] as List? ?? [])
                              .map((row) => List<String>.from(row as List))
                              .toList();
                          final rows = emojiGrid.length;
                          final cols = rows > 0 ? emojiGrid[0].length : 0;

                          if (rows == 0 || cols == 0) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No layout plan saved for this garden.')),
                            );
                            return;
                          }

                          await ExportService().exportGardenPlanPdf(
                            gardenName: garden.name,
                            emojiGrid: emojiGrid,
                            labelGrid: labelGrid,
                            rows: rows,
                            cols: cols,
                          );
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
