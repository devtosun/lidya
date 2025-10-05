// domain/usecases/remove_technical_indicator.dart
import '../entities/chart_data.dart';

class RemoveTechnicalIndicatorUseCase {
  Future<ChartData> execute({
    required ChartData chartData,
    required String indicatorId,
  }) async {
    final overlayIndicators = chartData.overlayIndicators
        .where((i) => i.id != indicatorId)
        .toList();
    
    final bottomIndicators = chartData.bottomIndicators
        .where((i) => i.id != indicatorId)
        .toList();

    return chartData.copyWith(
      overlayIndicators: overlayIndicators,
      bottomIndicators: bottomIndicators,
    );
  }
}