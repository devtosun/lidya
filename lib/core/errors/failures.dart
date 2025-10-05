import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

/// Data failures
class DataFailure extends Failure {
  const DataFailure(String message, {String? code}) : super(message, code: code);
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code}) : super(message, code: code);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code}) : super(message, code: code);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code}) : super(message, code: code);
}

/// Server failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code}) : super(message, code: code);
}