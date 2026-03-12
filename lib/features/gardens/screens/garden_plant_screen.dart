import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../../shared/utils/storage_service.dart';
import '../../plants/models/plant.dart';
import '../../plants/providers/plant_providers.dart';

final _client = Supabase.instance.client;

// Fetch garden_plant record (personal instance)
final gardenPlantInstanceProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, gardenPlantId) async {
  final res = await _client
      .from('garden_plants')
      .select()
      .eq('id', gardenPlantId)
      .single();
  return res;
});

class GardenPlantScreen extends ConsumerStatefulWidget {
  const GardenPlantScreen({
    super.key,
    required this.gardenPlantId,
    required this.plantId,
    required this.gardenName,
  });
  final String gardenPlantId;
  final String plantId;
  final String gardenName;

  @override
  ConsumerState<GardenPlantScreen> createState() => _GardenPlantScreenState();
}

class _GardenPlantScreenState extends ConsumerState<GardenPlantScreen> {
  final _notesCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  DateTime? _plantedDate;
  String _status = 'planning';
  List<String> _photoUrls = [];
  bool _saving = false;
  bool _loaded = false;
  final _picker = ImagePicker();

  static const _statuses = [
  {'value': 'planning',   'emoji': '📋', 'label': 'Planning'},
  {'value': 'started',    'emoji': '🌱', 'label': 'Started'},
  {'value': 'growing',    'emoji': '🌿', 'label': 'Growing'},
  {'value': 'flowering',  'emoji': '🌸', 'label': 'Flowering'},
  {'value': 'harvesting', 'emoji': '🌾', 'label': 'Harvesting'},
  {'value': 'done',       'emoji': '✅', 'label': 'Done'},
];

  @override
  void dispose() {
    _notesCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _loadInstance(Map<String, dynamic> data) {
    if (_loaded) return;
    _loaded = true;
    _notesCtrl.text = data['notes'] ?? '';
    _nameCtrl.text  = data['custom_name'] ?? '';
    _status         = data['status'] ?? 'planning';
    _photoUrls      = List<String>.from(data['photo_urls'] ?? []);
    if (data['planted_date'] != null) {
      _plantedDate = DateTime.tryParse(data['planted_date']);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _client.from('garden_plants').update({
        'notes':       _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'custom_name': _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        'status':      _status,
        'planted_date': _plantedDate?.toIso8601String().split('T').first,
        'photo_urls':  _photoUrls,
      }).eq('id', widget.gardenPlantId);

      ref.invalidate(gardenPlantInstanceProvider(widget.gardenPlantId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _saving = false);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('📷', style: TextStyle(fontSize: 22)),
              title: Text('Take a photo', style: AppTypography.bodyM()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Text('🖼️', style: TextStyle(fontSize: 22)),
              title: Text('Choose from gallery', style: AppTypography.bodyM()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      final url = await ref.read(storageServiceProvider).uploadJournalPhoto(
        file: File(picked.path),
        gardenId: widget.gardenPlantId,
      );
      setState(() => _photoUrls.add(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantAsync    = ref.watch(plantProvider(widget.plantId));
    final instanceAsync = ref.watch(gardenPlantInstanceProvider(widget.gardenPlantId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.soil : AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        leading: BackButton(color: AppColors.cream),
        title: plantAsync.maybeWhen(
          data: (plant) => Text(
            plant.commonName,
            style: AppTypography.displayM(color: AppColors.cream),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                : Text('Save',
                    style: AppTypography.labelM(color: AppColors.cream)),
          ),
        ],
      ),
      body: instanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => OGErrorState(message: e.toString()),
        data: (instance) {
          _loadInstance(instance);
          return plantAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => OGErrorState(message: e.toString()),
            data: (plant) => _buildBody(context, plant, isDark),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, Plant plant, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // Plant header
        Row(
          children: [
            Text(plant.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.commonName,
                    style: AppTypography.displayM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  Text(
                    'in ${widget.gardenName}',
                    style: AppTypography.bodyS(color: AppColors.warmGray),
                  ),
                ],
              ),
            ),
            // View encyclopedia entry
            GestureDetector(
              onTap: () => context.push('/plant/${plant.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.fern.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: AppColors.fern.withOpacity(0.3)),
                ),
                child: Text('📖 Info',
                    style: AppTypography.monoS(color: AppColors.leaf)
                        .copyWith(fontSize: 10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Status picker
        SectionLabel(label: 'Status'),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _statuses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _statuses[i];
              final value = s['value']!;
              final emoji = s['emoji']!;
              final label = s['label']!;
              final selected = _status == value;
              return GestureDetector(
                onTap: () => setState(() => _status = value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.terracotta
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: selected
                          ? AppColors.terracotta
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height:4),
                      Text(label,
                          style: AppTypography.monoS(
                            color: selected ? Colors.white : AppColors.warmGray,
                          ).copyWith(fontSize: 9),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Nickname
        SectionLabel(label: 'Nickname (optional)'),
        const SizedBox(height: 10),
        OGTextField(
          controller: _nameCtrl,
          hint: 'e.g. "Big Boy", "Front bed tomato"',
        ),
        const SizedBox(height: 24),

        // Planted date
        SectionLabel(label: 'Planted / Started Date'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _plantedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _plantedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  _plantedDate != null
                      ? '${_plantedDate!.month}/${_plantedDate!.day}/${_plantedDate!.year}'
                      : 'Tap to set date',
                  style: AppTypography.bodyM(
                    color: _plantedDate != null
                        ? (isDark ? AppColors.cream : AppColors.ink)
                        : AppColors.warmGray,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Notes
        SectionLabel(label: 'Notes'),
        const SizedBox(height: 10),
        TextField(
          controller: _notesCtrl,
          maxLines: 5,
          style: TextStyle(
            color: isDark ? AppColors.cream : AppColors.ink,
            fontSize: 13,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'How is it doing? Any issues? What worked?',
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Photos
        SectionLabel(label: 'Photos'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Add photo button
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📷', style: TextStyle(fontSize: 24)),
                    SizedBox(height:4),
                    Text('Add', style: TextStyle(fontSize: 10, color: AppColors.warmGray)),
                  ],
                ),
              ),
            ),
            // Existing photos
            ..._photoUrls.map((url) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: Image.network(
                    url,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _photoUrls.remove(url)),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.terracotta,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
        const SizedBox(height: 40),

        OGButton(
          label: 'Save Changes',
          onPressed: _saving ? null : _save,
          isLoading: _saving,
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
