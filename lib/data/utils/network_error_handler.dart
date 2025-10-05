// data/utils/network_error_handler.dart
import 'dart:async';
import 'dart:io';

class NetworkErrorHandler {
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          rethrow;
        }
        
        if (_shouldRetry(e)) {
          await Future.delayed(retryDelay * attempt);
          continue;
        }
        
        rethrow;
      }
    }
  }

  static bool _shouldRetry(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HttpException) return true;
    
    return false;
  }
}