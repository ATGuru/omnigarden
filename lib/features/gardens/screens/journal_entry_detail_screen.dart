// lib/features/gardens/screens/journal_entry_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../models/garden.dart';
import '../providers/garden_provider.dart';

// ── Media Helper Functions ────────────────────────────────────────

Widget _buildMediaWidget(String url, {double height = 220}) {
  final isVideo = url.contains('.mp4') || url.contains('.mov') || url.contains('.avi');
  if (isVideo) return _VideoPlayerWidget(url: url);
  return Image.network(
    url,
    width: double.infinity,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: height,
      color: const Color(0xFF2A2A27),
      child: const Center(child: Text('📷', style: TextStyle(fontSize: 40))),
    ),
  );
}

// ── Video Player Widget ────────────────────────────────────────

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({required this.url});
  final String url;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      }),
      child: Container(
        width: double.infinity,
        height: 220,
        color: Colors.black,
        child: _initialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!_controller.value.isPlaying)
                  const Icon(Icons.play_circle_fill,
                      color: Color(0xFF7A9E4E), size: 64),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF7A9E4E)),
            ),
      ),
    );
  }
}

// ── Main Screen ────────────────────────────────────────────

class JournalEntryDetailScreen extends ConsumerWidget {
  const JournalEntryDetailScreen({super.key, required this.entry});
  
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Format date as "Monday, March 10, 2026"
    final formattedDate = _formatDate(entry.entryDate);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.soil : AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.cream),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
        title: null, // No title, date will be shown in header section
      ),
      body: Column(
        children: [
          // Dark header section with date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                    : [const Color(0xFF2C3E6B), const Color(0xFF1A2440)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: AppTypography.displayM(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable content below
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo grid if photos exist
                  if (entry.photoUrl != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Photos',
                      style: AppTypography.labelM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showFullScreenPhoto(context, entry.photoUrl!),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD - 1),
                          child: _buildMediaWidget(entry.photoUrl!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Body note text in readable card
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    Text(
                      'Notes',
                      style: AppTypography.labelM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        entry.note!,
                        style: AppTypography.bodyM(
                          color: isDark ? AppColors.cream : AppColors.ink,
                        ).copyWith(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Tags displayed as chips
                  if (entry.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: AppTypography.labelM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.tags.map((tag) => OGTag(label: tag)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Watering info if exists
                  if (entry.wateringMl != null) ...[
                    Text(
                      'Watering',
                      style: AppTypography.labelM(
                        color: isDark ? AppColors.cream : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('💧', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(
                            '${entry.wateringMl}ml',
                            style: AppTypography.bodyM(
                              color: isDark ? AppColors.cream : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showFullScreenPhoto(BuildContext context, String photoUrl) {
    final isVideo = photoUrl.contains('.mp4') || photoUrl.contains('.mov') || photoUrl.contains('.avi');
    if (isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Icon(Icons.play_circle_fill, color: Color(0xFF7A9E4E), size: 64),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                child: _buildMediaWidget(photoUrl),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Delete Entry?', style: AppTypography.sectionTitle()),
        content: Text(
          'This journal entry will be permanently deleted.',
          style: AppTypography.bodyS(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.warmGray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(journalNotifierProvider(entry.gardenId).notifier)
                  .deleteEntry(entry.id);
              context.pop();
            },
            child: Text('Delete',
                style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
  }
}
