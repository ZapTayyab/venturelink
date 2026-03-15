import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/models/startup_model.dart';

class AdminState {
  final bool isActing;
  final AppException? error;
  final Map<String, dynamic>? metrics;

  const AdminState({
    this.isActing = false,
    this.error,
    this.metrics,
  });

  AdminState copyWith({
    bool? isActing,
    AppException? error,
    Map<String, dynamic>? metrics,
    bool clearError = false,
  }) {
    return AdminState(
      isActing: isActing ?? this.isActing,
      error: clearError ? null : (error ?? this.error),
      metrics: metrics ?? this.metrics,
    );
  }
}

final adminRepositoryProvider =
    Provider<AdminRepository>((ref) => AdminRepository());

final pendingStartupsAdminProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.read(adminRepositoryProvider).watchPendingStartups();
});

final allStartupsAdminProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.read(adminRepositoryProvider).watchAllStartups();
});

final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.read(adminRepositoryProvider));
});

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repo;

  AdminNotifier(this._repo) : super(const AdminState());

  Future<void> approveStartup(String startupId, {String? note}) async {
    state = state.copyWith(isActing: true, clearError: true);
    try {
      await _repo.moderateStartup(
          startupId: startupId, action: 'approve', note: note);
      state = state.copyWith(isActing: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isActing: false, error: err);
      rethrow;
    }
  }

  Future<void> rejectStartup(String startupId, {String? note}) async {
    state = state.copyWith(isActing: true, clearError: true);
    try {
      await _repo.moderateStartup(
          startupId: startupId, action: 'reject', note: note);
      state = state.copyWith(isActing: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isActing: false, error: err);
      rethrow;
    }
  }

  Future<void> loadMetrics() async {
    try {
      final data = await _repo.getPlatformMetrics();
      state = state.copyWith(metrics: data);
    } catch (e, stack) {
      ErrorHandler.log('Metrics load failed', error: e, stackTrace: stack);
    }
  }
}