import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';

class StorageService {
  StorageService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadStartupLogo({
    required String startupId,
    required Uint8List bytes,
    required String extension,
  }) async {
    try {
      final ref = _storage.ref('startups/$startupId/logo.$extension');
      final metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {'startupId': startupId},
      );
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e, stack) {
      ErrorHandler.log('Upload logo failed', error: e, stackTrace: stack);
      throw const AppException(
        message: 'Failed to upload image. Please try again.',
        code: 'upload-failed',
      );
    }
  }

  static Future<String?> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
    required String extension,
  }) async {
    try {
      final ref = _storage.ref('users/$uid/avatar.$extension');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$extension'),
      );
      return await ref.getDownloadURL();
    } catch (e, stack) {
      ErrorHandler.log('Upload avatar failed', error: e, stackTrace: stack);
      throw const AppException(
        message: 'Failed to upload photo.',
        code: 'upload-failed',
      );
    }
  }

  static Future<void> deleteFile(String gsUrl) async {
    try {
      await _storage.refFromURL(gsUrl).delete();
    } catch (e) {
      ErrorHandler.logWarning('Delete file failed: $e');
    }
  }
}