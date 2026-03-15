import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/round_repository.dart';
import '../../../core/errors/error_handler.dart';
import 'round_state.dart';

final roundRepositoryProvider = Provider<RoundRepository>((ref) => RoundRepository());

final startupRoundsProvider =
    StreamProvider.family<List<dynamic>, String>((ref, startupId) {
  return ref.read(roundRepositoryProvider).watchStartupRounds(startupId);
});

final openRoundsProvider = StreamProvider<List<dynamic>>((ref) {
  return ref.read(roundRepositoryProvider).watchOpenRounds();
});

final roundDetailProvider =
    StreamProvider.family<dynamic, String>((ref, roundId) {
  return ref.read(roundRepositoryProvider).watchRound(roundId);
});

final roundFormNotifierProvider =
    StateNotifierProvider<RoundFormNotifier, RoundFormState>((ref) {
  return RoundFormNotifier(ref.read(roundRepositoryProvider));
});

class RoundFormNotifier extends StateNotifier<RoundFormState> {
  final RoundRepository _repo;

  RoundFormNotifier(this._repo) : super(const RoundFormState());

  Future<void> createRound(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.createRound(data);
      state = state.copyWith(isSubmitting: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isSubmitting: false, error: err);
      rethrow;
    }
  }

  Future<void> updateRound(String roundId, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.updateRound(roundId, data);
      state = state.copyWith(isSubmitting: false);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isSubmitting: false, error: err);
      rethrow;
    }
  }
}