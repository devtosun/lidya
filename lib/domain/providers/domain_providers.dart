// domain/providers/domain_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/data_providers.dart';
import '../usecases/load_initial_chart_data.dart';
import '../usecases/add_technical_indicator.dart';
import '../usecases/remove_technical_indicator.dart';
import '../usecases/add_drawing.dart';
import '../usecases/update_drawing.dart';
import '../usecases/remove_drawing.dart';

// Use Cases
final loadInitialChartDataUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chartRepositoryProvider);
  return LoadInitialChartDataUseCase(repository);
});

final addTechnicalIndicatorUseCaseProvider = Provider((ref) {
  return AddTechnicalIndicatorUseCase();
});

final removeTechnicalIndicatorUseCaseProvider = Provider((ref) {
  return RemoveTechnicalIndicatorUseCase();
});

final addDrawingUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chartRepositoryProvider);
  return AddDrawingUseCase(repository);
});

final updateDrawingUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chartRepositoryProvider);
  return UpdateDrawingUseCase(repository);
});

final removeDrawingUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chartRepositoryProvider);
  return RemoveDrawingUseCase(repository);
});