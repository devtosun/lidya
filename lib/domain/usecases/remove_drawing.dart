// domain/usecases/remove_drawing.dart
import '../entities/chart_data.dart';
import '../repositories/chart_repository.dart';

class RemoveDrawingUseCase {
  final ChartRepository repository;

  RemoveDrawingUseCase(this.repository);

  Future<ChartData> execute({
    required ChartData chartData,
    required String drawingId,
  }) async {
    await repository.deleteDrawing(chartData.symbol, drawingId);

    final drawings = chartData.drawings
        .where((d) => d.id != drawingId)
        .toList();

    return chartData.copyWith(drawings: drawings);
  }
}