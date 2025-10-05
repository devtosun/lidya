import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chart_controller.dart';
import '../state/chart_state.dart';
import '../painters/candle_painter.dart';
import '../painters/axis_painter.dart';
import '../painters/indicator_painter.dart';
import '../painters/bottom_indicator_painter.dart';
import '../painters/drawing_painter.dart';
import 'chart_gesture_handler.dart';
import '../../domain/entities/indicators/indicator.dart';
import '../../domain/entities/indicators/rsi.dart';
import '../../domain/entities/indicators/macd.dart';
import '../../data/providers/data_providers.dart' as data;

class CandlestickChartWidget extends ConsumerStatefulWidget {
  final String symbol;
  final Duration interval;

  const CandlestickChartWidget({
    super.key,
    required this.symbol,
    this.interval = const Duration(minutes: 15),
  });

  @override
  ConsumerState<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends ConsumerState<CandlestickChartWidget> {
  late final StateNotifierProvider<ChartController, ChartState> _chartProvider;

  @override
  void initState() {
    super.initState();

    _chartProvider = StateNotifierProvider<ChartController, ChartState>((ref) {
      final repository = ref.watch(data.chartRepositoryProvider);
      return ChartController(
        repository,
        symbol: widget.symbol,
        interval: widget.interval,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_chartProvider);
    final controller = ref.read(_chartProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF131722),
      body: Column(
        children: [
          _buildToolbar(context, state, controller),
          Expanded(
            child: _buildChartArea(state, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ChartState state, ChartController controller) {
    return Container(
      height: 50,
      color: const Color(0xFF1E222D),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            state.symbol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          _buildIndicatorButtons(state, controller),
          const Spacer(),
          _buildDrawingTools(state, controller),
          const SizedBox(width: 16),
          _buildZoomControls(controller),
        ],
      ),
    );
  }

  Widget _buildIndicatorButtons(ChartState state, ChartController controller) {
    return Row(
      children: [
        _buildIndicatorButton('EMA 200', IndicatorType.ema, state, controller),
        const SizedBox(width: 8),
        _buildIndicatorButton('Bollinger', IndicatorType.bollingerBands, state, controller),
        const SizedBox(width: 8),
        _buildIndicatorButton('RSI', IndicatorType.rsi, state, controller),
        const SizedBox(width: 8),
        _buildIndicatorButton('MACD', IndicatorType.macd, state, controller),
      ],
    );
  }

  Widget _buildIndicatorButton(
    String label,
    IndicatorType type,
    ChartState state,
    ChartController controller,
  ) {
    final isActive = state.activeOverlayIndicators.any((i) => i.type == type) ||
        state.activeBottomIndicators.any((i) => i.type == type);

    return ElevatedButton(
      onPressed: () => controller.toggleIndicator(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF2962FF) : const Color(0xFF2A2E39),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildDrawingTools(ChartState state, ChartController controller) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.show_chart,
            color: state.interactionMode == InteractionMode.drawing &&
                    state.selectedDrawingTool == 'trendline'
                ? const Color(0xFF2962FF)
                : Colors.white70,
          ),
          onPressed: () {
            controller.setInteractionMode(
              state.interactionMode == InteractionMode.drawing &&
                      state.selectedDrawingTool == 'trendline'
                  ? InteractionMode.navigation
                  : InteractionMode.drawing,
              drawingTool: 'trendline',
            );
          },
          tooltip: 'Trendline',
        ),
        IconButton(
          icon: Icon(
            Icons.linear_scale,
            color: state.interactionMode == InteractionMode.drawing &&
                    state.selectedDrawingTool == 'fibonacci'
                ? const Color(0xFF2962FF)
                : Colors.white70,
          ),
          onPressed: () {
            controller.setInteractionMode(
              state.interactionMode == InteractionMode.drawing &&
                      state.selectedDrawingTool == 'fibonacci'
                  ? InteractionMode.navigation
                  : InteractionMode.drawing,
              drawingTool: 'fibonacci',
            );
          },
          tooltip: 'Fibonacci',
        ),
        IconButton(
          icon: Icon(
            Icons.touch_app,
            color: state.interactionMode == InteractionMode.navigation
                ? const Color(0xFF2962FF)
                : Colors.white70,
          ),
          onPressed: () => controller.setInteractionMode(InteractionMode.navigation),
          tooltip: 'Navigation Mode',
        ),
      ],
    );
  }

  Widget _buildZoomControls(ChartController controller) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_in, color: Colors.white70),
          onPressed: () => controller.onZoom(1.2),
          tooltip: 'Zoom In',
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out, color: Colors.white70),
          onPressed: () => controller.onZoom(0.8),
          tooltip: 'Zoom Out',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white70),
          onPressed: () => controller.resetZoom(),
          tooltip: 'Reset Zoom',
        ),
      ],
    );
  }

  Widget _buildChartArea(ChartState state, ChartController controller) {
    if (state.stage == ChartLoadingStage.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.stage == ChartLoadingStage.error) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Error loading chart',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.visibleCandles.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Calculate bottom panel height
    final hasBottomIndicators = state.activeBottomIndicators.isNotEmpty;
    const bottomPanelHeight = 150.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mainChartHeight = hasBottomIndicators
            ? constraints.maxHeight - bottomPanelHeight
            : constraints.maxHeight;

        return Column(
          children: [
            // Main chart area
            SizedBox(
              height: mainChartHeight,
              child: _buildMainChart(state, controller, Size(constraints.maxWidth, mainChartHeight)),
            ),

            // Bottom indicator panels
            if (hasBottomIndicators)
              SizedBox(
                height: bottomPanelHeight,
                child: _buildBottomIndicators(state, Size(constraints.maxWidth, bottomPanelHeight)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainChart(ChartState state, ChartController controller, Size size) {
    const priceAxisWidth = 60.0;
    const timeAxisHeight = 30.0;

    return ChartGestureHandler(
      controller: controller,
      state: state,
      chartSize: Size(size.width - priceAxisWidth, size.height - timeAxisHeight),
      child: Row(
        children: [
          // Main chart canvas
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Grid
                      CustomPaint(
                        size: Size.infinite,
                        painter: GridPainter(
                          candles: state.visibleCandles,
                          verticalScale: state.verticalScale,
                          verticalOffset: state.verticalOffset,
                        ),
                      ),
                      // Candles
                      CustomPaint(
                        size: Size.infinite,
                        painter: CandlePainter(
                          candles: state.visibleCandles,
                          verticalScale: state.verticalScale,
                          verticalOffset: state.verticalOffset,
                        ),
                      ),
                      // Overlay indicators
                      if (state.activeOverlayIndicators.isNotEmpty)
                        CustomPaint(
                          size: Size.infinite,
                          painter: OverlayIndicatorPainter(
                            candles: state.visibleCandles,
                            indicators: state.activeOverlayIndicators,
                            verticalScale: state.verticalScale,
                            verticalOffset: state.verticalOffset,
                          ),
                        ),
                      // Drawings
                      if (state.drawings.isNotEmpty || state.currentDraftDrawing != null)
                        CustomPaint(
                          size: Size.infinite,
                          painter: DrawingPainter(
                            candles: state.visibleCandles,
                            drawings: state.drawings,
                            draftDrawing: state.currentDraftDrawing,
                            selectedDrawingId: state.selectedDrawingId,
                            verticalScale: state.verticalScale,
                            verticalOffset: state.verticalOffset,
                          ),
                        ),
                    ],
                  ),
                ),
                // Time axis
                SizedBox(
                  height: timeAxisHeight,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: TimeAxisPainter(
                      candles: state.visibleCandles,
                      height: timeAxisHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Price axis
          SizedBox(
            width: priceAxisWidth,
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PriceAxisPainter(
                      candles: state.visibleCandles,
                      verticalScale: state.verticalScale,
                      verticalOffset: state.verticalOffset,
                      width: priceAxisWidth,
                    ),
                  ),
                ),
                const SizedBox(height: timeAxisHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIndicators(ChartState state, Size size) {
    // For simplicity, showing one indicator at a time
    // In a full implementation, you could stack multiple indicators
    final indicator = state.activeBottomIndicators.first;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A2E39), width: 1)),
      ),
      child: CustomPaint(
        size: size,
        painter: indicator is RSIIndicator
            ? RSIPainter(
                candles: state.visibleCandles,
                indicator: indicator,
              )
            : indicator is MACDIndicator
                ? MACDPainter(
                    candles: state.visibleCandles,
                    indicator: indicator,
                  )
                : null,
      ),
    );
  }
}