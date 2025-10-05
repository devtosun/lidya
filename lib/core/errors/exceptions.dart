abstract class ChartException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const ChartException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write(runtimeType)
      ..write(': ')
      ..write(message);

    if (code != null) {
      buffer.write(' (code: $code)');
    }

    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }

    return buffer.toString();
  }
}

/// Chart data related exceptions
class ChartDataException extends ChartException {
  const ChartDataException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Network related exceptions
class NetworkException extends ChartException {
  const NetworkException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Coordinate transformation exceptions
class CoordinateException extends ChartException {
  const CoordinateException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Indicator calculation exceptions
class IndicatorException extends ChartException {
  const IndicatorException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Drawing tool exceptions
class DrawingToolException extends ChartException {
  const DrawingToolException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Parsing/Serialization exceptions
class ParseException extends ChartException {
  const ParseException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Cache exceptions
class CacheException extends ChartException {
  const CacheException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Unsupported operation exception
class UnsupportedOperationException extends ChartException {
  const UnsupportedOperationException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}