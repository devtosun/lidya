import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../../core/constants/colors.dart' as app_colors;

class CandlePainter extends CustomPainter {
  final List<Candle> candles;
  final double verticalScale;
  final double verticalOffset;
  final Color? bullishColor;
  final Color? bearishColor;
  final double candleSpacing;

  CandlePainter({
    required this.candles,
    this.verticalScale = 1.0,
    this.verticalOffset = 0.0,
    this.bullishColor,
    this.bearishColor,
    this.candleSpacing = 0.1, // 10% spacing between candles
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Calculate price range
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

    // Calculate candle width
    final totalWidth = size.width;
    final candleWidth = totalWidth / candles.length;
    final bodyWidth = candleWidth * (1 - candleSpacing);
    final candleSpacingPixels = candleWidth * candleSpacing;

    // Paint styles
    final bullishPaint = Paint()
      ..color = bullishColor ?? const Color(0xFF26A69A)
      ..style = PaintingStyle.fill;

    final bearishPaint = Paint()
      ..color = bearishColor ?? const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;

    final wickPaint = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Draw each candle
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = i * candleWidth + candleSpacingPixels / 2;

      // Calculate y positions
      final openY = _priceToY(candle.open, adjustedMinPrice, adjustedPriceSpan, size.height);
      final closeY = _priceToY(candle.close, adjustedMinPrice, adjustedPriceSpan, size.height);
      final highY = _priceToY(candle.high, adjustedMinPrice, adjustedPriceSpan, size.height);
      final lowY = _priceToY(candle.low, adjustedMinPrice, adjustedPriceSpan, size.height);

      final isBullish = candle.isBullish;
      final paint = isBullish ? bullishPaint : bearishPaint;
      wickPaint.color = paint.color;

      // Draw wick (high to low line)
      final wickX = x + bodyWidth / 2;
      canvas.drawLine(
        Offset(wickX, highY),
        Offset(wickX, lowY),
        wickPaint,
      );

      // Draw body
      final bodyTop = isBullish ? closeY : openY;
      final bodyBottom = isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs();

      // Minimum body height for visibility
      final minBodyHeight = 1.0;
      final actualBodyHeight = bodyHeight < minBodyHeight ? minBodyHeight : bodyHeight;

      final rect = Rect.fromLTWH(
        x,
        bodyTop,
        bodyWidth,
        actualBodyHeight,
      );

      // For very small candles (doji), draw a line instead of rectangle
      if (bodyHeight < 2.0) {
        canvas.drawLine(
          Offset(x, bodyTop),
          Offset(x + bodyWidth, bodyTop),
          Paint()
            ..color = paint.color
            ..strokeWidth = 1.5,
        );
      } else {
        canvas.drawRect(rect, paint);

        // Draw border for hollow candles (optional)
        if (isBullish) {
          canvas.drawRect(
            rect,
            Paint()
              ..color = paint.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      }
    }
  }

  Map<String, double> _calculatePriceRange() {
    if (candles.isEmpty) return {};

    double minPrice = candles.first.low;
    double maxPrice = candles.first.high;

    for (final candle in candles) {
      if (candle.low < minPrice) minPrice = candle.low;
      if (candle.high > maxPrice) maxPrice = candle.high;
    }

    // Add padding (5% on each side)
    final padding = (maxPrice - minPrice) * 0.05;
    minPrice -= padding;
    maxPrice += padding;

    return {
      'min': minPrice,
      'max': maxPrice,
    };
  }

  double _priceToY(double price, double minPrice, double priceSpan, double height) {
    // Invert Y axis (higher price = lower Y coordinate)
    return height - ((price - minPrice) / priceSpan * height);
  }

  @override
  bool shouldRepaint(CandlePainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.verticalScale != verticalScale ||
        oldDelegate.verticalOffset != verticalOffset ||
        oldDelegate.bullishColor != bullishColor ||
        oldDelegate.bearishColor != bearishColor;
  }
}
