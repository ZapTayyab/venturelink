class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';

  factory AppException.fromFirebase(dynamic e) {
    final code = e.code as String? ?? 'unknown';
    final message = _firebaseErrorMessages[code] ?? e.message ?? 'An error occurred';
    return AppException(message: message, code: code, originalError: e);
  }

  factory AppException.fromFunctions(dynamic e) {
    return AppException(
      message: e.message ?? 'Function call failed',
      code: e.code?.toString(),
      originalError: e,
    );
  }

  factory AppException.network() => const AppException(
        message: 'Network error. Please check your connection.',
        code: 'network-error',
      );

  factory AppException.unknown() => const AppException(
        message: 'An unexpected error occurred.',
        code: 'unknown',
      );

  static const Map<String, String> _firebaseErrorMessages = {
    'user-not-found': 'No user found with this email.',
    'wrong-password': 'Incorrect password.',
    'email-already-in-use': 'This email is already registered.',
    'weak-password': 'Password is too weak. Use at least 6 characters.',
    'invalid-email': 'Please enter a valid email address.',
    'user-disabled': 'This account has been disabled.',
    'too-many-requests': 'Too many attempts. Please try again later.',
    'operation-not-allowed': 'This operation is not allowed.',
    'network-request-failed': 'Network error. Please check your connection.',
    'requires-recent-login': 'Please log in again to continue.',
    'permission-denied': 'You do not have permission to perform this action.',
    'not-found': 'The requested resource was not found.',
    'already-exists': 'This resource already exists.',
    'unauthenticated': 'Please log in to continue.',
  };
}