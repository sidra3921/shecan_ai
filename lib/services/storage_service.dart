import 'dart:io';

import 'supabase_storage_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseStorageService _storage = SupabaseStorageService();

  Future<String> uploadProfilePhoto(String userId, File imageFile) {
    return _storage.uploadProfilePhoto(userId: userId, imageFile: imageFile);
  }
}
