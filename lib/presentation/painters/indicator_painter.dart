import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/indicators/indicator.dart';
import '../../domain/entities/indicators/moving_average.dart';
import '../../domain/entities/indicators/bollinger_bands.dart';

/// Painter for overlay indicators (MA, Bollinger Bands, etc.)
class OverlayIndicatorPainter extends CustomPainter {
  final List<Candle> candles;
  final List<Indicator> indicators;
  final double verticalScale;
  final double verticalOffset;

  OverlayIndicatorPainter({
    required this.candles,
    required this.indicators,
    this.verticalScale = 1.0,
    this.verticalOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || indicators.isEmpty) return;

    final priceRange = _calculatePriceRange();
    if (priceRange.isEmpty) return;

    final minPrice = priceRange['min']!;
    final maxPrice = priceRange['max']!;
    final priceSpan = maxPrice - minPrice;

    if (priceSpan == 0) return;

    // Apply vertical scale and offset
    final adjustedMinPrice = minPrice - (priceSpan * (verticalScale - 1) / 2) - (verticalOffset * priceSpan / size.height);
    final adjustedMaxPrice = maxPrice + (priceSpan * (verticalScale - 1) / 2) - (verticalOffset * priceSpan / size.height);
    final adjustedPriceSpan = adjustedMaxPrice - adjustedMinPrice;

    final candleWidth = size.width / candles.length;

    // Draw each indicator
    for (final indicator in indicators) {
      if (indicator is MovingAverageIndicator) {
        _drawMovingAverage(
          canvas,
          size,
          indicator,
          candleWidth,
          adjustedMinPrice,
          adjustedPriceSpan,
        );
      } else if (indicator is BollingerBandsIndicator) {
        _drawBollingerBands(
          canvas,
          size,
          indicator,
          candleWidth,
          adjustedMinPrice,
          adjustedPriceSpan,
        );
      }
    }
  }

  void _drawMovingAverage(
    Canvas canvas,
    Size size,
    MovingAverageIndicator indicator,
    double candleWidth,
    double minPrice,
    double priceSpan,
  ) {
    final paint = Paint()
      ..color = _parseColor(indicator.color)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool isFirstPoint = true;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final value = indicator.values[candle.timestamp];

      if (value != null) {
        final x = i * candleWidth + candleWidth / 2;
        final y = _priceToY(value, minPrice, priceSpan, size.height);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawBollingerBands(
    Canvas canvas,
    Size size,
    BollingerBandsIndicator indicator,
    double candleWidth,
    double minPrice,
    double priceSpan,
  ) {
    final color = _parseColor(indicator.color);

    // Paint for bands
    final bandPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Paint for fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Paint for middle line
    final middlePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final upperPath = Path();
    final lowerPath = Path();
    final middlePath = Path();
    final fillPath = Path();

    bool isFirstPoint = true;
    final points = <Offset>[];
    final lowerPoints = <Offset>[];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final upperValue = indicator.upperBand[candle.timestamp];
      final middleValue = indicator.middleBand[candle.timestamp];
      final lowerValue = indicator.lowerBand[candle.timestamp];

      if (upperValue != null && middleValue != null && lowerValue != null) {
        final x = i * candleWidth + candleWidth / 2;
        final upperY = _priceToY(upperValue, minPrice, priceSpan, size.height);
        final middleY = _priceToY(middleValue, minPrice, priceSpan, size.height);
        final lowerY = _priceToY(lowerValue, minPrice, priceSpan, size.height);

        if (isFirstPoint) {
          upperPath.moveTo(x, upperY);
          middlePath.moveTo(x, middleY);
          lowerPath.moveTo(x, lowerY);
          fillPath.moveTo(x, upperY);
          isFirstPoint = false;
        } else {
          upperPath.lineTo(x, upperY);
          middlePath.lineTo(x, middleY);
          lowerPath.lineTo(x, lowerY);
          fillPath.lineTo(x, upperY);
        }

        points.add(Offset(x, upperY));
        lowerPoints.add(Offset(x, lowerY));
      }
    }

    // Complete fill path
    if (lowerPoints.isNotEmpty) {
      for (int i = lowerPoints.length - 1; i >= 0; i--) {
        fillPath.lineTo(lowerPoints[i].dx, lowerPoints[i].dy);
      }
      fillPath.close();

      // Draw fill first
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw bands
    canvas.drawPath(upperPath, bandPaint);
    canvas.drawPath(lowerPath, bandPaint);
    canvas.drawPath(middlePath, middlePaint);
  }

  Map<String, double> _calculatePriceRange() {
    if (candles.isEmpty) return {};

    double minPrice = candles.first.low;
    double maxPrice = candles.first.high;

    for (final candle in candles) {
      if (candle.low < minPrice) minPrice = candle.low;
      if (candle.high > maxPrice) maxPrice = candle.high;
    }

    // Check indicator values too
    for (final indicator in indicators) {
      if (indicator is BollingerBandsIndicator) {
        for (final candle in candles) {
          final upper = indicator.upperBand[candle.timestamp];
          final lower = indicator.lowerBand[candle.timestamp];
          if (upper != null && upper > maxPrice) maxPrice = upper;
          if (lower != null && lower < minPrice) minPrice = lower;
        }
      }
    }

    // Add padding
    final padding = (maxPrice - minPrice) * 0.05;
    minPrice -= padding;
    maxPrice += padding;

    return {
      'min': minPrice,
      'max': maxPrice,
    };
  }

  double _priceToY(double price, double minPrice, double priceSpan, double height) {
    return height - ((price - minPrice) / priceSpan * height);
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  bool shouldRepaint(OverlayIndicatorPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.indicators != indicators ||
        oldDelegate.verticalScale != verticalScale ||
        oldDelegate.verticalOffset != verticalOffset;
  }
}
