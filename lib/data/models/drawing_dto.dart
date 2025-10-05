import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/drawing/drawing.dart';
import '../../../domain/entities/drawing/drawing_point.dart';
import '../../../domain/entities/drawing/trendline_drawing.dart';
import '../../../domain/entities/drawing/fibonacci_drawing.dart';
import '../../../domain/entities/drawing/freehand_drawing.dart';

part 'drawing_dto.g.dart';

@JsonSerializable()
class DrawingDto {
  final String id;
  final String type; // 'trendline', 'fibonacci', 'freehand', 'horizontalLine', etc.
  final List<DrawingPointDto> points;
  final String color;
  final double strokeWidth;
  final Map<String, dynamic>? settings;

  DrawingDto({
    required this.id,
    required this.type,
    required this.points,
    required this.color,
    this.strokeWidth = 2.0,
    this.settings,
  });

  factory DrawingDto.fromJson(Map<String, dynamic> json) => 
      _$DrawingDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$DrawingDtoToJson(this);

  /// DTO'dan Domain'e dönüştürme - Factory pattern ile doğru concrete sınıfı döndürür
  Drawing toDomain() {
    final domainPoints = points.map((p) => p.toDomain()).toList();
    
    switch (type) {
      case 'trendline':
        if (domainPoints.length < 2) {
          throw Exception('Trendline requires at least 2 points');
        }
        return TrendlineDrawing(
          id: id,
          startPoint: domainPoints[0],
          endPoint: domainPoints[1],
          color: color,
          strokeWidth: strokeWidth,
          extendLeft: settings?['extendLeft'] ?? false,
          extendRight: settings?['extendRight'] ?? false,
          settings: settings,
        );
        
      case 'fibonacci':
        if (domainPoints.length < 2) {
          throw Exception('Fibonacci requires at least 2 points');
        }
        return FibonacciDrawing(
          id: id,
          startPoint: domainPoints[0],
          endPoint: domainPoints[1],
          color: color,
          strokeWidth: strokeWidth,
          levels: settings?['levels']?.cast<double>() ?? 
                  [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0],
          settings: settings,
        );
        
      case 'freehand':
        if (domainPoints.isEmpty) {
          throw Exception('Freehand drawing requires at least 1 point');
        }
        return FreehandDrawing(
          id: id,
          pathPoints: domainPoints,
          color: color,
          strokeWidth: strokeWidth,
          settings: settings,
        );
        
      default:
        // Varsayılan olarak trendline döndür
        if (domainPoints.length >= 2) {
          return TrendlineDrawing(
            id: id,
            startPoint: domainPoints[0],
            endPoint: domainPoints[1],
            color: color,
            strokeWidth: strokeWidth,
            settings: settings,
          );
        }
        throw Exception('Unknown drawing type: $type');
    }
  }

  /// Domain'den DTO'ya dönüştürme - Her drawing tipini handle eder
  factory DrawingDto.fromDomain(Drawing drawing) {
    final List<DrawingPointDto> pointDtos;
    
    // Drawing tipine göre noktaları al
    if (drawing is TrendlineDrawing) {
      pointDtos = [
        DrawingPointDto.fromDomain(drawing.startPoint),
        DrawingPointDto.fromDomain(drawing.endPoint),
      ];
    } else if (drawing is FibonacciDrawing) {
      pointDtos = [
        DrawingPointDto.fromDomain(drawing.startPoint),
        DrawingPointDto.fromDomain(drawing.endPoint),
      ];
    } else if (drawing is FreehandDrawing) {
      pointDtos = drawing.pathPoints
          .map((p) => DrawingPointDto.fromDomain(p))
          .toList();
    } else {
      // Fallback - generic points getter kullan
      pointDtos = drawing.points
          .map((p) => DrawingPointDto.fromDomain(p))
          .toList();
    }
    
    return DrawingDto(
      id: drawing.id,
      type: drawing.type.name,
      points: pointDtos,
      color: drawing.color,
      strokeWidth: drawing.strokeWidth,
      settings: drawing.settings,
    );
  }
}

@JsonSerializable()
class DrawingPointDto {
  final int timestampMs;
  final double price;

  DrawingPointDto({
    required this.timestampMs,
    required this.price,
  });

  factory DrawingPointDto.fromJson(Map<String, dynamic> json) => 
      _$DrawingPointDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$DrawingPointDtoToJson(this);

  DrawingPoint toDomain() {
    return DrawingPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      price: price,
    );
  }

  factory DrawingPointDto.fromDomain(DrawingPoint point) {
    return DrawingPointDto(
      timestampMs: point.timestamp.millisecondsSinceEpoch,
      price: point.price,
    );
  }
}