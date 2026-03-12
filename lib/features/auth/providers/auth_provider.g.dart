// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPrefsHash() => r'a6490a34be890da0df529590076bd1ea30b5ea3c';

/// See also [sharedPrefs].
@ProviderFor(sharedPrefs)
final sharedPrefsProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPrefs,
  name: r'sharedPrefsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sharedPrefsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPrefsRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$authStateHash() => r'0b5a658a6b45f7f7b6036f22a6c5d2c1203bcb07';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeFutureProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeFutureProviderRef<AuthState>;
String _$authStateNotifierHash() => r'81af221ff8eaaf9f31feb39ecad9b3b127241612';

/// See also [AuthStateNotifier].
@ProviderFor(AuthStateNotifier)
final authStateNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthStateNotifier, AuthState>.internal(
  AuthStateNotifier.new,
  name: r'authStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthStateNotifier = AutoDisposeAsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
