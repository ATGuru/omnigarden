import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../../shared/utils/storage_service.dart';
import '../../../shared/utils/cache_provider.dart';
import '../../../shared/utils/cache_service.dart';
import '../models/garden.dart';
import '../providers/garden_provider.dart';
import 'garden_plan_screen.dart';
import 'garden_lunar_screen.dart';

final _gardenPlantsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, gardenId) async {
  final cache  = ref.read(cacheServiceProvider);
  final client = Supabase.instance.client;

  // Try cache
  final cached = cache.get<List>(CacheService.gardenPlantsKey(gardenId));
  if (cached != null) {
    return cached.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  final res = await client
      .from('garden_plants')
      .select('id, plant_id, status, planted_date, custom_name, plants(id, common_name, emoji, latin_name)')
      .eq('garden_id', gardenId);

  final list = List<Map<String, dynamic>>.from(res);

  // Cache it
  await cache.set(CacheService.gardenPlantsKey(gardenId), list);

  return list;
});

// ── Media Helper Functions ────────────────────────────────────────

Widget _buildMediaHeader(String url) {
  final isVideo = url.contains('.mp4') || url.contains('.mov') || 
                  url.contains('.avi') || url.contains('.video');
  if (isVideo) {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: AppColors.leaf, size: 64),
      ),
    );
  }
  return Image.network(
    url,
    width: double.infinity,
    height: 220,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: 220,
      color: AppColors.surfaceDark,
      child: const Center(child: Text('📷', style: TextStyle(fontSize: 40))),
    ),
  );
}

// ── Main Screen ────────────────────────────────────────────────────

class GardenDetailScreen extends ConsumerStatefulWidget {
  const GardenDetailScreen({super.key, required this.gardenId});
  final String gardenId;

  @override
  ConsumerState<GardenDetailScreen> createState() => _GardenDetailScreenState();
}

class _GardenDetailScreenState extends ConsumerState<GardenDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  Future<void> _refresh() async {
    ref.invalidate(journalEntriesProvider(widget.gardenId));
    ref.invalidate(gardenPlantIdsProvider(widget.gardenId));
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.soil : AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        leading: BackButton(color: AppColors.cream),
        title: Text('Garden', style: AppTypography.displayM(color: AppColors.cream)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.warmGray,
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.terracotta,
          labelColor: AppColors.cream,
          unselectedLabelColor: AppColors.warmGray,
          tabs: const [
            Tab(text: 'Plants'),
            Tab(text: 'Journal'),
            Tab(text: 'Plan'),
            Tab(text: '🌕 Lunar'),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (_, __) => _tabs.index >= 2
      ? const SizedBox.shrink()
      : FloatingActionButton(
          backgroundColor: AppColors.terracotta,
          child: Icon(
            _tabs.index == 0 ? Icons.search : Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            if (_tabs.index == 0) {
              context.push('/garden-plant-search');
            } else {
              _showAddEntrySheet();
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PlantsTab(gardenId: widget.gardenId, onRefresh: _refresh),
          _JournalTab(
            gardenId: widget.gardenId,
            onAddEntry: _showAddEntrySheet,
            onRefresh: _refresh,
          ),
          GardenPlanScreen(
            gardenId: widget.gardenId,
            gardenName: widget.gardenId,
          ),
          GardenLunarScreen(gardenId: widget.gardenId),
        ],
      ),
    );
  }

  void _showAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEntrySheet(gardenId: widget.gardenId, ref: ref),
    );
  }
}

// ── Plants Tab ────────────────────────────────────────────

