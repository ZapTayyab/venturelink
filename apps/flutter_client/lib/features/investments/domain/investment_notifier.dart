import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/investment_repository.dart';
import '../../../core/errors/error_handler.dart';
import 'investment_state.dart';

final investmentRepositoryProvider =
    Provider<InvestmentRepository>((ref) => InvestmentRepository());

final myInvestmentsProvider =
    StreamProvider.family<List<dynamic>, String>((ref, investorId) {
  return ref
      .read(investmentRepositoryProvider)
      .watchInvestorInvestments(investorId);
});

final investFormNotifierProvider =
    StateNotifierProvider<InvestFormNotifier, InvestFormState>((ref) {
  return InvestFormNotifier(ref.read(investmentRepositoryProvider));
});

class InvestFormNotifier extends StateNotifier<InvestFormState> {
  final InvestmentRepository _repo;

  InvestFormNotifier(this._repo) : super(const InvestFormState());

  Future<void> invest(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true, success: false);
    try {
      await _repo.makeInvestment(data);
      state = state.copyWith(isSubmitting: false, success: true);
    } catch (e, stack) {
      final err = ErrorHandler.handle(e, stack);
      state = state.copyWith(isSubmitting: false, error: err);
      rethrow;
    }
  }
}