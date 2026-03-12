// lib/features/auth/screens/zip_entry_screen.dart
//
// ZIP → zone lookup uses a hardcoded prefix map (Phase 1).
// Phase 2: swap with Supabase Edge Function or USDA Plant Hardiness API.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/og_widgets.dart';
import '../providers/auth_provider.dart';

class ZipEntryScreen extends ConsumerStatefulWidget {
  const ZipEntryScreen({super.key});

  @override
  ConsumerState<ZipEntryScreen> createState() => _ZipEntryScreenState();
}

class _ZipEntryScreenState extends ConsumerState<ZipEntryScreen> {
  final _zipCtrl = TextEditingController();
  String? _detectedZone;
  String? _detectedLocation;
  bool _saving = false;
  bool _lookingUp = false;

  @override
  void dispose() {
    _zipCtrl.dispose();
    super.dispose();
  }

  // Phase 1 stub: ZIP prefix → zone
  // Covers main US zones. Phase 2: full 45,000-ZIP dataset in Supabase.
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
  final zone = _detectedZone;
  final zip  = _zipCtrl.text.trim();
  if (zone == null || zip.length != 5) return;

  setState(() => _saving = true);
  await ref.read(authStateNotifierProvider.notifier)
      .saveZip(zip, zone, location: _detectedLocation);
  setState(() => _saving = false);
  if (mounted) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final frostDates = _detectedZone != null
        ? AppConstants.frostDates[_detectedZone]
        : null;

    return Scaffold(
      backgroundColor: AppColors.soil,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        automaticallyImplyLeading: true,
        title: Text('ZIP Entry', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 60),

              Text('📍', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                "Where's\nyour garden?",
                style: AppTypography.displayL(),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your ZIP code to get hyper-local frost dates and planting windows.',
                style: AppTypography.bodyM(color: AppColors.warmGray),
              ),
              const SizedBox(height: 40),

              // ZIP input
              TextField(
                controller: _zipCtrl,
                keyboardType: TextInputType.number,
                maxLength: 5,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (val) => _onZipChanged(val),
                style: AppTypography.displayM(color: AppColors.cream)
                    .copyWith(letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '_ _ _ _ _',
                  hintStyle: AppTypography.displayM(color: AppColors.warmGray)
                      .copyWith(letterSpacing: 8),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.terracotta, width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),

              const SizedBox(height: 24),

              // Zone detection result
              AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    child: _detectedZone != null
        ? _ZoneCard(
            zone: _detectedZone!,
            location: _detectedLocation ?? '',
            lastFrost: frostDates?['last'] ?? '—',
            firstFrost: frostDates?['first'] ?? '—',
          )
        : const SizedBox.shrink(),
  ),

              const Spacer(),

              OGButton(
                label: _lookingUp
                    ? 'Looking up ZIP...'
                    : _detectedZone != null
                        ? 'Use ${_detectedLocation ?? _detectedZone!} →'
                        : 'Enter a 5-digit ZIP',
                onPressed: (_detectedZone != null && !_lookingUp) ? _save : null,
                isLoading: _lookingUp || _saving,
              ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref.read(authStateNotifierProvider.notifier)
                        .saveZip('00000', 'Zone 6a', location: 'United States');
                    if (mounted) context.go('/home');
                  },
                  child: Text(
                    'Skip — use default (Zone 6a)',
                    style: AppTypography.bodyS(color: AppColors.warmGray),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),  // SingleChildScrollView closes
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.zone,
    required this.location,
    required this.lastFrost,
    required this.firstFrost,
  });
  final String zone;
  final String location;
  final String lastFrost;
  final String firstFrost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fern.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.leaf.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: AppTypography.displayM(color: AppColors.sprout),
                ),
                const SizedBox(height: 2),
                Text(
                  zone,
                  style: AppTypography.monoS(color: AppColors.warmGray)
                      .copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('❄', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text('Last frost: $lastFrost',
                        style: AppTypography.monoS(color: AppColors.frost)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🍂', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text('First frost: $firstFrost',
                        style: AppTypography.monoS(
                            color: AppColors.warmGray)),
                  ],
                ),
              ],
            ),
          ),
          const Text('✓', style: TextStyle(
            color: AppColors.leaf,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }
}
