// domain/usecases/add_technical_indicator.dart
import '../entities/candle.dart';
import '../entities/chart_data.dart';
import '../entities/indicators/indicator.dart';
import '../services/indicator_calculator.dart';

class AddTechnicalIndicatorUseCase {
  Future<ChartData> execute({
    required ChartData chartData,
    required IndicatorType type,
    Map<String, dynamic>? params,
  }) async {
    final indicator = IndicatorCalculator.createIndicator(
      type: type,
      candles: chartData.candles,
      params: params,
    );

    if (indicator.position == IndicatorPosition.overlay) {
      return chartData.copyWith(
        overlayIndicators: [...chartData.overlayIndicators, indicator],
      );
    } else {
      return chartData.copyWith(
        bottomIndicators: [...chartData.bottomIndicators, indicator],
      );
    }
  }
}