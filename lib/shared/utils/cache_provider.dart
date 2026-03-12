import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// Call this in main.dart to initialize
Future<CacheService> createCacheService() async {
  final prefs = await SharedPreferences.getInstance();
  return CacheService(prefs);
}
