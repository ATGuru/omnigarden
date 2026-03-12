import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../models/garden.dart';
import '../providers/garden_provider.dart';

class GardenDetailScreen extends ConsumerWidget {
  const GardenDetailScreen({super.key, required this.gardenId});
  final String gardenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalNotifierProvider(gardenId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.soil : AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        leading: BackButton(color: AppColors.cream),
        title: Text(
          'Journal',
          style: AppTypography.displayM(color: AppColors.cream),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.terracotta,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEntrySheet(context, ref),
      ),
      body: entriesAsync.when(
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
                    Text(
                      'No entries yet',
                      style: AppTypography.displayM(
                          color: AppColors.warmGray),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to log your first entry.',
                      style: AppTypography.bodyS(),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _JournalEntryCard(
                  entry: entries[i],
                  onDelete: () => ref
                      .read(journalNotifierProvider(gardenId).notifier)
                      .deleteEntry(entries[i].id),
                ),
              ),
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEntrySheet(gardenId: gardenId, ref: ref),
    );
  }
}

// ── Journal Entry Card ────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
    required this.onDelete,
  });
  final JournalEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        '${entry.entryDate.month}/${entry.entryDate.day}/${entry.entryDate.year}';

    return Container(
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
          // Photo placeholder
          if (entry.photoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusMD)),
              child: Image.network(
                entry.photoUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.fern, AppColors.moss],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMD)),
              ),
              child: const Center(
                child: Text('📓', style: TextStyle(fontSize: 32)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + delete
                Row(
                  children: [
                    Text(dateStr,
                        style: AppTypography.monoS(color: AppColors.warmGray)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.warmGray),
                    ),
                  ],
                ),

                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.note!,
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                ],

                if (entry.wateringMl != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💧 ${entry.wateringMl}ml watered',
                    style: AppTypography.bodyS(color: AppColors.frost),
                  ),
                ],

                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: entry.tags
                        .map((t) => OGTag(
                              label: t,
                              isWarning: ['aphids', 'pests', 'disease',
                                      'overwatered', 'dead']
                                  .contains(t.toLowerCase()),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
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
  final _noteCtrl = TextEditingController();
  final _tagCtrl  = TextEditingController();
  final _waterCtrl = TextEditingController();
  DateTime _date  = DateTime.now();
  bool _saving    = false;
  final List<String> _tags = [];

  @override
  void dispose() {
    _noteCtrl.dispose();
    _tagCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
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
            tags: _tags,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 24, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Entry', style: AppTypography.displayM()),
            const SizedBox(height: 20),

            // Date picker
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

            // Note
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              style: AppTypography.bodyM(),
              decoration: const InputDecoration(
                hintText: 'What happened today in garden?',
              ),
            ),
            const SizedBox(height: 12),

            // Watering
            OGTextField(
              controller: _waterCtrl,
              hint: 'Water amount (ml) — optional',
              prefixEmoji: '💧',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Tags
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
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 20),
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
                          onTap: () =>
                              setState(() => _tags.remove(t)),
                          child: OGTag(label: '$t ✕'),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 20),
            OGButton(
              label: 'Save Entry',
              onPressed: _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
