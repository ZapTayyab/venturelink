import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';

class ProfileState {
  final bool isUpdating;
  final AppException? error;

  const ProfileState({this.isUpdating = false, this.error});

  ProfileState copyWith({bool? isUpdating, AppException? error, bool clearError = false}) {
    return ProfileState(
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository());

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.read(profileRepositoryProvider),
    ref,
  );
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repo;
  final Ref _ref;

  ProfileNotifier(this._repo, this._ref) : super(const ProfileState());

  Future<void> updateProfile({required String displayName}) async {
    final uid = _ref.read(authNotifierProvider).user?.uid;
    if (uid == null) return;

    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      await _repo.updateProfile(uid: uid, data: {'displayName': displayName});
      await _ref.read(authNotifierProvider.notifier).updateProfile(
            displayName: displayName,
          );
      state = state.copyWith(isUpdating: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isUpdating: false, error: err);
      rethrow;
    }
  }
}