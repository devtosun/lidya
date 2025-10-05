import 'package:equatable/equatable.dart';

class Candle extends Equatable {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Bullish (yükseliş) mi?
  bool get isBullish => close >= open;

  /// Bearish (düşüş) mü?
  bool get isBearish => close < open;

  /// Candle gövde boyutu
  double get bodySize => (close - open).abs();

  /// Üst fitil boyutu
  double get upperWickSize => high - (isBullish ? close : open);

  /// Alt fitil boyutu
  double get lowerWickSize => (isBullish ? open : close) - low;

  /// Toplam range
  double get range => high - low;

  /// Gövde/range oranı
  double get bodyRatio => range == 0 ? 0 : bodySize / range;

  @override
  List<Object?> get props => [timestamp, open, high, low, close, volume];

  Candle copyWith({
    DateTime? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return Candle(
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  @override
  String toString() => 'Candle(${timestamp.toIso8601String()}, O:$open H:$high L:$low C:$close)';
}