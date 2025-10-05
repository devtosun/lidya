import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/candle.dart';

class PriceAxisPainter extends CustomPainter {
  final List<Candle> candles;
  final double verticalScale;
  final double verticalOffset;
  final Color textColor;
  final Color gridColor;
  final int numberOfLabels;
  final double width;

  PriceAxisPainter({
    required this.candles,
    this.verticalScale = 1.0,
    this.verticalOffset = 0.0,
    this.textColor = Colors.white70,
    this.gridColor = const Color(0xFF2A2E39),
    this.numberOfLabels = 5,
    this.width = 60.0,
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

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E222D),
    );

    // Calculate price levels
    final priceStep = adjustedPriceSpan / (numberOfLabels - 1);

    for (int i = 0; i < numberOfLabels; i++) {
      final price = adjustedMinPrice + (priceStep * i);
      final y = _priceToY(price, adjustedMinPrice, adjustedPriceSpan, size.height);

      // Draw label
      _drawPriceLabel(canvas, price, y, size.width);
    }

    // Draw current price (last close price)
    final currentPrice = candles.last.close;
    final currentY = _priceToY(currentPrice, adjustedMinPrice, adjustedPriceSpan, size.height);
    _drawCurrentPriceLabel(canvas, currentPrice, currentY, size.width);
  }

  void _drawPriceLabel(Canvas canvas, double price, double y, double width) {
    final textSpan = TextSpan(
      text: _formatPrice(price),
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontFamily: 'monospace',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
    );

    textPainter.layout(maxWidth: width - 8);

    final offset = Offset(
      4,
      y - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  void _drawCurrentPriceLabel(Canvas canvas, double price, double y, double width) {
    // Draw background rectangle
    final textSpan = TextSpan(
      text: _formatPrice(price),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
    );

    textPainter.layout(maxWidth: width - 8);

    final bgRect = Rect.fromLTWH(
      0,
      y - textPainter.height / 2 - 2,
      width,
      textPainter.height + 4,
    );

    canvas.drawRect(
      bgRect,
      Paint()..color = const Color(0xFF2962FF),
    );

    final offset = Offset(
      4,
      y - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
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

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(3);
    } else {
      return price.toStringAsFixed(5);
    }
  }

  @override
  bool shouldRepaint(PriceAxisPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.verticalScale != verticalScale ||
        oldDelegate.verticalOffset != verticalOffset;
  }
}

class TimeAxisPainter extends CustomPainter {
  final List<Candle> candles;
  final Color textColor;
  final Color gridColor;
  final int numberOfLabels;
  final double height;

  TimeAxisPainter({
    required this.candles,
    this.textColor = Colors.white70,
    this.gridColor = const Color(0xFF2A2E39),
    this.numberOfLabels = 6,
    this.height = 30.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E222D),
    );

    // Calculate time intervals
    final candleWidth = size.width / candles.length;
    final step = (candles.length / (numberOfLabels - 1)).floor();

    for (int i = 0; i < numberOfLabels; i++) {
      final index = (i * step).clamp(0, candles.length - 1);
      final candle = candles[index];
      final x = index * candleWidth + candleWidth / 2;

      _drawTimeLabel(canvas, candle.timestamp, x);
    }
  }

  void _drawTimeLabel(Canvas canvas, DateTime timestamp, double x) {
    final textSpan = TextSpan(
      text: _formatTime(timestamp),
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontFamily: 'monospace',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
    );

    textPainter.layout();

    final offset = Offset(
      x - textPainter.width / 2,
      8,
    );

    textPainter.paint(canvas, offset);
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candleDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (candleDate == today) {
      // Same day: show only time
      return DateFormat.Hm().format(timestamp);
    } else if (timestamp.year == now.year) {
      // Same year: show month and day
      return DateFormat.MMMd().format(timestamp);
    } else {
      // Different year: show full date
      return DateFormat.yMMMd().format(timestamp);
    }
  }

  @override
  bool shouldRepaint(TimeAxisPainter oldDelegate) {
    return oldDelegate.candles != candles;
  }
}

class GridPainter extends CustomPainter {
  final List<Candle> candles;
  final double verticalScale;
  final double verticalOffset;
  final Color gridColor;
  final int horizontalLines;
  final int verticalLines;

  GridPainter({
    required this.candles,
    this.verticalScale = 1.0,
    this.verticalOffset = 0.0,
    this.gridColor = const Color(0xFF2A2E39),
    this.horizontalLines = 5,
    this.verticalLines = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i < horizontalLines; i++) {
      final y = (size.height / (horizontalLines - 1)) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical grid lines
    if (candles.isNotEmpty) {
      final candleWidth = size.width / candles.length;
      final step = (candles.length / (verticalLines - 1)).floor();

      for (int i = 0; i < verticalLines; i++) {
        final index = (i * step).clamp(0, candles.length - 1);
        final x = index * candleWidth + candleWidth / 2;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.verticalScale != verticalScale ||
        oldDelegate.verticalOffset != verticalOffset;
  }
}
