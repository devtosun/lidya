import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/indicators/indicator.dart';
import '../../domain/entities/indicators/rsi.dart';
import '../../domain/entities/indicators/macd.dart';

/// Painter for RSI indicator
class RSIPainter extends CustomPainter {
  final List<Candle> candles;
  final RSIIndicator indicator;
  final Color backgroundColor;
  final Color gridColor;
  final Color textColor;

  RSIPainter({
    required this.candles,
    required this.indicator,
    this.backgroundColor = const Color(0xFF1E222D),
    this.gridColor = const Color(0xFF2A2E39),
    this.textColor = Colors.white70,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw reference lines (30, 50, 70)
    _drawReferenceLevels(canvas, size);

    // Draw RSI line
    _drawRSILine(canvas, size);

    // Draw labels
    _drawLabels(canvas, size);
  }

  void _drawReferenceLevels(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final levels = [30.0, 50.0, 70.0];

    for (final level in levels) {
      final y = _valueToY(level, size.height);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawRSILine(Canvas canvas, Size size) {
    final color = _parseColor(indicator.color);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool isFirstPoint = true;
    final candleWidth = size.width / candles.length;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final value = indicator.values[candle.timestamp];

      if (value != null) {
        final x = i * candleWidth + candleWidth / 2;
        final y = _valueToY(value, size.height);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);

    // Draw overbought/oversold fills
    _drawOverboughtOversoldZones(canvas, size, path);
  }

  void _drawOverboughtOversoldZones(Canvas canvas, Size size, Path linePath) {
    final color = _parseColor(indicator.color);

    // Overbought zone (> 70)
    final overboughtPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final overboughtRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      _valueToY(70, size.height),
    );
    canvas.drawRect(overboughtRect, overboughtPaint);

    // Oversold zone (< 30)
    final oversoldPaint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final oversoldY = _valueToY(30, size.height);
    final oversoldRect = Rect.fromLTWH(
      0,
      oversoldY,
      size.width,
      size.height - oversoldY,
    );
    canvas.drawRect(oversoldRect, oversoldPaint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final levels = [
      {'value': 0.0, 'label': '0'},
      {'value': 30.0, 'label': '30'},
      {'value': 50.0, 'label': '50'},
      {'value': 70.0, 'label': '70'},
      {'value': 100.0, 'label': '100'},
    ];

    for (final level in levels) {
      final value = level['value'] as double;
      final label = level['label'] as String;
      final y = _valueToY(value, size.height);

      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - textPainter.height / 2));
    }

    // Draw indicator name
    final nameSpan = TextSpan(
      text: 'RSI(${indicator.period})',
      style: TextStyle(
        color: _parseColor(indicator.color),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );

    final namePainter = TextPainter(
      text: nameSpan,
      textDirection: TextDirection.ltr,
    );

    namePainter.layout();
    namePainter.paint(canvas, const Offset(50, 4));
  }

  double _valueToY(double value, double height) {
    // RSI is 0-100, inverted Y axis
    return height - (value / 100 * height);
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.purple;
    }
  }

  @override
  bool shouldRepaint(RSIPainter oldDelegate) {
    return oldDelegate.candles != candles || oldDelegate.indicator != indicator;
  }
}

/// Painter for MACD indicator
class MACDPainter extends CustomPainter {
  final List<Candle> candles;
  final MACDIndicator indicator;
  final Color backgroundColor;
  final Color gridColor;
  final Color textColor;

