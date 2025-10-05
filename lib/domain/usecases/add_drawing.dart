// domain/usecases/add_drawing.dart
import '../entities/chart_data.dart';
import '../entities/drawing/drawing.dart';
import '../repositories/chart_repository.dart';

class AddDrawingUseCase {
  final ChartRepository repository;

  AddDrawingUseCase(this.repository);

  Future<ChartData> execute({
    required ChartData chartData,
    required Drawing drawing,
  }) async {
    await repository.saveDrawing(chartData.symbol, drawing);

    return chartData.copyWith(
      drawings: [...chartData.drawings, drawing],
    );
  }
}