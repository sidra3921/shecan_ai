import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

class SupabaseStorageService {
  static final SupabaseStorageService _instance =
      SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  final _supabase = Supabase.instance.client;

  // Storage bucket names
  static const String profilePhotosBucket = 'profile-photos';
  static const String projectPhotosBucket = 'project-photos';
  static const String documentsBucket = 'documents';
  static const String videosBucket = 'videos';

  // ==================== PROFILE PHOTOS ====================

  /// Upload user profile photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final filePath = '$userId/profile.jpg';

      // Delete old photo if exists
      try {
        await _supabase.storage
            .from(profilePhotosBucket)
            .remove([filePath]);
      } catch (e) {
        // File might not exist, ignore error
      }

      // Upload new photo
      await _supabase.storage
          .from(profilePhotosBucket)
          .upload(filePath, imageFile);

      // Get public URL
      final url = _supabase.storage
          .from(profilePhotosBucket)
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Upload user profile photo from bytes (web-friendly)
  Future<String> uploadProfilePhotoBytes({
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final filePath = '$userId/profile.jpg';

      try {
        await _supabase.storage.from(profilePhotosBucket).remove([filePath]);
      } catch (_) {
        // File might not exist, ignore error
      }

      await _supabase.storage
          .from(profilePhotosBucket)
          .uploadBinary(filePath, bytes);

      return _supabase.storage.from(profilePhotosBucket).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Get profile photo URL
  String getProfilePhotoUrl(String userId) {
    final filePath = '$userId/profile.jpg';
    return _supabase.storage
        .from(profilePhotosBucket)
        .getPublicUrl(filePath);
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final filePath = '$userId/profile.jpg';
      await _supabase.storage
          .from(profilePhotosBucket)
          .remove([filePath]);
    } catch (e) {
      print('Error deleting profile photo: $e');
    }
  }

  // ==================== PROJECT PHOTOS ====================

  /// Upload project photo
  Future<String> uploadProjectPhoto({
    required String projectId,
    required File imageFile,
    int photoIndex = 0,
  }) async {
    try {
      final fileName = 'project_${projectId}_photo_$photoIndex.jpg';
      final filePath = 'project_photos/$fileName';

      await _supabase.storage
          .from(projectPhotosBucket)
          .upload(filePath, imageFile);

      final url = _supabase.storage
          .from(projectPhotosBucket)
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload project photo: $e');
    }
  }

  /// Get project photo URL
  String getProjectPhotoUrl(String projectId, int photoIndex) {
    final fileName = 'project_${projectId}_photo_$photoIndex.jpg';
    final filePath = 'project_photos/$fileName';
    return _supabase.storage
        .from(projectPhotosBucket)
        .getPublicUrl(filePath);
  }

  /// Upload multiple project photos
  Future<List<String>> uploadProjectPhotos({
    required String projectId,
    required List<File> imageFiles,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final url = await uploadProjectPhoto(
          projectId: projectId,
          imageFile: imageFiles[i],
          photoIndex: i,
        );
        urls.add(url);
      } catch (e) {
        print('Error uploading photo $i: $e');
      }
    }
    return urls;
  }

  // ==================== DOCUMENTS ====================

  /// Upload document
  Future<String> uploadDocument({
    required String userId,
    required String documentName,
    required File documentFile,
  }) async {
    try {
      final fileName = '${userId}_$documentName';
      final filePath = 'documents/$fileName';

      await _supabase.storage
          .from(documentsBucket)
          .upload(filePath, documentFile);

      final url = _supabase.storage
          .from(documentsBucket)
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Download document
  Future<List<int>> downloadDocument(String filePath) async {
    try {
      final data = await _supabase.storage
          .from(documentsBucket)
          .download(filePath);
      return data;
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }

  /// Delete document
  Future<void> deleteDocument(String filePath) async {
    try {
      await _supabase.storage
          .from(documentsBucket)
          .remove([filePath]);
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  // ==================== VIDEOS ====================

  /// Upload video
  Future<String> uploadVideo({
    required String projectId,
    required File videoFile,
  }) async {
    try {
      final fileName = 'project_${projectId}_video.mp4';
      final filePath = 'videos/$fileName';

      await _supabase.storage
          .from(videosBucket)
          .upload(filePath, videoFile);

      final url = _supabase.storage
          .from(videosBucket)
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  /// Get video URL
  String getVideoUrl(String projectId) {
    final fileName = 'project_${projectId}_video.mp4';
    final filePath = 'videos/$fileName';
    return _supabase.storage
        .from(videosBucket)
        .getPublicUrl(filePath);
  }

  /// Delete video
  Future<void> deleteVideo(String projectId) async {
    try {
      final fileName = 'project_${projectId}_video.mp4';
      final filePath = 'videos/$fileName';
      await _supabase.storage
          .from(videosBucket)
          .remove([filePath]);
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  // ==================== GENERIC OPERATIONS ====================

  /// Get file from any bucket
  Future<List<int>> getFile(String bucket, String filePath) async {
    try {
      return await _supabase.storage.from(bucket).download(filePath);
    } catch (e) {
      throw Exception('Failed to get file: $e');
    }
  }

  /// Upload file to any bucket
  Future<String> uploadFile({
    required String bucket,
    required String filePath,
    required File file,
  }) async {
    try {
      await _supabase.storage.from(bucket).upload(filePath, file);
      return _supabase.storage.from(bucket).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Delete file from bucket
  Future<void> deleteFile(String bucket, String filePath) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  /// List files in bucket folder
  Future<List<FileObject>> listFiles(String bucket, String folderPath) async {
    try {
      return await _supabase.storage.from(bucket).list(path: folderPath);
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}
