// lib/features/settings/screens/guide_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/og_widgets.dart';

class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

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
        title: Text('How to Use OmniGarden', style: AppTypography.displayM(color: AppColors.cream)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('🌱', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'Welcome to OmniGarden',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Your Midwest Gardening Companion',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'OmniGarden is a comprehensive gardening companion built specifically for Midwest growers. It combines a curated 2,200+ plant encyclopedia, personalized planting calendars based on your USDA hardiness zone, a detailed garden journal, and lunar gardening guidance—all in one powerful app.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set your ZIP code once and everything—planting dates, frost warnings, seasonal tips—automatically adjusts to your exact location. Whether you\'re in Chicago\'s Zone 6a or Minneapolis\'s Zone 4b, OmniGarden delivers hyper-local guidance for your specific climate.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The app tracks your entire gardening journey from seed to harvest. Plan multiple garden beds, log daily observations with photos, and get lunar phase recommendations for optimal planting times. Every feature is designed to help Midwest gardeners maximize their growing season and harvest success.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Perfect for both beginners learning their first season and experienced growers looking to optimize their yields. OmniGarden turns complex gardening knowledge into simple, actionable guidance tailored to your exact location.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Home Screen Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('🏡', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'Home Screen',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Your Personal Garden Dashboard',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The home screen is your personalized gardening dashboard that shows your current season and location-specific tips. It displays real-time information based on your ZIP code, including current growing phase, upcoming frost dates, and seasonal recommendations tailored to your exact climate zone.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The "Start Soon" section highlights plants coming up in your planting calendar within the next 2-4 weeks. This helps you prepare seeds, gather supplies, and plan your garden tasks. Each plant card shows the optimal planting window and quick access to detailed care instructions.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quick action cards provide instant navigation to key features. Jump directly to Search to explore new plants, Calendar to review your planting schedule, or Gardens to manage your existing garden beds. These shortcuts adapt based on your current gardening season and activity.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap any plant in the "Start Soon" section to see its full profile including growth stages, companion plants, spacing requirements, watering needs, and your local planting windows. The home screen learns from your garden activity and prioritizes the most relevant plants for your current season.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Search Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('🔍', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'Search',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Explore 2,200+ Plant Varieties',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Browse or search through our curated database of over 2,200 plant varieties covering vegetables, herbs, fruits, and flowers suited for Midwest growing conditions. Use the search bar to find plants by common name, scientific name, or characteristics like "drought tolerant" or "shade loving."',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap any plant to see its comprehensive profile including detailed growth stages, companion planting recommendations, proper spacing guidelines, specific watering needs, soil requirements, and most importantly—your personalized planting windows calculated for your exact hardiness zone.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use advanced filter options to narrow down the perfect plants for your garden. Filter by plant category (vegetables, herbs, flowers, fruits), growing conditions (sun requirements, water needs, soil type), mature height, days to maturity, and even specific uses like "container gardening" or "pollinator friendly."',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Each plant profile includes practical information like pest and disease resistance, common problems to watch for, harvesting tips, and storage recommendations. The "Add to Garden" button instantly adds plants to your existing gardens, automatically updating your calendar with the correct planting dates for your location.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Calendar Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('📅', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'Calendar',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Your Personalized Planting Calendar',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your calendar shows personalized indoor start, transplant, and direct sow windows for every plant in the database, precisely calculated for your specific USDA hardiness zone. Each colored bar represents optimal timing: light blue for indoor sowing, orange-red for transplanting, and green for direct outdoor sowing.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All planting dates automatically update when you change your ZIP code, ensuring your timing is always perfectly matched to your local climate. The calendar accounts for your last spring frost date and first fall frost date, providing safe planting windows that minimize risk of crop loss.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The color legend at the top clearly shows what each bar means, making it easy to scan your year at a glance. The current month is highlighted to show where you are in the growing season. Tap any plant row to see its full detail page with specific timing recommendations and care instructions.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your calendar automatically includes every plant you\'ve added to your gardens, plus you can search and view timing for any plant in the database. This helps you plan succession planting, coordinate crop rotations, and ensure continuous harvests throughout the growing season.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // My Gardens Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('🌿', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'My Gardens',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Create and Manage Multiple Gardens',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create multiple gardens and give each one a unique name, emoji, and optional cover photo. Whether you have a vegetable garden, herb garden, flower beds, or container garden, you can organize and track each space separately with its own plant list and journal entries.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add plants to each garden and track their progress through the season. Each plant gets its own profile with growth observations, photos, and care notes. The garden overview shows all your plants at a glance with their current status and upcoming care tasks.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use the Journal tab to log daily observations, photos, and notes for each garden. Record planting dates, growth milestones, pest sightings, weather observations, and harvest records. Photos are automatically timestamped and organized by garden and plant for easy reference.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The Plan tab helps you map your garden layout with an interactive drag-and-drop grid. Design your planting arrangement, visualize spacing, and optimize companion planting. The Lunar tab shows moon phase recommendations for optimal timing of garden tasks like planting, pruning, and harvesting.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Long-press any garden card to enter selection mode for batch operations. Select multiple gardens to rename them simultaneously or delete entire gardens. This makes it easy to manage seasonal garden cleanup or reorganize your garden structure between growing seasons.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Settings Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('⚙️', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'Settings',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Customize Your Garden Experience',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Change your ZIP code at any time to update all planting dates and frost information. When you move or want to plan for a different location, simply update your ZIP and the entire app—calendar, planting recommendations, and seasonal tips—automatically adjusts to your new climate zone.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toggle dark mode to match your preference or time of day. Dark mode reduces eye strain in low light conditions and can help extend battery life on OLED screens. Your preference is saved and applied across the entire app interface.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Manage notification preferences for planting reminders. Get alerts when it\'s time to start seeds indoors, transplant seedlings, or direct sow crops. You can customize which types of notifications you receive and when they arrive, ensuring you never miss critical planting windows.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'View app sources and credits to learn about the data behind OmniGarden. We transparently share our plant database sources, climate data providers, and the research that powers our planting recommendations. This helps you understand the science behind your gardening guidance.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The Danger Zone section allows you to sign out of your account or permanently delete your account and all associated data. Sign out simply logs you out while preserving your data for future use. Delete account permanently removes everything—gardens, journal entries, photos, and personal information—so use this option carefully.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Lunar Gardening Section
              ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.terracotta.withOpacity(0.2) : AppColors.fern.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('🌙', style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(
                  'Lunar Gardening',
                  style: AppTypography.sectionTitle(
                    color: isDark ? AppColors.cream : AppColors.ink,
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Gardening by Moon Phases',
                    style: AppTypography.bodyM(
                      color: isDark ? AppColors.cream : AppColors.ink,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The lunar calendar shows the current moon phase and daily recommendations for planting, pruning, harvesting, or resting. This ancient gardening practice aligns your garden tasks with natural lunar cycles that influence plant growth, sap flow, and pest activity.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Waxing moon phases (from new moon to full moon) favor above-ground crops. As the moon grows, it draws energy upward, making this the ideal time to plant leafy greens, fruits, and flowers. The increasing light also promotes strong leaf development and vigorous growth.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Waning phases (from full moon to new moon) favor root work and pruning. As the moon decreases, energy pulls downward into the soil, making this perfect for planting root vegetables, transplanting, and pruning. The decreased light helps plants focus on root development rather than leaf growth.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The new moon is ideal for soil preparation. With minimal gravitational pull, this is the perfect time to work the soil, add amendments, and prepare beds. Planting during the new moon gives seeds a strong start as they begin their journey with the growing lunar energy.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The full moon is best for harvesting. At peak lunar energy, plants are at their most potent and flavorful. Harvesting during the full moon is believed to produce better-tasting crops and longer storage life. It\'s also an excellent time for gathering herbs and medicinal plants.',
                    style: AppTypography.bodyS(color: AppColors.warmGray).copyWith(height: 1.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
