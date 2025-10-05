import 'package:equatable/equatable.dart';
import 'candle.dart';
import 'indicators/indicator.dart';
import 'drawing/drawing.dart';

class ChartData extends Equatable {
  final List<Candle> candles;
  final List<Indicator> overlayIndicators;
  final List<Indicator> bottomIndicators;
  final List<Drawing> drawings;
  final String symbol;
  final Duration interval;

  const ChartData({
    required this.candles,
    this.overlayIndicators = const [],
    this.bottomIndicators = const [],
    this.drawings = const [],
    required this.symbol,
    required this.interval,
  });

  /// Fiyat aralığı (min-max)
  ({double min, double max}) get priceRange {
    if (candles.isEmpty) return (min: 0, max: 0);
    
    double min = candles.first.low;
    double max = candles.first.high;
    
    for (final candle in candles) {
      if (candle.low < min) min = candle.low;
      if (candle.high > max) max = candle.high;
    }
    
    return (min: min, max: max);
  }

  /// Zaman aralığı
  ({DateTime start, DateTime end}) get timeRange {
    if (candles.isEmpty) {
      final now = DateTime.now();
      return (start: now, end: now);
    }
    return (start: candles.first.timestamp, end: candles.last.timestamp);
  }

  /// Toplam candle sayısı
  int get candleCount => candles.length;

  @override
  List<Object?> get props => [
        candles,
        overlayIndicators,
        bottomIndicators,
        drawings,
        symbol,
        interval,
      ];

  ChartData copyWith({
    List<Candle>? candles,
    List<Indicator>? overlayIndicators,
    List<Indicator>? bottomIndicators,
    List<Drawing>? drawings,
    String? symbol,
    Duration? interval,
  }) {
    return ChartData(
      candles: candles ?? this.candles,
      overlayIndicators: overlayIndicators ?? this.overlayIndicators,
      bottomIndicators: bottomIndicators ?? this.bottomIndicators,
      drawings: drawings ?? this.drawings,
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
    );
  }
}