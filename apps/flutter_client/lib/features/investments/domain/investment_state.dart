import '../../../shared/models/investment_model.dart';
import '../../../core/errors/app_exception.dart';

class InvestmentListState {
  final List<InvestmentModel> investments;
  final bool isLoading;
  final AppException? error;

  const InvestmentListState({
    this.investments = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalInvested =>
      investments.fold(0, (sum, i) => sum + i.amount);

  InvestmentListState copyWith({
    List<InvestmentModel>? investments,
    bool? isLoading,
    AppException? error,
    bool clearError = false,
  }) {
    return InvestmentListState(
      investments: investments ?? this.investments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class InvestFormState {
  final bool isSubmitting;
  final bool success;
  final AppException? error;

  const InvestFormState({
    this.isSubmitting = false,
    this.success = false,
    this.error,
  });

  InvestFormState copyWith({
    bool? isSubmitting,
    bool? success,
    AppException? error,
    bool clearError = false,
  }) {
    return InvestFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }
}