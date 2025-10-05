import 'indicator.dart';

class RSIIndicator extends Indicator {
  final int period;
  final Map<DateTime, double> _values;
  final double overbought;
  final double oversold;

  const RSIIndicator({
    required String id,
    required this.period,
    required Map<DateTime, double> values,
    required String color,
    this.overbought = 70.0,
    this.oversold = 30.0,
    bool isVisible = true,
  })  : _values = values,
        super(
          id: id,
          type: IndicatorType.rsi,
          position: IndicatorPosition.bottom,
          color: color,
          isVisible: isVisible,
        );

  @override
  Map<DateTime, double> get values => _values;

  @override
  ({double min, double max}) get range => (min: 0, max: 100);

  @override
  List<Object?> get props => [
        id,
        type,
        period,
        _values,
        overbought,
        oversold,
        color,
        isVisible,
      ];

  RSIIndicator copyWith({
    String? id,
    int? period,
    Map<DateTime, double>? values,
    String? color,
    double? overbought,
    double? oversold,
    bool? isVisible,
  }) {
    return RSIIndicator(
      id: id ?? this.id,
      period: period ?? this.period,
      values: values ?? _values,
      color: color ?? this.color,
      overbought: overbought ?? this.overbought,
      oversold: oversold ?? this.oversold,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}