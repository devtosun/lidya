import 'dart:math' as math;

class MathUtils {
  MathUtils._();

  /// Calculate "nice" number for axis scaling
  static double niceNumber(double range, {bool round = true}) {
    final exponent = (math.log(range) / math.ln10).floor();
    final fraction = range / math.pow(10, exponent);

    double niceFraction;
    if (round) {
      if (fraction < 1.5) {
        niceFraction = 1;
      } else if (fraction < 3) {
        niceFraction = 2;
      } else if (fraction < 7) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    } else {
      if (fraction <= 1) {
        niceFraction = 1;
      } else if (fraction <= 2) {
        niceFraction = 2;
      } else if (fraction <= 5) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    }

    return niceFraction * math.pow(10, exponent);
  }

  /// Calculate price steps for axis
  static List<double> calculatePriceSteps({
    required double minPrice,
    required double maxPrice,
    required int targetCount,
  }) {
    final range = maxPrice - minPrice;
    final step = niceNumber(range / (targetCount - 1), round: false);
    final niceMin = (minPrice / step).floor() * step;
    final niceMax = (maxPrice / step).ceil() * step;

    final steps = <double>[];
    double current = niceMin;

    while (current <= niceMax) {
      if (current >= minPrice && current <= maxPrice) {
        steps.add(current);
      }
      current += step;
    }

    return steps;
  }

  /// Linear interpolation
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Clamp value between min and max
  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }

  /// Map value from one range to another
  static double map(
    double value,
    double inMin,
    double inMax,
    double outMin,
    double outMax,
  ) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  /// Calculate distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate angle between two points (in degrees)
  static double angleBetweenPoints(double x1, double y1, double x2, double y2) {
    return math.atan2(y2 - y1, x2 - x1) * 180 / math.pi;
  }

  /// Point to line distance
  static double pointToLineDistance(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    final lineLength = distance(x1, y1, x2, y2);
    if (lineLength == 0) return distance(px, py, x1, y1);

    final t = math.max(
      0,
      math.min(
        1,
        ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / (lineLength * lineLength),
      ),
    );

    final projectionX = x1 + t * (x2 - x1);
    final projectionY = y1 + t * (y2 - y1);

    return distance(px, py, projectionX, projectionY);
  }

  /// Simple Moving Average
  static double sma(List<double> values, int period) {
    if (values.length < period) return 0;
    
    double sum = 0;
    for (int i = values.length - period; i < values.length; i++) {
      sum += values[i];
    }
    return sum / period;
  }

  /// Exponential Moving Average
  static double ema(List<double> values, int period, {double? previousEMA}) {
    if (values.isEmpty) return 0;
    
    final multiplier = 2.0 / (period + 1);
    final currentValue = values.last;
    
    if (previousEMA == null) {
      // First EMA is SMA
      return sma(values.take(period).toList(), period);
    }
    
    return (currentValue - previousEMA) * multiplier + previousEMA;
  }

  /// Standard Deviation
  static double standardDeviation(List<double> values) {
    if (values.isEmpty) return 0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    return math.sqrt(variance);
  }

  /// Round to decimal places
  static double roundToDecimals(double value, int decimals) {
    final factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }

  /// Format price with appropriate decimals
  static String formatPrice(double price, {int? decimals}) {
    final effectiveDecimals = decimals ?? _getOptimalDecimals(price);
    return price.toStringAsFixed(effectiveDecimals);
  }

  static int _getOptimalDecimals(double price) {
    if (price < 0.01) return 8;
    if (price < 1) return 5;
    if (price < 100) return 2;
    return 0;
  }

  /// Percentage change
  static double percentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
}
