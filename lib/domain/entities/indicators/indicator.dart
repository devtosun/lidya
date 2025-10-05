import 'package:equatable/equatable.dart';

enum IndicatorType {
  ema,
  sma,
  dema,
  bollingerBands,
  rsi,
  macd,
}

enum IndicatorPosition {
  overlay,  // Ana grafik üzerinde
  bottom,   // Ayrı panel altında
}

abstract class Indicator extends Equatable {
  final String id;
  final IndicatorType type;
  final IndicatorPosition position;
  final String color;
  final bool isVisible;

  const Indicator({
    required this.id,
    required this.type,
    required this.position,
    required this.color,
    this.isVisible = true,
  });

  /// İndikatör değerleri (timestamp -> value)
  Map<DateTime, double> get values;

  /// İndikatör aralığı (min-max)
  ({double min, double max}) get range {
    if (values.isEmpty) return (min: 0, max: 0);
    final vals = values.values;
    return (min: vals.reduce((a, b) => a < b ? a : b), max: vals.reduce((a, b) => a > b ? a : b));
  }
}