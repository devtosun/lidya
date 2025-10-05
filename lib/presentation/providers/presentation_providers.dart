import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chart_controller.dart';
import '../state/chart_state.dart';
import '../../data/providers/data_providers.dart';

/// Example: Global chart controller provider
/// Note: In practice, each CandlestickChartWidget creates its own instance
/// to maintain isolated state per chart
StateNotifierProvider<ChartController, ChartState> createChartProvider({
  required String symbol,
  Duration interval = const Duration(minutes: 15),
}) {
  return StateNotifierProvider<ChartController, ChartState>((ref) {
    final repository = ref.watch(chartRepositoryProvider);
    return ChartController(
      repository,
      symbol: symbol,
      interval: interval,
    );
  });
}
