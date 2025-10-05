import 'dart:math' as math;
import 'package:collection/collection.dart';

extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Get last n elements
  List<T> takeLast(int n) {
    if (n >= length) return this;
    return sublist(length - n);
  }

  /// Get first n elements safely
  List<T> takeFirst(int n) {
    if (n >= length) return this;
    return sublist(0, n);
  }

  /// Split list into chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, math.min(i + size, length)));
    }
    return chunks;
  }

  /// Remove nulls from list
  List<T> whereNotNull() {
    return where((element) => element != null).toList();
  }

  /// Find index of element that satisfies condition
  int indexWhereOrNull(bool Function(T element) test) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  /// Group by key
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}

extension NumListExtensions on List<num> {
  /// Calculate sum
  num get sum => isEmpty ? 0 : reduce((a, b) => a + b);

  /// Calculate average
  double get average => isEmpty ? 0 : sum / length;

  /// Find minimum value
  num get min => isEmpty ? 0 : reduce(math.min);

  /// Find maximum value
  num get max => isEmpty ? 0 : reduce(math.max);

  /// Calculate standard deviation
  double get standardDeviation {
    if (isEmpty) return 0;
    final mean = average;
    final variance = map((x) => math.pow(x - mean, 2)).sum / length;
    return math.sqrt(variance);
  }
}