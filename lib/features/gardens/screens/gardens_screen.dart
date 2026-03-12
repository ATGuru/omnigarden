import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../../../shared/utils/storage_service.dart';
import '../models/garden.dart';
import '../providers/garden_provider.dart';

class GardensScreen extends ConsumerStatefulWidget {
  const GardensScreen({super.key});

  @override
  ConsumerState<GardensScreen> createState() => _GardensScreenState();
}

class _GardensScreenState extends ConsumerState<GardensScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedGardenIds = {};

  Future<void> _refresh() async {
    ref.invalidate(gardenNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final gardensAsync = ref.watch(gardenNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        title: Text(
          'My Gardens',
          style: AppTypography.displayM(color: AppColors.cream),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.warmGray,
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.cream),
              onPressed: _exitSelectionMode,
              tooltip: 'Exit selection',
            ),
            if (_selectedGardenIds.length == 1)
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.cream),
                onPressed: () => _showRenameDialog(context, _selectedGardenIds.first),
                tooltip: 'Rename garden',
              ),
          ],
          IconButton(
            icon: Icon(
              _isSelectionMode ? Icons.check_circle : Icons.select_all,
              color: AppColors.cream,
            ),
            onPressed: _toggleSelectionMode,
            tooltip: _isSelectionMode ? 'Exit selection' : 'Select gardens',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text(
                    'My Gardens',
                    style: AppTypography.displayM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showCreateGardenSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '+ New',
                        style: AppTypography.labelM(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: gardensAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => OGErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(gardenNotifierProvider),
                ),
                data: (gardens) => gardens.isEmpty
                    ? _EmptyGardens(
                        onCreate: () => _showCreateGardenSheet(context, ref),
                      )
                    : RefreshIndicator(
                        color: AppColors.terracotta,
                        backgroundColor: AppColors.charcoal,
                        onRefresh: _refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: gardens.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _GardenCard(
                            garden: gardens[i],
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleGardenSelection(gardens[i].id);
                              } else {
                                context.push('/garden/${gardens[i].id}');
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                setState(() => _isSelectionMode = true);
                              }
                              _toggleGardenSelection(gardens[i].id);
                            },
                            onDelete: () => _confirmDelete(context, ref, gardens[i]),
                            isSelected: _selectedGardenIds.contains(gardens[i].id),
                            isSelectionMode: _isSelectionMode,
                          ),
                        ),
                      ),
              ),
            ),
            if (_isSelectionMode && _selectedGardenIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.bark,
                child: Row(
                  children: [
                    Text(
                      '${_selectedGardenIds.length} selected',
                      style: AppTypography.labelM(color: AppColors.cream),
                    ),
                    const Spacer(),
                    if (_selectedGardenIds.length == 1)
                      TextButton(
                        onPressed: () => _showRenameDialog(context, _selectedGardenIds.first),
                        child: Text('Rename', style: TextStyle(color: AppColors.leaf)),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _batchDeleteSelectedGardens(context, ref),
                      child: Text('Delete', style: TextStyle(color: AppColors.rust)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedGardenIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedGardenIds.clear();
    });
  }

  void _toggleGardenSelection(String id) {
    setState(() {
      if (_selectedGardenIds.contains(id)) {
        _selectedGardenIds.remove(id);
      } else {
        _selectedGardenIds.add(id);
      }
    });
  }

  void _showRenameDialog(BuildContext context, String gardenId) {
    final gardens = ref.read(gardenNotifierProvider).value ?? [];
    final garden = gardens.firstWhere((g) => g.id == gardenId);
    final nameCtrl = TextEditingController(text: garden.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Rename Garden', style: AppTypography.sectionTitle()),
        content: TextField(
          controller: nameCtrl,
          style: AppTypography.bodyM(color: AppColors.cream),
          decoration: InputDecoration(
            hintText: 'Garden name',
            filled: true,
            fillColor: AppColors.surfaceDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await ref.read(gardenNotifierProvider.notifier).updateGarden(
                gardenId: gardenId,
                name: nameCtrl.text.trim(),
              );
              ref.invalidate(gardenNotifierProvider);
            },
            child: Text('Rename', style: TextStyle(color: AppColors.leaf)),
          ),
        ],
      ),
    );
  }

  Future<void> _batchDeleteSelectedGardens(BuildContext context, WidgetRef ref) async {
    final count = _selectedGardenIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Delete $count garden${count == 1 ? '' : 's'}?',
            style: AppTypography.sectionTitle()),
        content: Text(
          'This will permanently delete the selected garden${count == 1 ? '' : 's'} and all their data.',
          style: AppTypography.bodyS(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final gardenId in _selectedGardenIds.toList()) {
        await ref.read(gardenNotifierProvider.notifier).deleteGarden(gardenId);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count garden${count == 1 ? '' : 's'} deleted')),
        );
      }
      _exitSelectionMode();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showCreateGardenSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateGardenSheet(ref: ref),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Garden garden) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.charcoal,
      title: Text('Delete ${garden.name}?', style: AppTypography.sectionTitle()),
      content: Text(
        'This will permanently delete the garden and all its plants and journal entries.',
        style: AppTypography.bodyS(),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: Text('Delete', style: TextStyle(color: AppColors.rust)),
        ),
      ],
    ),
  );
  if (confirm != true) return;
  
  // Navigate first, THEN delete — prevents screen rebuilding a deleted garden
  if (context.mounted) context.go('/gardens');
  await ref.read(gardenNotifierProvider.notifier).deleteGarden(garden.id);
  ref.invalidate(gardenNotifierProvider);
}
}

// ── Garden Card ────────────────────────────────────────────────

