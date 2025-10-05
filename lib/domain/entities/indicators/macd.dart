import 'indicator.dart';

class MACDIndicator extends Indicator {
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;
  final Map<DateTime, double> macdLine;
  final Map<DateTime, double> signalLine;
  final Map<DateTime, double> histogram;

  const MACDIndicator({
    required String id,
    required this.fastPeriod,
    required this.slowPeriod,
    required this.signalPeriod,
    required this.macdLine,
    required this.signalLine,
    required this.histogram,
    required String color,
    bool isVisible = true,
  }) : super(
          id: id,
          type: IndicatorType.macd,
          position: IndicatorPosition.bottom,
          color: color,
          isVisible: isVisible,
        );

  @override
  Map<DateTime, double> get values => macdLine;

  @override
  List<Object?> get props => [
        id,
        type,
        fastPeriod,
        slowPeriod,
        signalPeriod,
        macdLine,
        signalLine,
        histogram,
        color,
        isVisible,
      ];

  MACDIndicator copyWith({
    String? id,
    int? fastPeriod,
    int? slowPeriod,
    int? signalPeriod,
    Map<DateTime, double>? macdLine,
    Map<DateTime, double>? signalLine,
    Map<DateTime, double>? histogram,
    String? color,
    bool? isVisible,
  }) {
    return MACDIndicator(
      id: id ?? this.id,
      fastPeriod: fastPeriod ?? this.fastPeriod,
      slowPeriod: slowPeriod ?? this.slowPeriod,
      signalPeriod: signalPeriod ?? this.signalPeriod,
      macdLine: macdLine ?? this.macdLine,
      signalLine: signalLine ?? this.signalLine,
      histogram: histogram ?? this.histogram,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}