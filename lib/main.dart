
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'shared/utils/cache_provider.dart';
import 'shared/utils/cache_service.dart';
import 'shared/utils/notification_service.dart';
import 'shared/utils/garden_scheduler.dart';

Future<void> _requestStartupPermissions() async {
  if (!Platform.isAndroid) return;
  await [
    Permission.camera,
    Permission.photos,
    Permission.videos,
    Permission.storage,
  ].request();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: 'https://lltbcsnhapqmeyuzgmwj.supabase.co',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      localStorage: SharedPreferencesLocalStorage(
        persistSessionKey: 'supabase_session',
      ),
    ),
  );

  const clearPrefs = String.fromEnvironment('CLEAR_PREFS', defaultValue: 'false');
  if (clearPrefs == 'true') {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_zip');
    await prefs.remove('user_zone');
    await prefs.remove('user_location');
    await prefs.remove('is_guest');
    await prefs.setBool('CLEAR_PREFS_FLAG', true);
    print('🧹 Cleared user preferences (zip, zone, location, guest)');
  }

  final cacheService = await createCacheService();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  await _requestStartupPermissions();

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    ProviderScope(
      overrides: [
        cacheServiceProvider.overrideWithValue(cacheService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const OmniGardenApp(),
    ),
  );
}

class OmniGardenApp extends ConsumerStatefulWidget {
  const OmniGardenApp({super.key});

  @override
  ConsumerState<OmniGardenApp> createState() => _OmniGardenAppState();
}

class _OmniGardenAppState extends ConsumerState<OmniGardenApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        GoRouter.of(rootNavigatorKey.currentContext!).go('/reset-password');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeMode_Provider);

    return MaterialApp.router(
      title: 'OmniGarden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