class _PlantsTab extends ConsumerWidget {
  const _PlantsTab({required this.gardenId, required this.onRefresh});
  final String gardenId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(_gardenPlantsProvider(gardenId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return plantsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => OGErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(_gardenPlantsProvider(gardenId)),
      ),
      data: (plants) => plants.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('No plants yet',
                      style: AppTypography.displayM(color: AppColors.warmGray)),
                  const SizedBox(height: 8),
                  Text(
                    'Tap 🔍 to search and add plants\nto this garden.',
                    style: AppTypography.bodyS(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.terracotta,
              backgroundColor: AppColors.charcoal,
              onRefresh: () async => onRefresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: plants.length,
                itemBuilder: (_, i) {
                  final item  = plants[i];
                  final plant = item['plants'] as Map<String, dynamic>;
                  final status = item['status'] as String? ?? 'planning';
                  return GestureDetector(
                    onTap: () => context.push(
                      '/garden-plant/${item['id']}',
                      extra: {
                        'plantId': item['plant_id'] as String,
                        'gardenName': gardenId,
                      },
                    ),
                    onLongPress: () => _confirmRemove(context, ref, item['plant_id']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.fern.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            ),
                            child: Center(
                              child: Text(
                                plant['emoji'] ?? '🌱',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plant['common_name'],
                                  style: AppTypography.labelM(
                                    color: isDark ? AppColors.cream : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plant['latin_name'] ?? '',
                                  style: AppTypography.bodyS().copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (status != 'planning') ...[
                            Text(
                              _statusEmoji(status),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                          ],
                          const Icon(Icons.chevron_right,
                              color: AppColors.warmGray, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, String plantId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Remove plant?', style: AppTypography.sectionTitle()),
        content: Text('This removes it from the garden but not the database.',
            style: AppTypography.bodyS()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client
                  .from('garden_plants')
                  .delete()
                  .eq('garden_id', gardenId)
                  .eq('plant_id', plantId);
              await ref.read(cacheServiceProvider).invalidate(
                CacheService.gardenPlantsKey(gardenId),
              );
              ref.invalidate(_gardenPlantsProvider(gardenId));
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
  }
}

String _statusEmoji(String status) {
  switch (status) {
    case 'started':    return '🌱';
    case 'growing':    return '🌿';
    case 'flowering':  return '🌸';
    case 'harvesting': return '🌾';
    case 'done':       return '✅';
    default:           return '';
  }
}

// ── Journal Tab ───────────────────────────────────────────

class _JournalTab extends ConsumerWidget {
  const _JournalTab({required this.gardenId, required this.onAddEntry, required this.onRefresh});
  final String gardenId;
  final VoidCallback onAddEntry;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalNotifierProvider(gardenId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => OGErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(journalNotifierProvider(gardenId)),
      ),
      data: (entries) => entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📓', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('No entries yet',
                      style: AppTypography.displayM(color: AppColors.warmGray)),
                  const SizedBox(height: 8),
                  Text('Tap + to log your first entry.',
                      style: AppTypography.bodyS()),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.terracotta,
              backgroundColor: AppColors.charcoal,
              onRefresh: () async => onRefresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _JournalEntryCard(
                  entry: entries[i],
                  onDelete: () {}, // Empty since deletion handled inline
                  onTap: () => context.push('/journal-entry/${entries[i].id}', extra: {
                    'entry': entries[i],
                  }),
                  gardenId: gardenId, // gardenId available in the parent widget
                  onDeleted: () => ref.invalidate(journalEntriesProvider(gardenId)),
                ),
              ),
            ),
    );
  }

  void _showJournalEntryDetail(BuildContext context, JournalEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = '${entry.entryDate.month}/${entry.entryDate.day}/${entry.entryDate.year}';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warmGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: Column(
                children: [
                  // Hero image header
                  if (entry.photoUrl != null)
                    _buildMediaWidget(entry.photoUrl!),
                  // Scrollable content below
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date title
                          Text(
                            dateStr,
                            style: AppTypography.displayM(
                              color: isDark ? AppColors.cream : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Note
                          if (entry.note != null && entry.note!.isNotEmpty) ...[
                            Text(
                              entry.note!,
                              style: AppTypography.bodyM(
                                color: isDark ? AppColors.cream : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Tags
                          if (entry.tags != null && entry.tags!.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.tags!.map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.fern.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.leaf.withOpacity(0.4)),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTypography.bodyS(color: AppColors.leaf),
                                ),
                              )).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Journal Entry Card ────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry, 
    required this.onDelete, 
    required this.onTap,
    required this.gardenId,
    required this.onDeleted,
  });
  final JournalEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String gardenId;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        '${entry.entryDate.month}/${entry.entryDate.day}/${entry.entryDate.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
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
          if (entry.photoUrl != null)
            _buildMediaWidget(entry.photoUrl!)
          else
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.fern, AppColors.moss]),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMD)),
              ),
              child: const Center(
                child: Text('📓', style: TextStyle(fontSize: 24)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(dateStr,
                        style: AppTypography.monoS(color: AppColors.warmGray)),
                    const Spacer(),
                    IconButton(
  icon: const Icon(Icons.delete_outline, color: AppColors.warmGray, size: 20),
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Delete entry?', style: AppTypography.sectionTitle()),
        content: Text('This cannot be undone.', style: AppTypography.bodyS()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Supabase.instance.client
          .from('journal_entries')
          .delete()
          .eq('id', entry.id);
      onDeleted();
    }
  },
),
                  ],
                ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(entry.note!,
                      style: AppTypography.bodyM(
                          color: isDark ? AppColors.cream : AppColors.ink)),
                ],
                if (entry.wateringMl != null) ...[
                  const SizedBox(height: 8),
                  Text('💧 ${entry.wateringMl}ml',
                      style: AppTypography.bodyS(color: AppColors.frost)),
                ],
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: entry.tags.map((t) => OGTag(label: t)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Add Entry Sheet ───────────────────────────────────────

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({required this.gardenId, required this.ref});
  final String gardenId;
  final WidgetRef ref;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _noteCtrl  = TextEditingController();
  final _tagCtrl   = TextEditingController();
  final _waterCtrl = TextEditingController();
  DateTime _date   = DateTime.now();
  bool _saving     = false;
  bool _uploadingPhoto = false;
  final List<String> _tags = [];
  List<Map<String, dynamic>> _selectedMedia = [];
  String? _uploadedPhotoUrl;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _noteCtrl.dispose();
    _tagCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<bool> _requestMediaPermissions() async {
    if (!Platform.isAndroid) return true;
    
    // Android 13+ uses granular permissions
    final sdkInt = await _getAndroidSdkInt();
    if (sdkInt >= 33) {
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final camera = await Permission.camera.request();
      return photos.isGranted && videos.isGranted && camera.isGranted;
    } else {
      final storage = await Permission.storage.request();
      final camera = await Permission.camera.request();
      return storage.isGranted && camera.isGranted;
    }
  }

  Future<int> _getAndroidSdkInt() async {
    try {
      if (Platform.isAndroid) {
        final sdkVersion = await const MethodChannel('flutter/platform')
            .invokeMethod<String>('Android.getBuildVersion.SDK_INT');
        return int.tryParse(sdkVersion ?? '0') ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> _pickMedia(ImageSource source) async {
    final pickedPhotos = await _picker.pickMultipleMedia(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedPhotos == null) return;
    
    setState(() {
      _uploadingPhoto = true;
      _selectedMedia = pickedPhotos.map((media) => {
        'path': media.path,
        'type': (media.mimeType ?? '').startsWith('video/') ? 'video' : 'photo',
      }).toList();
    });
    
    try {
      final urls = await Future.wait(
        pickedPhotos.map((media) async {
          try {
            if ((media.mimeType ?? '').startsWith('video/')) {
              return await widget.ref
                  .read(storageServiceProvider)
                  .uploadJournalVideo(
                    file: File(media.path),
                    gardenId: widget.gardenId,
                  );
            } else {
              return await widget.ref
                  .read(storageServiceProvider)
                  .uploadJournalPhoto(
                    file: File(media.path),
                    gardenId: widget.gardenId,
                  );
            }
          } catch (e) {
            debugPrint('Upload error: $e');
            return null;
          }
        }),
      );
      
      final validUrls = urls.whereType<String>().toList();
      setState(() {
        _uploadedPhotoUrl = validUrls.isNotEmpty ? validUrls.first : null;
        _uploadingPhoto = false;
      });
      
      debugPrint('📸 Uploaded photo URL: $_uploadedPhotoUrl');
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _pickVideo(ImageSource source) async {
    final pickedVideo = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
    
    if (pickedVideo == null) return;
    
    setState(() {
      _uploadingPhoto = true;
      _selectedMedia = [
        {
          'path': pickedVideo.path,
          'type': 'video',
        }
      ];
    });
    
    try {
      final url = await widget.ref
          .read(storageServiceProvider)
          .uploadJournalVideo(
            file: File(pickedVideo.path),
            gardenId: widget.gardenId,
          );
      
      setState(() {
        _uploadedPhotoUrl = url;
        _uploadingPhoto = false;
      });
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _showMediaSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('📷', style: TextStyle(fontSize: 22)),
              title: Text('Take Photo', style: AppTypography.bodyM()),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Text('🎥', style: TextStyle(fontSize: 22)),
              title: Text('Take Video', style: AppTypography.bodyM()),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Text('🖼️', style: TextStyle(fontSize: 22)),
              title: Text('Choose Photo', style: AppTypography.bodyM()),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Text('🎬', style: TextStyle(fontSize: 22)),
              title: Text('Choose Video', style: AppTypography.bodyM()),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
            if (_selectedMedia.isNotEmpty)
              ListTile(
                leading: const Text('🗑️', style: TextStyle(fontSize: 22)),
                title: Text('Remove media',
                    style: AppTypography.bodyM()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedMedia.clear();
                    _uploadedPhotoUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _addTag() {
    final t = _tagCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _tags.add(t);
      _tagCtrl.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.ref
          .read(journalNotifierProvider(widget.gardenId).notifier)
          .addEntry(
            gardenId: widget.gardenId,
            entryDate: _date,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            wateringMl: int.tryParse(_waterCtrl.text),
            photoUrl: _uploadedPhotoUrl,
            tags: _tags,
          );
      // Refresh the journal list immediately
      widget.ref.invalidate(journalNotifierProvider(widget.gardenId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Entry', style: AppTypography.displayM()),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showMediaSourceSheet,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: _uploadingPhoto
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📷', style: TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text('Tap to add media',
                              style: AppTypography.bodyS()),
                        ],
                      ),
              ),
            ),
            _buildMediaPreview(),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Text(
                      '${_date.month}/${_date.day}/${_date.year}',
                      style: AppTypography.bodyM(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: AppTypography.bodyM(),
              decoration: const InputDecoration(
                  hintText: 'What happened today in the garden?'),
            ),
            const SizedBox(height: 12),
            OGTextField(
              controller: _waterCtrl,
              hint: 'Water amount (ml) — optional',
              prefixEmoji: '💧',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OGTextField(
                    controller: _tagCtrl,
                    hint: 'Add tag (e.g. aphids, transplant)',
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addTag,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.leaf,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags
                    .map((t) => GestureDetector(
                          onTap: () => setState(() => _tags.remove(t)),
                          child: OGTag(label: '$t ✕'),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            OGButton(
              label: 'Save Entry',
              onPressed: _saving ? null : _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedMedia.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMedia.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final media = _selectedMedia[i];
          final isVideo = (media['type'] as String? ?? '') == 'video';
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
              ? Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surfaceDark,
                  child: const Center(
                    child: Icon(Icons.videocam, color: AppColors.leaf, size: 32),
                  ),
                )
              : Image.file(
                  File(media['path'] as String),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceDark,
                    child: const Icon(Icons.broken_image, color: AppColors.warmGray),
                  ),
                ),
          );
        },
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({required this.path});
  final String path;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          if (!_controller.value.isPlaying)
            const Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

// ── Media Widget Helper Function ──────────────────────────────────

Widget _buildMediaWidget(String url) {
  final isVideo = url.contains('.mp4') || url.contains('.mov') || url.contains('.avi');
  if (isVideo) {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: AppColors.leaf, size: 64),
      ),
    );
  }
  return Image.network(
    url,
    width: double.infinity,
    height: 220,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: 220,
      color: AppColors.surfaceDark,
      child: const Center(child: Text('📷', style: TextStyle(fontSize: 40))),
    ),
  );
}
