import 'drawing.dart';
import 'drawing_point.dart';

class TrendlineDrawing extends Drawing {
  final DrawingPoint startPoint;
  final DrawingPoint endPoint;
  final bool extendLeft;
  final bool extendRight;

  const TrendlineDrawing({
    required String id,
    required this.startPoint,
    required this.endPoint,
    required String color,
    double strokeWidth = 2.0,
    this.extendLeft = false,
    this.extendRight = false,
    Map<String, dynamic>? settings,
  }) : super(
          id: id,
          type: DrawingType.trendline,
          color: color,
          strokeWidth: strokeWidth,
          settings: settings,
        );

  @override
  List<DrawingPoint> get points => [startPoint, endPoint];

  /// Trend açısı (derece)
  double get angle {
    final dx = endPoint.timestamp.difference(startPoint.timestamp).inMilliseconds.toDouble();
    final dy = endPoint.price - startPoint.price;
    return dy / dx; // Slope
  }

  /// Belirli bir zamandaki fiyat değeri (trendline üzerinde)
  double priceAt(DateTime timestamp) {
    final dx = endPoint.timestamp.difference(startPoint.timestamp).inMilliseconds.toDouble();
    final dy = endPoint.price - startPoint.price;
    final t = timestamp.difference(startPoint.timestamp).inMilliseconds.toDouble();
    return startPoint.price + (dy / dx) * t;
  }

  @override
  bool containsPoint(DrawingPoint point, double tolerance) {
    final expectedPrice = priceAt(point.timestamp);
    return (point.price - expectedPrice).abs() < tolerance;
  }

  @override
  TrendlineDrawing copyWith({
    String? id,
    DrawingPoint? startPoint,
    DrawingPoint? endPoint,
    String? color,
    double? strokeWidth,
    bool? extendLeft,
    bool? extendRight,
    Map<String, dynamic>? settings,
  }) {
    return TrendlineDrawing(
      id: id ?? this.id,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      extendLeft: extendLeft ?? this.extendLeft,
      extendRight: extendRight ?? this.extendRight,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        startPoint,
        endPoint,
        color,
        strokeWidth,
        extendLeft,
        extendRight,
        settings,
      ];
}