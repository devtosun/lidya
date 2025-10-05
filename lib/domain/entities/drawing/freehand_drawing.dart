import 'drawing.dart';
import 'drawing_point.dart';

class FreehandDrawing extends Drawing {
  final List<DrawingPoint> pathPoints;

  const FreehandDrawing({
    required String id,
    required this.pathPoints,
    required String color,
    double strokeWidth = 2.0,
    Map<String, dynamic>? settings,
  }) : super(
          id: id,
          type: DrawingType.freehand,
          color: color,
          strokeWidth: strokeWidth,
          settings: settings,
        );

  @override
  List<DrawingPoint> get points => pathPoints;

  @override
  bool containsPoint(DrawingPoint point, double tolerance) {
    // Herhangi bir path noktasına yakın mı?
    return pathPoints.any((p) =>
        (p.timestamp.difference(point.timestamp).inMilliseconds.abs() < 60000) &&
        (p.price - point.price).abs() < tolerance);
  }

  @override
  FreehandDrawing copyWith({
    String? id,
    List<DrawingPoint>? pathPoints,
    String? color,
    double? strokeWidth,
    Map<String, dynamic>? settings,
  }) {
    return FreehandDrawing(
      id: id ?? this.id,
      pathPoints: pathPoints ?? this.pathPoints,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        pathPoints,
        color,
        strokeWidth,
        settings,
      ];
}