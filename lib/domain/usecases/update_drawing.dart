// domain/usecases/update_drawing.dart
import '../entities/chart_data.dart';
import '../entities/drawing/drawing.dart';
import '../repositories/chart_repository.dart';

class UpdateDrawingUseCase {
  final ChartRepository repository;

  UpdateDrawingUseCase(this.repository);

  Future<ChartData> execute({
    required ChartData chartData,
    required Drawing updatedDrawing,
  }) async {
    await repository.saveDrawing(chartData.symbol, updatedDrawing);

    final drawings = chartData.drawings.map((d) {
      return d.id == updatedDrawing.id ? updatedDrawing : d;
    }).toList();

    return chartData.copyWith(drawings: drawings);
  }
}