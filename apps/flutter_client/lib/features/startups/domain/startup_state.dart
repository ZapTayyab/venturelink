import '../../../shared/models/startup_model.dart';
import '../../../core/errors/app_exception.dart';

class StartupListState {
  final List<StartupModel> startups;
  final bool isLoading;
  final AppException? error;

  const StartupListState({
    this.startups = const [],
    this.isLoading = false,
    this.error,
  });

  StartupListState copyWith({
    List<StartupModel>? startups,
    bool? isLoading,
    AppException? error,
    bool clearError = false,
  }) {
    return StartupListState(
      startups: startups ?? this.startups,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StartupDetailState {
  final StartupModel? startup;
  final bool isLoading;
  final AppException? error;
  final bool isSubmitting;

  const StartupDetailState({
    this.startup,
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  StartupDetailState copyWith({
    StartupModel? startup,
    bool? isLoading,
    AppException? error,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return StartupDetailState(
      startup: startup ?? this.startup,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}