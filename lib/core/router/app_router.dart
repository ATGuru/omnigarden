// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/gardens/screens/featured_garden_screen.dart';
import '../../features/gardens/models/featured_garden.dart';
import '../../features/gardens/models/garden.dart';
import '../../features/gardens/models/garden_plant.dart';
import '../../features/gardens/screens/garden_plant_screen.dart';
import '../../features/gardens/screens/garden_detail_screen.dart';
import '../../features/gardens/screens/garden_plan_screen.dart';
import '../../features/gardens/screens/garden_lunar_screen.dart';
import '../../features/gardens/screens/journal_entry_detail_screen.dart';
import '../../features/settings/screens/sources_screen.dart';
import '../../features/settings/screens/guide_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/export_plans_screen.dart';
import '../../features/settings/screens/export_calendar_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/zip_entry_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/plants/screens/plant_search_screen.dart';
import '../../features/plants/screens/plant_detail_screen.dart';
import '../../features/gardens/screens/gardens_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../shell/main_shell.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

// ── Route path constants ─────────────────────────────────
abstract final class AppRoutes {
  static const splash     = '/';
  static const onboarding = '/onboarding';
  static const zipEntry   = '/zip-entry';
  static const signIn     = '/sign-in';
  static const signUp     = '/sign-up';

  // Shell routes (bottom nav)
  static const home       = '/home';
  static const search     = '/search';
  static const calendar   = '/calendar';
  static const gardens    = '/gardens';

  // Push routes (full screen)
  static const plantDetail = '/plant/:id';
  static const gardenPlantSearch = '/garden-plant-search';
  static const sources     = '/sources';
  static const guide       = '/guide';
  static const exportPlans = '/export-plans';
  static const exportCalendar = '/export-calendar';
  static const resetPassword = '/reset-password';
  static String plantDetailPath(String id) => '/plant/$id';
}

// ── Provider ─────────────────────────────────────────────
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final notifier = ref.watch(authStateNotifierProvider.notifier);
  
  final listenable = _AuthChangeNotifier(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: rootNavigatorKey,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authValue   = ref.read(authStateNotifierProvider);
      final isLoading   = authValue.isLoading;
      final authData    = authValue.value;
      final isAuthed    = authData?.isAuthenticated ?? false;
      final isGuest     = authData?.isGuest ?? false;
      final hasZip      = authData?.hasZip ?? false;
      final currentRoute = state.matchedLocation;
      print('REDIRECT: route=$currentRoute isAuthed=$isAuthed isGuest=$isGuest hasZip=$hasZip isLoading=$isLoading');

      if (currentRoute == '/') return null;
      if (currentRoute == '/zip-entry') return null;

      final isAuthRoute = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.zipEntry,
        AppRoutes.signIn,
        AppRoutes.signUp,
      ].contains(currentRoute);

      if (isLoading) return null;

      if ((isAuthed || isGuest) && hasZip && isAuthRoute) return AppRoutes.home;
      if ((isAuthed || isGuest) && !hasZip && isAuthRoute && currentRoute != AppRoutes.zipEntry) return AppRoutes.zipEntry;
      if (!isAuthed && !isGuest && !isAuthRoute && currentRoute != AppRoutes.signIn && currentRoute != AppRoutes.signUp) return AppRoutes.onboarding;

      return null;
    },
    routes: [
      // ── Auth routes ────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.zipEntry,
        builder: (_, __) => const ZipEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(),
      ),

      // ── Shell with bottom nav ──────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (_, __) => const PlantSearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.guide,
            builder: (_, __) => const GuideScreen(),
          ),
          GoRoute(
            path: AppRoutes.sources,
            builder: (_, __) => const SourcesScreen(),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: AppRoutes.gardens,
            builder: (_, __) => const GardensScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),

      // ── Full-screen push ───────────────────────────────
      GoRoute(
        path: '/plant/:id',
        builder: (_, state) => PlantDetailScreen(
          plantId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/garden/:id',
        builder: (_, state) => GardenDetailScreen(
          gardenId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/garden-plant-search',
        builder: (_, __) => const PlantSearchScreen(),
      ),
      GoRoute(
        path: '/featured-garden/:id',
        builder: (context, state) {
          final garden = state.extra as FeaturedGarden;
          return FeaturedGardenScreen(garden: garden);
        },
      ),
      GoRoute(
        path: '/garden-plant/:id',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return GardenPlantScreen(
            gardenPlantId: state.pathParameters['id']!,
            plantId: extra['plantId'] as String,
            gardenName: extra['gardenName'] as String,
          );
        },
      ),
      GoRoute(
        path: '/journal-entry/:id',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final entry = extra?['entry'] as JournalEntry?;
          return JournalEntryDetailScreen(entry: entry!);
        },
      ),
      GoRoute(
        path: AppRoutes.exportPlans,
        builder: (_, __) => const ExportPlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.exportCalendar,
        builder: (_, __) => const ExportCalendarScreen(),
      ),
    ],
    errorBuilder: (_, state) => _RouterErrorScreen(error: state.error),
  );
}

// ── Placeholder screens for Phase 2 features ─────────────
class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text(
        '$label\nComing in Phase 2',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Navigation error: ${error?.toString() ?? "Unknown"}'),
    ),
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen(authStateNotifierProvider, (previous, next) {
      // Only notify if loading state changed, or auth/guest/zip values changed
      final prevLoading = previous?.isLoading ?? false;
      final nextLoading = next.isLoading;
      final prevAuthed = previous?.value?.isAuthenticated ?? false;
      final nextAuthed = next.value?.isAuthenticated ?? false;
      final prevGuest = previous?.value?.isGuest ?? false;
      final nextGuest = next.value?.isGuest ?? false;
      final prevZip = previous?.value?.hasZip ?? false;
      final nextZip = next.value?.hasZip ?? false;

      if (prevLoading != nextLoading ||
          prevAuthed != nextAuthed ||
          prevGuest != nextGuest ||
          prevZip != nextZip) {
        notifyListeners();
      }
    });
  }
  final Ref _ref;
}
