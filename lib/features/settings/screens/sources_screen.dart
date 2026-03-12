// lib/features/settings/screens/sources_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.soil : AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.bark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => context.pop(),
        ),
        title: Text('Sources & Credits', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Data
              _SourceSection(
                icon: '🌱',
                title: 'Plant Data',
                subtitle: 'USDA PLANTS Database',
                description: 'Comprehensive plant information, growing guides, and characteristics for thousands of species.',
                url: 'https://plants.usda.gov',
              ),
              
              const SizedBox(height: 24),
              
              // Hardiness Zones
              _SourceSection(
                icon: '🗺️',
                title: 'Hardiness Zones',
                subtitle: '2023 USDA Plant Hardiness Zone Map, PRISM Climate Group, Oregon State University',
                description: 'Interactive zone mapping system based on USDA climate data and university research.',
                url: 'https://prism.oregonstate.edu',
              ),
              
              const SizedBox(height: 24),
              
              // ZIP Code Data
              _SourceSection(
                icon: '📮',
                title: 'ZIP Code Data',
                subtitle: 'SimpleMaps US ZIP Codes Database',
                description: 'Basic ZIP code lookup for geographic location data.',
                url: 'https://simplemaps.com/data/us-zips',
              ),
              
              const SizedBox(height: 24),
              
              // Moon Phase Calculations
              _SourceSection(
                icon: '🌙',
                title: 'Moon Phase Calculations',
                subtitle: 'Astronomical algorithms implemented in Dart, based on Jean Meeus "Astronomical Algorithms"',
                description: 'Lunar phase calculations and gardening timing recommendations.',
                url: 'https://en.wikipedia.org/wiki/Astronomical_algorithms',
              ),
              
              const SizedBox(height: 24),
              
              // App Development
              _SourceSection(
                icon: '🛠️',
                title: 'App Design & Development',
                subtitle: 'Built with Flutter, Supabase, Riverpod',
                description: 'Modern garden planning application with real-time data synchronization.',
              ),
              
              const SizedBox(height: 40),
              
              // Developer Credit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🌱',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Developed by',
                          style: AppTypography.bodyS(color: AppColors.warmGray),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AllTechGuru',
                          style: AppTypography.labelM(color: AppColors.terracotta),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'omnigarden.app',
                      style: AppTypography.bodyS(color: AppColors.warmGray),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    this.url,
  });
  
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: url != null ? () {
        // Launch URL in external browser
        // TODO: Add in-app web view for better UX
      } : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
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
                color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS(color: AppColors.warmGray),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.bodyS(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
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
