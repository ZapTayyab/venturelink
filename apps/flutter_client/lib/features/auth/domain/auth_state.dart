import '../../../shared/models/user_model.dart';
import '../../../core/errors/app_exception.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final AppException? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  const AuthState.initial() : user = null, isLoading = true, error = null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    AppException? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isAuthenticated => user != null;
}