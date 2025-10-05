import 'drawing.dart';
import 'drawing_point.dart';

class FibonacciDrawing extends Drawing {
  final DrawingPoint startPoint;
  final DrawingPoint endPoint;
  final List<double> levels;

  const FibonacciDrawing({
    required String id,
    required this.startPoint,
    required this.endPoint,
    required String color,
    double strokeWidth = 1.0,
    this.levels = const [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0],
    Map<String, dynamic>? settings,
  }) : super(
          id: id,
          type: DrawingType.fibonacci,
          color: color,
          strokeWidth: strokeWidth,
          settings: settings,
        );

  @override
  List<DrawingPoint> get points => [startPoint, endPoint];

  /// Fibonacci seviye fiyatlarını hesapla
  Map<double, double> get levelPrices {
    final priceRange = endPoint.price - startPoint.price;
    return {
      for (var level in levels)
        level: startPoint.price + (priceRange * level)
    };
  }

  @override
  bool containsPoint(DrawingPoint point, double tolerance) {
    // Fibonacci çizgilerinden herhangi birine yakın mı?
    final prices = levelPrices.values;
    return prices.any((price) => (point.price - price).abs() < tolerance);
  }

  @override
  FibonacciDrawing copyWith({
    String? id,
    DrawingPoint? startPoint,
    DrawingPoint? endPoint,
    String? color,
    double? strokeWidth,
    List<double>? levels,
    Map<String, dynamic>? settings,
  }) {
    return FibonacciDrawing(
      id: id ?? this.id,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      levels: levels ?? this.levels,
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
        levels,
        settings,
      ];
}