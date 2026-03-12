import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'dart:async';

import '../models/app_user.dart';
import '../../../shared/utils/supabase_service.dart';
import '../../../shared/utils/garden_scheduler.dart';

part 'auth_provider.g.dart';

@riverpod
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) =>
    SharedPreferences.getInstance();

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  static const _zipKey  = 'user_zip';
  static const _zoneKey = 'user_zone';
  static const _guestKey = 'is_guest';

  final _client = Supabase.instance.client;

  @override
  Future<AuthState> build() async {
    final prefs = await ref.watch(sharedPrefsProvider.future);
    final isGuest = prefs.getBool(_guestKey) ?? false;

    // Listen to auth state changes and rebuild when they fire
    ref.listen(authStateNotifierProvider, (_, __) {});
  
    // Subscribe to Supabase auth stream — this triggers rebuild on sign in/out
    final completer = Completer<void>();
    late StreamSubscription sub;
    sub = _client.auth.onAuthStateChange.listen((data) {
      sub.cancel();
      completer.complete();
    });
  
  // Wait up to 3 seconds for session restore, then continue
  await completer.future.timeout(
    const Duration(seconds: 3),
    onTimeout: () {},
  );
  
  final session = _client.auth.currentSession;
  final user = session?.user != null
      ? AppUser(id: session!.user.id, email: session.user.email ?? '')
      : null;

  String? zip = prefs.getString(_zipKey);
  String? zone = prefs.getString(_zoneKey);
  String? location = prefs.getString('user_location');

  if (user != null && (zip == null || zone == null)) {
    final profile = await _fetchProfile(user.id);
    if (profile != null) {
      zip = profile['zip'];
      zone = profile['zone'];
      location = profile['location'];
      if (zip != null) await prefs.setString(_zipKey, zip);
      if (zone != null) await prefs.setString(_zoneKey, zone);
      if (location != null) await prefs.setString('user_location', location);
    }
  }

  // Keep listening for future auth changes
  _client.auth.onAuthStateChange.listen((data) {
    final supaUser = data.session?.user;
    if (supaUser != null) {
      final current = state.value ?? const AuthState();
      state = AsyncData(current.copyWith(
        user: AppUser(id: supaUser.id, email: supaUser.email ?? ''),
        isGuest: false,
      ));
    } else if (data.event == AuthChangeEvent.signedOut) {
      final current = state.value ?? const AuthState();
      state = AsyncData(current.copyWith(user: null));
    }
  });

  if (user != null) {
    unawaited(ref.read(gardenSchedulerProvider).scheduleAll(user.id, zone ?? 'Zone 6a'));
  }

  print('AUTH BUILD: zip=$zip zone=$zone location=$location user=${user?.id}');

  return AuthState(
    user: user,
    isGuest: isGuest,
    zip: zip,
    zone: zone,
    location: location,
  );
}

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select('zip, zone, location')
          .eq('id', userId)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).signUp(
        email: email, password: password,
      );
      final current = state.value ?? const AuthState();
      return current.copyWith(user: user, isGuest: false);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).signIn(
        email: email, password: password,
      );
      final prefs = await ref.read(sharedPrefsProvider.future);

      // Load zip/zone from Supabase on every login
      String? zip  = prefs.getString(_zipKey);
      String? zone = prefs.getString(_zoneKey);
      String? location = prefs.getString('user_location');

      if (user != null && (zip == null || zone == null)) {
        final profile = await _fetchProfile(user.id);
        if (profile != null) {
          zip  = profile['zip'];
          zone = profile['zone'];
          location = profile['location'];
          if (zip  != null) await prefs.setString(_zipKey,  zip);
          if (zone != null) await prefs.setString(_zoneKey, zone);
          if (location != null) await prefs.setString('user_location', location);
        }
      }

      final current = state.value ?? const AuthState();
      
      // Schedule garden notifications
      if (user != null) {
        final scheduler = ref.read(gardenSchedulerProvider);
        unawaited(scheduler.scheduleAll(user.id, zone ?? 'Zone 6a'));
      }
      
      return current.copyWith(user: user, isGuest: false, zip: zip, zone: zone, location: location);
    });
  }

  Future<void> continueAsGuest() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setBool(_guestKey, true);
    final current = state.value ?? const AuthState();
    state = AsyncData(current.copyWith(isGuest: true));
  }

  // Called after zip entry screen — saves to both Supabase and local cache
  Future<void> saveZip(String zip, String zone, {String? location}) async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setString(_zipKey,  zip);
    await prefs.setString(_zoneKey, zone);
    if (location != null) await prefs.setString('user_location', location);

    // Persist to Supabase so it survives reinstalls / new devices
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('profiles').upsert({
        'id':       userId,
        'zip':      zip,
        'zone':     zone,
        'location': location,
      });
    }

    final current = state.value ?? const AuthState();
    state = AsyncData(current.copyWith(zip: zip, zone: zone, location: location));
  }

  Future<void> deleteAccount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      // Delete all user data from tables
      await _client.from('gardens').delete().eq('user_id', userId);
      await _client.from('garden_plants').delete().eq('user_id', userId);
      await _client.from('journal_entries').delete().eq('user_id', userId);
      await _client.from('profiles').delete().eq('id', userId);
      
      // Clear local preferences
      final prefs = await ref.read(sharedPrefsProvider.future);
      await prefs.clear();
      
      // Sign out
      await signOut();
      
    } catch (e) {
      // Re-throw for UI to handle
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    final prefs = await ref.read(sharedPrefsProvider.future);
    
    // Clear all locally cached user data
    await prefs.remove('user_zip');
    await prefs.remove('user_zone');
    await prefs.remove('user_location');
    await prefs.remove(_guestKey);
    
    final current = state.value ?? const AuthState();
    state = AsyncData(current.copyWith(
      user: null, 
      isGuest: false,
      zip: null,
      zone: null,
      location: null,
    ));
  }
}

@riverpod
Future<AuthState> authState(AuthStateRef ref) =>
    ref.watch(authStateNotifierProvider.future);
