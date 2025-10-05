import 'dart:math' as math;
import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  /// Round to specific decimal places
  double roundToDecimals(int decimals) {
    final factor = math.pow(10, decimals);
    return (this * factor).round() / factor;
  }

  /// Format as price
  String toPrice({int? decimals}) {
    final effectiveDecimals = decimals ?? _getOptimalDecimals();
    return toStringAsFixed(effectiveDecimals);
  }

  int _getOptimalDecimals() {
    if (this < 0.01) return 8;
    if (this < 1) return 5;
    if (this < 100) return 2;
    return 0;
  }

  /// Format with thousands separator
  String toFormattedString({int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}');
    return formatter.format(this);
  }

  /// Format as percentage
  String toPercentage({int decimals = 2}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Clamp between min and max
  double clampValue(double min, double max) {
    return math.max(min, math.min(max, this));
  }

  /// Check if approximately equal
  bool isApproximately(double other, {double epsilon = 0.0001}) {
    return (this - other).abs() < epsilon;
  }

  /// Check if in range
  bool inRange(double min, double max) {
    return this >= min && this <= max;
  }
}