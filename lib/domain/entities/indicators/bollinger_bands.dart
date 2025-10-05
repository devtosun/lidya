import 'indicator.dart';

class BollingerBandsIndicator extends Indicator {
  final int period;
  final double standardDeviations;
  final Map<DateTime, double> upperBand;
  final Map<DateTime, double> middleBand;
  final Map<DateTime, double> lowerBand;

  const BollingerBandsIndicator({
    required String id,
    required this.period,
    required this.standardDeviations,
    required this.upperBand,
    required this.middleBand,
    required this.lowerBand,
    required String color,
    bool isVisible = true,
  }) : super(
          id: id,
          type: IndicatorType.bollingerBands,
          position: IndicatorPosition.overlay,
          color: color,
          isVisible: isVisible,
        );

  @override
  Map<DateTime, double> get values => middleBand;

  @override
  List<Object?> get props => [
        id,
        type,
        period,
        standardDeviations,
        upperBand,
        middleBand,
        lowerBand,
        color,
        isVisible,
      ];

  BollingerBandsIndicator copyWith({
    String? id,
    int? period,
    double? standardDeviations,
    Map<DateTime, double>? upperBand,
    Map<DateTime, double>? middleBand,
    Map<DateTime, double>? lowerBand,
    String? color,
    bool? isVisible,
  }) {
    return BollingerBandsIndicator(
      id: id ?? this.id,
      period: period ?? this.period,
      standardDeviations: standardDeviations ?? this.standardDeviations,
      upperBand: upperBand ?? this.upperBand,
      middleBand: middleBand ?? this.middleBand,
      lowerBand: lowerBand ?? this.lowerBand,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}