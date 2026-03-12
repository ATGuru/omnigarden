import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../utils/export_service.dart';

class ExportCalendarScreen extends ConsumerStatefulWidget {
  const ExportCalendarScreen({super.key});

  @override
  ConsumerState<ExportCalendarScreen> createState() => _ExportCalendarScreenState();
}

class _ExportCalendarScreenState extends ConsumerState<ExportCalendarScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final auth = ref.read(authStateNotifierProvider).value;
      final zone = auth?.zone ?? 'Zone 6a';
      final location = auth?.location ?? zone;

      // Fetch all garden plants with their calendar data
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final gardens = await Supabase.instance.client
          .from('gardens').select('id').eq('user_id', userId!);
      final gardenIds = (gardens as List).map((g) => g['id']).toList();

      final plantRows = gardenIds.isEmpty ? [] : await Supabase.instance.client
          .from('garden_plants')
          .select('plant_id, plants(common_name, emoji, plant_calendar(*))')
          .inFilter('garden_id', gardenIds);

      final plants = (plantRows as List).map((row) {
        final plant = row['plants'] as Map<String, dynamic>? ?? {};
        final calendars = plant['plant_calendar'] as List? ?? [];
        final calendar = calendars.isNotEmpty
            ? calendars.firstWhere((c) => c['zone'] == zone, orElse: () => calendars.first)
            : {};
        return {
          'common_name': plant['common_name'] ?? '',
          'emoji': plant['emoji'] ?? '🌱',
          'calendar': calendar,
        };
      }).toList();

      await ExportService().exportCalendarPdf(
        zone: zone,
        location: location,
        plants: List<Map<String, dynamic>>.from(plants),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        title: Text('Export Calendar', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planting Calendar PDF', style: AppTypography.sectionTitle()),
            const SizedBox(height: 12),
            Text(
              'Exports a full planting calendar for all plants in your gardens, showing indoor start, transplant, and harvest windows by month.',
              style: AppTypography.bodyM(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _exporting
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                label: Text(_exporting ? 'Generating...' : 'Export as PDF',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _exporting ? null : _export,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
