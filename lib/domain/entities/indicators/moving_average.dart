import 'indicator.dart';

class MovingAverageIndicator extends Indicator {
  final int period;
  final Map<DateTime, double> _values;
  final bool isExponential;

  const MovingAverageIndicator({
    required String id,
    required this.period,
    required Map<DateTime, double> values,
    required String color,
    this.isExponential = false,
    bool isVisible = true,
  })  : _values = values,
        super(
          id: id,
          type: isExponential ? IndicatorType.ema : IndicatorType.sma,
          position: IndicatorPosition.overlay,
          color: color,
          isVisible: isVisible,
        );

  @override
  Map<DateTime, double> get values => _values;

  @override
  List<Object?> get props => [id, type, period, _values, color, isVisible];

  MovingAverageIndicator copyWith({
    String? id,
    int? period,
    Map<DateTime, double>? values,
    String? color,
    bool? isExponential,
    bool? isVisible,
  }) {
    return MovingAverageIndicator(
      id: id ?? this.id,
      period: period ?? this.period,
      values: values ?? _values,
      color: color ?? this.color,
      isExponential: isExponential ?? this.isExponential,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}