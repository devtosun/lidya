import 'package:equatable/equatable.dart';

class DrawingPoint extends Equatable {
  final DateTime timestamp;
  final double price;

  const DrawingPoint({
    required this.timestamp,
    required this.price,
  });

  @override
  List<Object?> get props => [timestamp, price];

  DrawingPoint copyWith({
    DateTime? timestamp,
    double? price,
  }) {
    return DrawingPoint(
      timestamp: timestamp ?? this.timestamp,
      price: price ?? this.price,
    );
  }

  @override
  String toString() => 'DrawingPoint(${timestamp.toIso8601String()}, $price)';
}