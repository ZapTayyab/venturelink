import '../../../shared/models/funding_round_model.dart';
import '../../../core/errors/app_exception.dart';

class RoundListState {
  final List<FundingRoundModel> rounds;
  final bool isLoading;
  final AppException? error;

  const RoundListState({
    this.rounds = const [],
    this.isLoading = false,
    this.error,
  });

  RoundListState copyWith({
    List<FundingRoundModel>? rounds,
    bool? isLoading,
    AppException? error,
    bool clearError = false,
  }) {
    return RoundListState(
      rounds: rounds ?? this.rounds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RoundFormState {
  final bool isSubmitting;
  final AppException? error;

  const RoundFormState({
    this.isSubmitting = false,
    this.error,
  });

  RoundFormState copyWith({
    bool? isSubmitting,
    AppException? error,
    bool clearError = false,
  }) {
    return RoundFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}