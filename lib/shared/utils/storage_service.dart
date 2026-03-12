import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) => StorageService();

class StorageService {
  final _client = Supabase.instance.client;
  final _bucket = 'journal-photos';

  Future<String> uploadJournalPhoto({
    required File file,
    required String gardenId,
  }) async {
    final userId    = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not signed in');

    final ext      = file.path.split('.').last;
    final fileName = '${userId}/${gardenId}/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(_bucket).upload(
      fileName,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    return _client.storage.from(_bucket).getPublicUrl(fileName);
  }

  Future<String?> uploadGardenCoverPhoto({required File file}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return null;
      final fileName = 'garden_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/gardens/$fileName';
      await Supabase.instance.client.storage
          .from('journal-photos')
          .upload(path, file);
      return Supabase.instance.client.storage
          .from('journal-photos')
          .getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  Future<void> deletePhoto(String publicUrl) async {
    // Extract path from public URL
    final uri  = Uri.parse(publicUrl);
    final path = uri.pathSegments.skipWhile((s) => s != _bucket).skip(1).join('/');
    await _client.storage.from(_bucket).remove([path]);
  }

  Future<String?> uploadJournalVideo({required File file, required String gardenId}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return null;
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = '$userId/$gardenId/$fileName';
      await Supabase.instance.client.storage
          .from('journal-photos')
          .upload(path, file,
              fileOptions: const FileOptions(
                contentType: 'video/mp4',
                cacheControl: '3600',
              ));
      return Supabase.instance.client.storage
          .from('journal-photos')
          .getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }
}
