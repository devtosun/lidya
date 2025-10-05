// domain/usecases/load_initial_chart_data.dart
import '../entities/candle.dart';
import '../entities/chart_data.dart';
import '../repositories/chart_repository.dart';

class LoadInitialChartDataUseCase {
  final ChartRepository repository;

  LoadInitialChartDataUseCase(this.repository);

  Future<ChartData> execute({
    required String symbol,
    required Duration interval,
    int limit = 1000,
  }) async {
    final candles = await repository.getHistoricalData(
      symbol: symbol,
      interval: interval,
      limit: limit,
    );

    final drawings = await repository.getDrawings(symbol);

    return ChartData(
      candles: candles,
      drawings: drawings,
      symbol: symbol,
      interval: interval,
    );
  }
}