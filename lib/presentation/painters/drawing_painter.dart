import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/drawing/drawing.dart';
import '../../domain/entities/drawing/trendline_drawing.dart';
import '../../domain/entities/drawing/fibonacci_drawing.dart';
import '../../domain/entities/drawing/freehand_drawing.dart';

/// Painter for chart drawings (trendlines, fibonacci, etc.)
class DrawingPainter extends CustomPainter {
  final List<Candle> candles;
  final List<Drawing> drawings;
  final Drawing? draftDrawing;
  final String? selectedDrawingId;
  final double verticalScale;
  final double verticalOffset;

  DrawingPainter({
    required this.candles,
    required this.drawings,
    this.draftDrawing,
    this.selectedDrawingId,
    this.verticalScale = 1.0,
    this.verticalOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

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

    // Draw all permanent drawings
    for (final drawing in drawings) {
      _drawDrawing(canvas, size, drawing, adjustedMinPrice, adjustedPriceSpan, false);
    }

    // Draw draft drawing (preview)
    if (draftDrawing != null) {
      _drawDrawing(canvas, size, draftDrawing!, adjustedMinPrice, adjustedPriceSpan, true);
    }
  }

  void _drawDrawing(
    Canvas canvas,
    Size size,
    Drawing drawing,
    double minPrice,
    double priceSpan,
    bool isDraft,
  ) {
    if (drawing is TrendlineDrawing) {
      _drawTrendline(canvas, size, drawing, minPrice, priceSpan, isDraft);
    } else if (drawing is FibonacciDrawing) {
      _drawFibonacci(canvas, size, drawing, minPrice, priceSpan, isDraft);
    } else if (drawing is FreehandDrawing) {
      _drawFreehand(canvas, size, drawing, minPrice, priceSpan, isDraft);
    }
  }

  void _drawTrendline(
    Canvas canvas,
    Size size,
    TrendlineDrawing drawing,
    double minPrice,
    double priceSpan,
    bool isDraft,
  ) {
    if (drawing.points.length < 2) return;

    final startPoint = drawing.points[0];
    final endPoint = drawing.points[1];

    final startOffset = _pointToOffset(startPoint.timestamp, startPoint.price, minPrice, priceSpan, size);
    final endOffset = _pointToOffset(endPoint.timestamp, endPoint.price, minPrice, priceSpan, size);

    if (startOffset == null || endOffset == null) return;

    final paint = Paint()
      ..color = _parseColor(drawing.color).withOpacity(isDraft ? 0.5 : 1.0)
      ..strokeWidth = drawing.strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(startOffset, endOffset, paint);

    // Draw selection handles if selected
    if (!isDraft && drawing.id == selectedDrawingId) {
      _drawSelectionHandles(canvas, [startOffset, endOffset]);
    }
  }

  void _drawFibonacci(
    Canvas canvas,
    Size size,
    FibonacciDrawing drawing,
    double minPrice,
    double priceSpan,
    bool isDraft,
  ) {
    if (drawing.points.length < 2) return;

    final startPoint = drawing.points[0];
    final endPoint = drawing.points[1];

    final startOffset = _pointToOffset(startPoint.timestamp, startPoint.price, minPrice, priceSpan, size);
    final endOffset = _pointToOffset(endPoint.timestamp, endPoint.price, minPrice, priceSpan, size);

    if (startOffset == null || endOffset == null) return;

    final color = _parseColor(drawing.color).withOpacity(isDraft ? 0.5 : 1.0);

    // Fibonacci levels
    final levels = [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0];
    final levelNames = ['0%', '23.6%', '38.2%', '50%', '61.8%', '78.6%', '100%'];

    final priceStart = startPoint.price;
    final priceEnd = endPoint.price;
    final priceDiff = priceEnd - priceStart;

    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      final price = priceStart + (priceDiff * level);
      final y = _priceToY(price, minPrice, priceSpan, size.height);

      // Draw horizontal line
      final paint = Paint()
        ..color = color
        ..strokeWidth = i == 0 || i == levels.length - 1 ? 2.0 : 1.0
        ..style = PaintingStyle.stroke;

      if (i > 0 && i < levels.length - 1) {
        paint.color = color.withOpacity(0.5);
      }

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );

      // Draw level label
      final textSpan = TextSpan(
        text: levelNames[i],
        style: TextStyle(
          color: color,
          fontSize: 10,
          backgroundColor: const Color(0xFF1E222D).withOpacity(0.7),
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - textPainter.height / 2));
    }

    // Draw selection handles if selected
    if (!isDraft && drawing.id == selectedDrawingId) {
      _drawSelectionHandles(canvas, [startOffset, endOffset]);
    }
  }

  void _drawFreehand(
    Canvas canvas,
    Size size,
    FreehandDrawing drawing,
    double minPrice,
    double priceSpan,
    bool isDraft,
  ) {
    if (drawing.points.isEmpty) return;

    final paint = Paint()
      ..color = _parseColor(drawing.color).withOpacity(isDraft ? 0.5 : 1.0)
      ..strokeWidth = drawing.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool isFirst = true;

    for (final point in drawing.points) {
      final offset = _pointToOffset(point.timestamp, point.price, minPrice, priceSpan, size);
      if (offset != null) {
        if (isFirst) {
          path.moveTo(offset.dx, offset.dy);
          isFirst = false;
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawSelectionHandles(Canvas canvas, List<Offset> points) {
    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final point in points) {
      canvas.drawCircle(point, 5, handlePaint);
      canvas.drawCircle(point, 5, borderPaint);
    }
  }

  Offset? _pointToOffset(DateTime timestamp, double price, double minPrice, double priceSpan, Size size) {
    // Find the candle index for this timestamp
    final candleIndex = _findCandleIndex(timestamp);
    if (candleIndex == -1) return null;

    final candleWidth = size.width / candles.length;
    final x = candleIndex * candleWidth + candleWidth / 2;
    final y = _priceToY(price, minPrice, priceSpan, size.height);

    return Offset(x, y);
  }

  int _findCandleIndex(DateTime timestamp) {
    for (int i = 0; i < candles.length; i++) {
      if (candles[i].timestamp == timestamp) {
        return i;
      }
    }

    // Find closest candle
    int closestIndex = -1;
    Duration closestDiff = const Duration(days: 365);

    for (int i = 0; i < candles.length; i++) {
      final diff = (candles[i].timestamp.difference(timestamp)).abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  Map<String, double> _calculatePriceRange() {
    if (candles.isEmpty) return {};

    double minPrice = candles.first.low;
    double maxPrice = candles.first.high;

    for (final candle in candles) {
      if (candle.low < minPrice) minPrice = candle.low;
      if (candle.high > maxPrice) maxPrice = candle.high;
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
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.drawings != drawings ||
        oldDelegate.draftDrawing != draftDrawing ||
        oldDelegate.selectedDrawingId != selectedDrawingId ||
        oldDelegate.verticalScale != verticalScale ||
        oldDelegate.verticalOffset != verticalOffset;
  }
}
