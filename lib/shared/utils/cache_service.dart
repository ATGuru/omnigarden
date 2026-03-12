import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _ttl = Duration(days: 1);

  final SharedPreferences _prefs;
  CacheService(this._prefs);

  // ── Write ────────────────────────────────────────────────
  Future<void> set(String key, dynamic data) async {
    final payload = jsonEncode({
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
    await _prefs.setString(key, payload);
  }

  // ── Read (returns null if missing or expired) ────────────
  T? get<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.fromMillisecondsSinceEpoch(payload['ts'] as int);
      if (DateTime.now().difference(ts) > _ttl) return null;
      return payload['data'] as T;
    } catch (_) {
      return null;
    }
  }

  // ── Invalidate ───────────────────────────────────────────
  Future<void> invalidate(String key) async {
    await _prefs.remove(key);
  }

  Future<void> invalidatePrefix(String prefix) async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(prefix));
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  // ── Keys ─────────────────────────────────────────────────
  static String searchKey(String query) => 'cache:search:$query';
  static String gardenPlantsKey(String gardenId) => 'cache:garden_plants:$gardenId';
  static String journalKey(String gardenId) => 'cache:journal:$gardenId';
}