  MACDPainter({
    required this.candles,
    required this.indicator,
    this.backgroundColor = const Color(0xFF1E222D),
    this.gridColor = const Color(0xFF2A2E39),
    this.textColor = Colors.white70,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Calculate value range
    final valueRange = _calculateValueRange();
    if (valueRange.isEmpty) return;

    // Draw zero line
    _drawZeroLine(canvas, size, valueRange);

    // Draw histogram first (background)
    _drawHistogram(canvas, size, valueRange);

    // Draw MACD and signal lines (foreground)
    _drawMACDLine(canvas, size, valueRange);
    _drawSignalLine(canvas, size, valueRange);

    // Draw labels
    _drawLabels(canvas, size);
  }

  Map<String, double> _calculateValueRange() {
    double minValue = 0;
    double maxValue = 0;

    for (final candle in candles) {
      final macdValue = indicator.macdLine[candle.timestamp];
      final signalValue = indicator.signalLine[candle.timestamp];
      final histValue = indicator.histogram[candle.timestamp];

      if (macdValue != null) {
        if (macdValue < minValue) minValue = macdValue;
        if (macdValue > maxValue) maxValue = macdValue;
      }
      if (signalValue != null) {
        if (signalValue < minValue) minValue = signalValue;
        if (signalValue > maxValue) maxValue = signalValue;
      }
      if (histValue != null) {
        if (histValue < minValue) minValue = histValue;
        if (histValue > maxValue) maxValue = histValue;
      }
    }

    // Add padding
    final padding = (maxValue - minValue) * 0.1;
    minValue -= padding;
    maxValue += padding;

    // Ensure zero is included
    if (minValue > 0) minValue = 0;
    if (maxValue < 0) maxValue = 0;

    return {
      'min': minValue,
      'max': maxValue,
    };
  }

  void _drawZeroLine(Canvas canvas, Size size, Map<String, double> valueRange) {
    final minValue = valueRange['min']!;
    final maxValue = valueRange['max']!;
    final zeroY = _valueToY(0, minValue, maxValue, size.height);

    final paint = Paint()
      ..color = gridColor.withOpacity(0.8)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      paint,
    );
  }

  void _drawHistogram(Canvas canvas, Size size, Map<String, double> valueRange) {
    final minValue = valueRange['min']!;
    final maxValue = valueRange['max']!;
    final candleWidth = size.width / candles.length;
    final zeroY = _valueToY(0, minValue, maxValue, size.height);

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final value = indicator.histogram[candle.timestamp];

      if (value != null) {
        final x = i * candleWidth;
        final valueY = _valueToY(value, minValue, maxValue, size.height);

        final paint = Paint()
          ..color = value >= 0 ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)
          ..style = PaintingStyle.fill;

        final rect = Rect.fromLTRB(
          x + candleWidth * 0.1,
          valueY,
          x + candleWidth * 0.9,
          zeroY,
        );

        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawMACDLine(Canvas canvas, Size size, Map<String, double> valueRange) {
    final minValue = valueRange['min']!;
    final maxValue = valueRange['max']!;
    final color = _parseColor(indicator.color);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool isFirstPoint = true;
    final candleWidth = size.width / candles.length;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final value = indicator.macdLine[candle.timestamp];

      if (value != null) {
        final x = i * candleWidth + candleWidth / 2;
        final y = _valueToY(value, minValue, maxValue, size.height);

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

  void _drawSignalLine(Canvas canvas, Size size, Map<String, double> valueRange) {
    final minValue = valueRange['min']!;
    final maxValue = valueRange['max']!;

    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool isFirstPoint = true;
    final candleWidth = size.width / candles.length;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final value = indicator.signalLine[candle.timestamp];

      if (value != null) {
        final x = i * candleWidth + candleWidth / 2;
        final y = _valueToY(value, minValue, maxValue, size.height);

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

  void _drawLabels(Canvas canvas, Size size) {
    // Draw indicator name
    final nameSpan = TextSpan(
      text: 'MACD(${indicator.fastPeriod},${indicator.slowPeriod},${indicator.signalPeriod})',
      style: TextStyle(
        color: _parseColor(indicator.color),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );

    final namePainter = TextPainter(
      text: nameSpan,
      textDirection: TextDirection.ltr,
    );

    namePainter.layout();
    namePainter.paint(canvas, const Offset(4, 4));
  }

  double _valueToY(double value, double minValue, double maxValue, double height) {
    final valueSpan = maxValue - minValue;
    if (valueSpan == 0) return height / 2;
    return height - ((value - minValue) / valueSpan * height);
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.orange;
    }
  }

  @override
  bool shouldRepaint(MACDPainter oldDelegate) {
    return oldDelegate.candles != candles || oldDelegate.indicator != indicator;
  }
}