class _GardenCard extends StatelessWidget {
  const _GardenCard({
    required this.garden,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    this.isSelected = false,
    this.isSelectionMode = false,
  });
  final Garden garden;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected
                ? AppColors.leaf
                : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isSelectionMode)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.leaf : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.leaf : AppColors.warmGray,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            Text(garden.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garden.name,
                    style: AppTypography.sectionTitle(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    garden.location ?? garden.zone ?? 'No location set',
                    style: AppTypography.bodyS(color: AppColors.warmGray),
                  ),
                ],
              ),
            ),
            if (!isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.warmGray, size: 20),
                onPressed: onDelete,
              ),
              const Icon(Icons.chevron_right, color: AppColors.warmGray),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────

class _EmptyGardens extends StatelessWidget {
  const _EmptyGardens({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No gardens yet', style: AppTypography.displayM(color: AppColors.warmGray)),
          const SizedBox(height: 8),
          Text(
            'Create your first garden to start\ntracking plants and logging entries.',
            style: AppTypography.bodyS(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCreate,
            child: const Text('Create a Garden'),
          ),
        ],
      ),
    );
  }
}

// ── Create Garden Sheet ────────────────────────────────────────

class _CreateGardenSheet extends StatefulWidget {
  const _CreateGardenSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreateGardenSheet> createState() => _CreateGardenSheetState();
}

class _CreateGardenSheetState extends State<_CreateGardenSheet> {
  final _nameCtrl = TextEditingController();
  final _zipCtrl  = TextEditingController();
  String  _emoji            = '🌿';
  String? _coverPhotoPath;
  bool    _saving           = false;
  bool    _lookingUp        = false;
  String? _detectedZone;
  String? _detectedLocation;

  final _emojis = ['🌿', '🥕', '🍅', '🌶️', '🫘', '🌽', '🌻', '🍓', '🧄', '🌱'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _prefillZip();
  }

  Future<void> _prefillZip() async {
    final prefs = await SharedPreferences.getInstance();
    final savedZip = prefs.getString('user_zip') ?? '';
    if (savedZip.length == 5) {
      _zipCtrl.text = savedZip;
      await _onZipChanged(savedZip);
    }
  }

  Future<Map<String, String>?> _lookupZip(String zip) async {
    try {
      final res = await Supabase.instance.client
          .from('zip_codes')
          .select('city, state_abbr, zone')
          .eq('zip', zip)
          .maybeSingle();
      if (res == null) return null;
      return {
        'zone':     res['zone'] as String,
        'location': '${res['city']}, ${res['state_abbr']}',
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _onZipChanged(String value) async {
    if (value.length == 5) {
      setState(() => _lookingUp = true);
      final data = await _lookupZip(value);
      setState(() {
        _detectedZone     = data?['zone'];
        _detectedLocation = data?['location'];
        _lookingUp        = false;
      });
    } else {
      setState(() {
        _detectedZone     = null;
        _detectedLocation = null;
        _lookingUp        = false;
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      String? coverPhotoUrl;
      if (_coverPhotoPath != null) {
        coverPhotoUrl = await widget.ref
            .read(storageServiceProvider)
            .uploadGardenCoverPhoto(file: File(_coverPhotoPath!));
      }
      await widget.ref.read(gardenNotifierProvider.notifier).createGarden(
            name:          _nameCtrl.text.trim(),
            emoji:         _emoji,
            zip:           _zipCtrl.text.trim(),
            zone:          _detectedZone,
            location:      _detectedLocation,
            coverPhotoUrl: coverPhotoUrl,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final photo  = await picker.pickImage(
      source:       source,
      maxWidth:     800,
      maxHeight:    800,
      imageQuality: 80,
    );
    if (photo != null) setState(() => _coverPhotoPath = photo.path);
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warmGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  _PhotoOptionTile(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 12),
                  _PhotoOptionTile(
                    icon: Icons.photo_library,
                    label: 'Choose from Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.warmGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('New Garden', style: AppTypography.displayM()),
              const SizedBox(height: 20),

              // Photo picker
              GestureDetector(
                onTap: () => _showPhotoOptions(context),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderDark,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_coverPhotoPath == null) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.terracotta.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.terracotta, width: 2),
                          ),
                          child: const Icon(Icons.add, color: AppColors.terracotta, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text('Add Cover Photo',
                            style: AppTypography.bodyM(color: AppColors.warmGray)),
                      ] else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            File(_coverPhotoPath!),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Change Cover Photo',
                            style: AppTypography.bodyM(color: AppColors.warmGray)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Emoji picker
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emojis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final e = _emojis[i];
                    final selected = e == _emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _emoji = e),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.terracotta.withOpacity(0.2)
                              : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? AppColors.terracotta : AppColors.borderDark,
                          ),
                        ),
                        child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Name input
              OGTextField(
                controller: _nameCtrl,
                hint: 'Garden name (e.g. Backyard Beds)',
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // ZIP input
              TextField(
                controller: _zipCtrl,
                keyboardType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onZipChanged,
                decoration: InputDecoration(
                  hintText: 'ZIP Code',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location detected
              if (_detectedLocation != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.fern.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.leaf, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _detectedLocation!,
                        style: AppTypography.labelM(color: AppColors.leaf),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              OGButton(
                label: _lookingUp
                    ? 'Looking up ZIP...'
                    : _saving
                        ? 'Creating Garden...'
                        : 'Create Garden',
                onPressed: (_detectedZone != null && !_lookingUp && !_saving) ? _save : null,
                isLoading: _lookingUp || _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Photo option tile ──────────────────────────────────────────

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.leaf),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.bodyM(color: AppColors.cream)),
          ],
        ),
      ),
    );
  }
}
