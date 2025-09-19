import 'package:equatable/equatable.dart';

/// Base state class for feature states
abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial state
class InitialState extends FeatureState {
  const InitialState();
}

/// Loading state
class LoadingState extends FeatureState {
  const LoadingState([this.message]);

  final String? message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Success state with data
class SuccessState<T> extends FeatureState {
  const SuccessState(this.data, [this.message]);

  final T data;
  final String? message;

  @override
  List<Object?> get props => <Object?>[data, message];
}

/// Error state
class ErrorState extends FeatureState {
  const ErrorState(this.message, [this.code, this.details]);

  final String message;
  final String? code;
  final dynamic details;

  @override
  List<Object?> get props => <Object?>[message, code, details];
}

/// Empty state (when no data available)
class EmptyState extends FeatureState {
  const EmptyState([this.message]);

  final String? message;

  @override
  List<Object?> get props => <Object?>[message];
}
