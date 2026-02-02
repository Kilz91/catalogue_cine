part of 'progress_bloc.dart';

class _Wrapped<T> {
  final T value;
  const _Wrapped(this.value);
}

class ProgressState {
  final ProgressEntity? progress;
  final bool isLoading;
  final String errorMessage;
  final String successMessage;

  const ProgressState({
    this.progress,
    this.isLoading = false,
    this.errorMessage = '',
    this.successMessage = '',
  });

  ProgressState copyWith({
    Object? progress = const Object(),
    bool? isLoading,
    Object? errorMessage = const Object(),
    Object? successMessage = const Object(),
  }) {
    return ProgressState(
      progress: progress is _Wrapped<ProgressEntity?>
          ? progress.value
          : (progress == const Object() ? this.progress : progress as ProgressEntity?),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage is _Wrapped<String>
          ? errorMessage.value
          : (errorMessage == const Object() ? this.errorMessage : errorMessage as String),
      successMessage: successMessage is _Wrapped<String>
          ? successMessage.value
          : (successMessage == const Object() ? this.successMessage : successMessage as String),
    );
  }
}
