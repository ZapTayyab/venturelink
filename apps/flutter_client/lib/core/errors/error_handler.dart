import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'app_exception.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8),
);

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      _logger.e('Error caught', error: error, stackTrace: stackTrace);
    }

    if (error is AppException) return error;

    if (error is FirebaseAuthException) {
      return AppException.fromFirebase(error);
    }

    if (error is FirebaseException) {
      return AppException.fromFirebase(error);
    }

    return AppException(
      message: error?.toString() ?? 'Unknown error',
      code: 'unknown',
      originalError: error,
    );
  }

  static void log(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void logWarning(String message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }
}