// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

// ── Phase 2: uncomment Supabase initialization ───────────
// import 'package:supabase_flutter/supabase_flutter.dart';
// const supabaseUrl  = String.fromEnvironment('SUPABASE_URL');
// const supabaseKey  = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 2: await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    const ProviderScope(
      child: OmniGardenApp(),
    ),
  );
}

class OmniGardenApp extends ConsumerWidget {
  const OmniGardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeMode_Provider);

    return MaterialApp.router(
      title: 'OmniGarden',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Navigation
      routerConfig: router,
    );
  }
}
