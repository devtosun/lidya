import 'package:equatable/equatable.dart';
import 'drawing_point.dart';
import 'trendline_drawing.dart';
import 'fibonacci_drawing.dart';
import 'freehand_drawing.dart';

enum DrawingType {
  trendline,
  horizontalLine,
  verticalLine,
  fibonacci,
  freehand,
  rectangle,
  ellipse,
}

abstract class Drawing extends Equatable {
  final String id;
  final DrawingType type;
  final String color;
  final double strokeWidth;
  final Map<String, dynamic>? settings;

  const Drawing({
    required this.id,
    required this.type,
    required this.color,
    this.strokeWidth = 2.0,
    this.settings,
  });

  /// Çizimin noktaları
  List<DrawingPoint> get points;

  /// Çizim bir noktayı içeriyor mu?
  bool containsPoint(DrawingPoint point, double tolerance);

  /// Çizimi kopyala
  Drawing copyWith({
    String? id,
    String? color,
    double? strokeWidth,
    Map<String, dynamic>? settings,
  });

  /// Factory method - Tip ve noktalara göre Drawing oluştur
  factory Drawing.create({
    required String id,
    required DrawingType type,
    required List<DrawingPoint> points,
    String color = '#FF0000',
    double strokeWidth = 2.0,
    Map<String, dynamic>? settings,
  }) {
    switch (type) {
      case DrawingType.trendline:
      case DrawingType.horizontalLine:
      case DrawingType.verticalLine:
        if (points.length < 2) {
          throw ArgumentError('Line drawings require at least 2 points');
        }
        return TrendlineDrawing(
          id: id,
          startPoint: points[0],
          endPoint: points[1],
          color: color,
          strokeWidth: strokeWidth,
          extendLeft: settings?['extendLeft'] ?? false,
          extendRight: settings?['extendRight'] ?? false,
          settings: settings,
        );

      case DrawingType.fibonacci:
        if (points.length < 2) {
          throw ArgumentError('Fibonacci requires at least 2 points');
        }
        return FibonacciDrawing(
          id: id,
          startPoint: points[0],
          endPoint: points[1],
          color: color,
          strokeWidth: strokeWidth,
          levels: settings?['levels']?.cast<double>() ?? 
                  [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0],
          settings: settings,
        );

      case DrawingType.freehand:
        if (points.isEmpty) {
          throw ArgumentError('Freehand drawing requires at least 1 point');
        }
        return FreehandDrawing(
          id: id,
          pathPoints: points,
          color: color,
          strokeWidth: strokeWidth,
          settings: settings,
        );

      case DrawingType.rectangle:
      case DrawingType.ellipse:
        // TODO: Implement rectangle and ellipse drawings
        throw UnimplementedError('$type drawing not yet implemented');
    }
  }
}