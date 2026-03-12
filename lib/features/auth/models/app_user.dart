// lib/features/auth/models/app_user.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    @Default(false) bool isGuest,
    String? displayName,
    String? avatarUrl,
    String? zip,
    String? zone,
    String? location,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

// Phase 2: uncomment when Supabase is live
// extension AppUserX on AppUser {
//   static AppUser fromSupabaseUser(supabase.User user) => AppUser(
//     id: user.id,
//     email: user.email ?? '',
//     displayName: user.userMetadata?['full_name'] as String?,
//     avatarUrl: user.userMetadata?['avatar_url'] as String?,
//   );
// }

/// Represents the full auth state passed through the router
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    AppUser? user,
    @Default(false) bool isGuest,
    String? zip,
    String? zone,
    String? location,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => user != null;
  bool get hasZip => zip != null && zip!.isNotEmpty;
}
