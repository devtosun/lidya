import 'package:equatable/equatable.dart';

class VisibleRange extends Equatable {
  final int startIndex;
  final int endIndex;
  final double priceMin;
  final double priceMax;
  final double horizontalScale; // 1.0 = normal, >1 = zoomed in
  final double verticalScale;   // 1.0 = normal, >1 = zoomed in

  const VisibleRange({
    required this.startIndex,
    required this.endIndex,
    required this.priceMin,
    required this.priceMax,
    this.horizontalScale = 1.0,
    this.verticalScale = 1.0,
  });

  /// Görünen candle sayısı
  int get visibleCandleCount => endIndex - startIndex + 1;

  /// Fiyat aralığı
  double get priceRange => priceMax - priceMin;

  /// Orta fiyat
  double get midPrice => (priceMin + priceMax) / 2;

  @override
  List<Object?> get props => [
        startIndex,
        endIndex,
        priceMin,
        priceMax,
        horizontalScale,
        verticalScale,
      ];

  VisibleRange copyWith({
    int? startIndex,
    int? endIndex,
    double? priceMin,
    double? priceMax,
    double? horizontalScale,
    double? verticalScale,
  }) {
    return VisibleRange(
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      horizontalScale: horizontalScale ?? this.horizontalScale,
      verticalScale: verticalScale ?? this.verticalScale,
    );
  }
}