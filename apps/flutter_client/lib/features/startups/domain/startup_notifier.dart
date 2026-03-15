import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/startup_repository.dart';
import '../../../core/errors/error_handler.dart';
import 'startup_state.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) => StartupRepository());

final approvedStartupsProvider = StreamProvider<List<dynamic>>((ref) {
  return ref.read(startupRepositoryProvider).watchApprovedStartups();
});

final founderStartupsProvider = StreamProvider.family<List<dynamic>, String>((ref, uid) {
  return ref.read(startupRepositoryProvider).watchFounderStartups(uid);
});

final pendingStartupsProvider = StreamProvider<List<dynamic>>((ref) {
  return ref.read(startupRepositoryProvider).watchPendingStartups();
});

final startupDetailProvider = StreamProvider.family<dynamic, String>((ref, startupId) {
  return ref.read(startupRepositoryProvider).watchStartup(startupId);
});

final startupFormNotifierProvider =
    StateNotifierProvider<StartupFormNotifier, StartupDetailState>((ref) {
  return StartupFormNotifier(ref.read(startupRepositoryProvider));
});

class StartupFormNotifier extends StateNotifier<StartupDetailState> {
  final StartupRepository _repo;

  StartupFormNotifier(this._repo) : super(const StartupDetailState());

  Future<void> createStartup(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.createStartup(data);
      state = state.copyWith(isSubmitting: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isSubmitting: false, error: err);
      rethrow;
    }
  }

  Future<void> updateStartup(String startupId, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.updateStartup(startupId, data);
      state = state.copyWith(isSubmitting: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isSubmitting: false, error: err);
      rethrow;
    }
  }

  Future<void> deleteStartup(String startupId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.deleteStartup(startupId);
      state = state.copyWith(isSubmitting: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isSubmitting: false, error: err);
      rethrow;
    }
  }
}