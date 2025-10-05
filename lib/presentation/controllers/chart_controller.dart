import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lidya/domain/entities/indicators/bollinger_bands.dart';
import 'package:lidya/domain/entities/indicators/macd.dart';
import 'package:lidya/domain/entities/indicators/moving_average.dart';
import 'package:lidya/domain/entities/indicators/rsi.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/indicators/indicator.dart';
import '../../domain/entities/drawing/drawing.dart';
import '../../domain/repositories/chart_repository.dart';
import '../../domain/services/indicator_calculator.dart';
import '../state/chart_state.dart';

class ChartController extends StateNotifier<ChartState> {
  final ChartRepository _repository;
  StreamSubscription<Candle>? _liveDataSubscription;

  static const int defaultVisibleCandles = 100;
  static const double minHorizontalScale = 0.2;
  static const double maxHorizontalScale = 5.0;
  static const double minVerticalScale = 0.5;
  static const double maxVerticalScale = 3.0;

  ChartController(
    this._repository, {
    required String symbol,
    Duration interval = const Duration(minutes: 15),
  }) : super(ChartState(symbol: symbol, interval: interval)) {
    loadInitialData();
  }

  /// Load initial chart data
  Future<void> loadInitialData() async {
    state = state.copyWith(stage: ChartLoadingStage.loading);

    try {
      final candles = await _repository.getHistoricalData(
        symbol: state.symbol,
        interval: state.interval,
        limit: 1000,
      );

      if (candles.isEmpty) {
        state = state.copyWith(
          stage: ChartLoadingStage.error,
          errorMessage: 'No data available',
        );
        return;
      }

      // Sort by timestamp
      candles.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Set visible range to last N candles
      final visibleCount = defaultVisibleCandles.clamp(1, candles.length);
      final startIndex = candles.length - visibleCount;

      state = state.copyWith(
        allCandles: candles,
        visibleCandles: candles.sublist(startIndex),
        visibleStartIndex: startIndex,
        visibleEndIndex: candles.length - 1,
        stage: ChartLoadingStage.loaded,
      );

      // Load drawings
      await _loadDrawings();

      // Subscribe to live data
      _subscribeToLiveData();
    } catch (e) {
      state = state.copyWith(
        stage: ChartLoadingStage.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _loadDrawings() async {
    try {
      final drawings = await _repository.getDrawings(state.symbol);
      state = state.copyWith(drawings: drawings);
    } catch (e) {
      // Silently fail, drawings are not critical
      debugPrint('Failed to load drawings: $e');
    }
  }

  void _subscribeToLiveData() {
    // _liveDataSubscription?.cancel();
    // _liveDataSubscription = _repository.subscribeToLiveData(state.symbol).listen(
    //   _handleNewCandle,
    //   onError: (error) {
    //     debugPrint('Live data error: $error');
    //   },
    // );
  }

  void _handleNewCandle(Candle newCandle) {
    final candles = List<Candle>.from(state.allCandles);

    if (candles.isEmpty) {
      candles.add(newCandle);
    } else {
      final lastCandle = candles.last;

      // Check if update to existing candle or new candle
      if (lastCandle.timestamp == newCandle.timestamp) {
        candles[candles.length - 1] = newCandle;
      } else {
        candles.add(newCandle);
      }
    }

    _updateVisibleCandles(candles);

    // Recalculate active indicators with new data
    _recalculateIndicators();
  }

  void _updateVisibleCandles(List<Candle> allCandles) {
    final startIndex = state.visibleStartIndex.clamp(0, allCandles.length - 1);
    final endIndex = state.visibleEndIndex.clamp(startIndex, allCandles.length - 1);

    state = state.copyWith(
      allCandles: allCandles,
      visibleCandles: allCandles.sublist(startIndex, endIndex + 1),
      visibleStartIndex: startIndex,
      visibleEndIndex: endIndex,
    );
  }

  /// Horizontal pan (left/right scrolling)
  void onPanHorizontally(double deltaPixels, double canvasWidth) {
    if (state.allCandles.isEmpty) return;

    final candleWidth = canvasWidth / state.visibleCandles.length;
    final candleShift = (deltaPixels / candleWidth).round();

    if (candleShift == 0) return;

    // Calculate new indices
    int newStartIndex = (state.visibleStartIndex - candleShift).clamp(0, state.allCandles.length - 1);
    int newEndIndex = (state.visibleEndIndex - candleShift).clamp(0, state.allCandles.length - 1);

    // Maintain visible count
    final visibleCount = state.visibleEndIndex - state.visibleStartIndex + 1;
    if (newEndIndex - newStartIndex + 1 != visibleCount) {
      newEndIndex = (newStartIndex + visibleCount - 1).clamp(0, state.allCandles.length - 1);
    }

    if (newStartIndex != state.visibleStartIndex || newEndIndex != state.visibleEndIndex) {
      state = state.copyWith(
        visibleStartIndex: newStartIndex,
        visibleEndIndex: newEndIndex,
        visibleCandles: state.allCandles.sublist(newStartIndex, newEndIndex + 1),
      );

      // Load more data if approaching edge
      if (newStartIndex < 50) {
        _loadMoreHistoricalData();
      }
    }
  }

  /// Vertical pan (price axis scrolling)
  void onPanVertically(double deltaPixels) {
    state = state.copyWith(
      verticalOffset: state.verticalOffset + deltaPixels,
    );
  }

  /// Horizontal zoom (time axis)
  void onZoom(double scaleFactor) {
    if (state.allCandles.isEmpty) return;

    final newScale = (state.horizontalScale * scaleFactor)
        .clamp(minHorizontalScale, maxHorizontalScale);

    if (newScale == state.horizontalScale) return;

    // Calculate new visible count
    final currentVisibleCount = state.visibleEndIndex - state.visibleStartIndex + 1;
    final newVisibleCount = (defaultVisibleCandles / newScale)
        .round()
        .clamp(5, state.allCandles.length);

    // Adjust around center
    final centerIndex = ((state.visibleStartIndex + state.visibleEndIndex) / 2).round();
    final halfCount = newVisibleCount ~/ 2;

    int newStartIndex = (centerIndex - halfCount).clamp(0, state.allCandles.length - 1);
    int newEndIndex = (centerIndex + halfCount).clamp(0, state.allCandles.length - 1);

    // Ensure we have the right count
    if (newEndIndex - newStartIndex + 1 < newVisibleCount && newEndIndex < state.allCandles.length - 1) {
      newEndIndex = (newStartIndex + newVisibleCount - 1).clamp(0, state.allCandles.length - 1);
    }

    state = state.copyWith(
      horizontalScale: newScale,
      visibleStartIndex: newStartIndex,
      visibleEndIndex: newEndIndex,
      visibleCandles: state.allCandles.sublist(newStartIndex, newEndIndex + 1),
    );
  }

  /// Vertical zoom (price axis)
  void onVerticalZoom(double scaleFactor) {
    final newScale = (state.verticalScale * scaleFactor)
        .clamp(minVerticalScale, maxVerticalScale);
    state = state.copyWith(verticalScale: newScale);
  }

  /// Reset zoom to default
  void resetZoom() {
    if (state.allCandles.isEmpty) return;

    final visibleCount = defaultVisibleCandles.clamp(1, state.allCandles.length);
    final startIndex = state.allCandles.length - visibleCount;

    state = state.copyWith(
      horizontalScale: 1.0,
      verticalScale: 1.0,
      verticalOffset: 0.0,
      visibleStartIndex: startIndex,
      visibleEndIndex: state.allCandles.length - 1,
      visibleCandles: state.allCandles.sublist(startIndex),
    );
  }

  /// Toggle technical indicator
  void toggleIndicator(IndicatorType type, {Map<String, dynamic>? params}) {
    // Check if indicator already exists
    final existingOverlay = state.activeOverlayIndicators.where((i) => i.type == type).toList();
    final existingBottom = state.activeBottomIndicators.where((i) => i.type == type).toList();

    if (existingOverlay.isNotEmpty || existingBottom.isNotEmpty) {
      // Remove indicator
      state = state.copyWith(
        activeOverlayIndicators: state.activeOverlayIndicators.where((i) => i.type != type).toList(),
        activeBottomIndicators: state.activeBottomIndicators.where((i) => i.type != type).toList(),
      );
    } else {
      // Add indicator
      final indicator = IndicatorCalculator.createIndicator(
        type: type,
        candles: state.allCandles,
        params: params,
      );

      if (_isOverlayIndicator(type)) {
        state = state.copyWith(
          activeOverlayIndicators: [...state.activeOverlayIndicators, indicator],
        );
      } else {
        state = state.copyWith(
          activeBottomIndicators: [...state.activeBottomIndicators, indicator],
        );
      }
    }
  }

  bool _isOverlayIndicator(IndicatorType type) {
    return type == IndicatorType.sma ||
        type == IndicatorType.ema ||
        type == IndicatorType.dema ||
        type == IndicatorType.bollingerBands;
  }

  void _recalculateIndicators() {
    if (state.allCandles.isEmpty) return;

    // Recalculate overlay indicators
    final newOverlayIndicators = state.activeOverlayIndicators.map((indicator) {
      return IndicatorCalculator.createIndicator(
        type: indicator.type,
        candles: state.allCandles,
        params: _getIndicatorParams(indicator),
      );
    }).toList();

    // Recalculate bottom indicators
    final newBottomIndicators = state.activeBottomIndicators.map((indicator) {
      return IndicatorCalculator.createIndicator(
        type: indicator.type,
        candles: state.allCandles,
        params: _getIndicatorParams(indicator),
      );
    }).toList();

    state = state.copyWith(
      activeOverlayIndicators: newOverlayIndicators,
      activeBottomIndicators: newBottomIndicators,
    );
  }

  Map<String, dynamic> _getIndicatorParams(Indicator indicator) {
    final params = <String, dynamic>{
      'color': indicator.color,
    };

    if (indicator is MovingAverageIndicator) {
      params['period'] = indicator.period;
    } else if (indicator is BollingerBandsIndicator) {
      params['period'] = indicator.period;
      params['standardDeviations'] = indicator.standardDeviations;
    } else if (indicator is RSIIndicator) {
      params['period'] = indicator.period;
    } else if (indicator is MACDIndicator) {
      params['fastPeriod'] = indicator.fastPeriod;
      params['slowPeriod'] = indicator.slowPeriod;
      params['signalPeriod'] = indicator.signalPeriod;
    }

    return params;
  }

  /// Set interaction mode
  void setInteractionMode(InteractionMode mode, {String? drawingTool}) {
    state = state.copyWith(
      interactionMode: mode,
      selectedDrawingTool: drawingTool,
      clearDrawingTool: drawingTool == null,
    );
  }

  /// Add drawing
  Future<void> addDrawing(Drawing drawing) async {
    try {
      await _repository.saveDrawing(state.symbol, drawing);
      state = state.copyWith(
        drawings: [...state.drawings, drawing],
        clearDraftDrawing: true,
      );
    } catch (e) {
      debugPrint('Failed to save drawing: $e');
    }
  }

  /// Update draft drawing (preview)
  void updateDraftDrawing(Drawing? drawing) {
    state = state.copyWith(
      currentDraftDrawing: drawing,
      clearDraftDrawing: drawing == null,
    );
  }

  /// Remove drawing
  Future<void> removeDrawing(String drawingId) async {
    try {
      await _repository.deleteDrawing(state.symbol, drawingId);
      state = state.copyWith(
        drawings: state.drawings.where((d) => d.id != drawingId).toList(),
      );
    } catch (e) {
      debugPrint('Failed to delete drawing: $e');
    }
  }

  /// Update crosshair position
  void updateCrosshair(Offset? position, int? candleIndex) {
    state = state.copyWith(
      crosshairPosition: position,
      clearCrosshair: position == null,
      hoveredCandleIndex: candleIndex,
      clearHoveredCandle: candleIndex == null,
    );
  }

  Future<void> _loadMoreHistoricalData() async {
    // Prevent duplicate loads
    if (state.allCandles.isEmpty) return;

    try {
      final oldestCandle = state.allCandles.first;
      final newCandles = await _repository.getHistoricalData(
        symbol: state.symbol,
        interval: state.interval,
        to: oldestCandle.timestamp,
        limit: 500,
      );

      if (newCandles.isNotEmpty) {
        final combined = [...newCandles, ...state.allCandles];
        combined.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Adjust indices for new data
        final indexOffset = newCandles.length;
        state = state.copyWith(
          allCandles: combined,
          visibleStartIndex: state.visibleStartIndex + indexOffset,
          visibleEndIndex: state.visibleEndIndex + indexOffset,
          visibleCandles: combined.sublist(
            state.visibleStartIndex + indexOffset,
            state.visibleEndIndex + indexOffset + 1,
          ),
        );

        _recalculateIndicators();
      }
    } catch (e) {
      debugPrint('Failed to load more historical data: $e');
    }
  }

  @override
  void dispose() {
    _liveDataSubscription?.cancel();
    super.dispose();
  }
}
