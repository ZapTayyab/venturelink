import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../shared/enums/user_role.dart';
import '../../../core/errors/error_handler.dart';
import 'auth_state.dart';
import '../../../shared/models/user_model.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState.initial()) {
    _init();
  }

  void _init() {
  // Safety timeout — if auth stream never fires, unblock after 5s
  Future.delayed(const Duration(seconds: 5), () {
    if (mounted && state.isLoading) {
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  });

  _repo.authStateChanges.listen(
    (firebaseUser) async {
      if (firebaseUser == null) {
        state = state.copyWith(isLoading: false, clearUser: true);
      } else {
        try {
          // Get user document once first (don't wait for stream)
          final userModel = await _repo.getCurrentUserModel();
          if (mounted) {
            if (userModel != null) {
              state = state.copyWith(
                user: userModel,
                isLoading: false,
                clearError: true,
              );
            } else {
              // User exists in Auth but not in Firestore
              // Create a basic profile automatically
              final now = DateTime.now();
              final basicUser = UserModel(
                uid: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                displayName:
                    firebaseUser.displayName ??
                    (firebaseUser.email?.split('@').first ?? 'User'),
                role: UserRole.investor,
                isVerified: false,
                createdAt: now,
                updatedAt: now,
              );
              state = state.copyWith(
                user: basicUser,
                isLoading: false,
                clearError: true,
              );
            }
          }

          // Then keep listening for real-time updates
          _repo.userStream(firebaseUser.uid).listen(
            (updatedUser) {
              if (mounted && updatedUser != null) {
                state = state.copyWith(
                  user: updatedUser,
                  isLoading: false,
                );
              }
            },
            onError: (_) {}, // silent — we already have the user
          );
        } catch (e) {
          if (mounted) {
            state = state.copyWith(isLoading: false, clearUser: true);
          }
        }
      }
    },
    onError: (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, clearUser: true);
      }
    },
  );
}
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isLoading: false, error: err);
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.login(email: email, password: password);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isLoading: false, error: err);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(clearUser: true, isLoading: false);
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isLoading: false, error: err);
      rethrow;
    }
  }

  Future<void> updateProfile({required String displayName}) async {
    final uid = state.user?.uid;
    if (uid == null) return;
    try {
      await _repo.updateProfile(uid: uid, displayName: displayName);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(error: err);
      rethrow;
    }
  }
}