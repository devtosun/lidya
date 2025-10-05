import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/indicators/indicator.dart';
import '../../domain/entities/drawing/drawing.dart';

enum ChartLoadingStage {
  initial,
  loading,
  loaded,
  error,
}

enum InteractionMode {
  navigation,
  drawing,
}

class ChartState extends Equatable {
  // Data
  final List<Candle> allCandles;
  final List<Candle> visibleCandles;

  // Indicators
  final List<Indicator> activeOverlayIndicators;
  final List<Indicator> activeBottomIndicators;

  // Drawings
  final List<Drawing> drawings;
  final Drawing? currentDraftDrawing;
  final String? selectedDrawingId;

  // View parameters
  final int visibleStartIndex;
  final int visibleEndIndex;
  final double horizontalScale; // Zoom level (1.0 = normal, >1 = zoomed in)
  final double verticalScale;
  final double verticalOffset; // For vertical panning

  // Interaction
  final InteractionMode interactionMode;
  final String? selectedDrawingTool; // 'trendline', 'fibonacci', 'freehand'

  // Crosshair/Hover
  final Offset? crosshairPosition;
  final int? hoveredCandleIndex;

  // State
  final ChartLoadingStage stage;
  final String? errorMessage;
  final String symbol;
  final Duration interval;

  const ChartState({
    this.allCandles = const [],
    this.visibleCandles = const [],
    this.activeOverlayIndicators = const [],
    this.activeBottomIndicators = const [],
    this.drawings = const [],
    this.currentDraftDrawing,
    this.selectedDrawingId,
    this.visibleStartIndex = 0,
    this.visibleEndIndex = 0,
    this.horizontalScale = 1.0,
    this.verticalScale = 1.0,
    this.verticalOffset = 0.0,
    this.interactionMode = InteractionMode.navigation,
    this.selectedDrawingTool,
    this.crosshairPosition,
    this.hoveredCandleIndex,
    this.stage = ChartLoadingStage.initial,
    this.errorMessage,
    required this.symbol,
    this.interval = const Duration(minutes: 15),
  });

  ChartState copyWith({
    List<Candle>? allCandles,
    List<Candle>? visibleCandles,
    List<Indicator>? activeOverlayIndicators,
    List<Indicator>? activeBottomIndicators,
    List<Drawing>? drawings,
    Drawing? currentDraftDrawing,
    bool clearDraftDrawing = false,
    String? selectedDrawingId,
    bool clearSelectedDrawing = false,
    int? visibleStartIndex,
    int? visibleEndIndex,
    double? horizontalScale,
    double? verticalScale,
    double? verticalOffset,
    InteractionMode? interactionMode,
    String? selectedDrawingTool,
    bool clearDrawingTool = false,
    Offset? crosshairPosition,
    bool clearCrosshair = false,
    int? hoveredCandleIndex,
    bool clearHoveredCandle = false,
    ChartLoadingStage? stage,
    String? errorMessage,
    bool clearError = false,
    String? symbol,
    Duration? interval,
  }) {
    return ChartState(
      allCandles: allCandles ?? this.allCandles,
      visibleCandles: visibleCandles ?? this.visibleCandles,
      activeOverlayIndicators: activeOverlayIndicators ?? this.activeOverlayIndicators,
      activeBottomIndicators: activeBottomIndicators ?? this.activeBottomIndicators,
      drawings: drawings ?? this.drawings,
      currentDraftDrawing: clearDraftDrawing ? null : (currentDraftDrawing ?? this.currentDraftDrawing),
      selectedDrawingId: clearSelectedDrawing ? null : (selectedDrawingId ?? this.selectedDrawingId),
      visibleStartIndex: visibleStartIndex ?? this.visibleStartIndex,
      visibleEndIndex: visibleEndIndex ?? this.visibleEndIndex,
      horizontalScale: horizontalScale ?? this.horizontalScale,
      verticalScale: verticalScale ?? this.verticalScale,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      interactionMode: interactionMode ?? this.interactionMode,
      selectedDrawingTool: clearDrawingTool ? null : (selectedDrawingTool ?? this.selectedDrawingTool),
      crosshairPosition: clearCrosshair ? null : (crosshairPosition ?? this.crosshairPosition),
      hoveredCandleIndex: clearHoveredCandle ? null : (hoveredCandleIndex ?? this.hoveredCandleIndex),
      stage: stage ?? this.stage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
    );
  }

  @override
  List<Object?> get props => [
    allCandles,
    visibleCandles,
    activeOverlayIndicators,
    activeBottomIndicators,
    drawings,
    currentDraftDrawing,
    selectedDrawingId,
    visibleStartIndex,
    visibleEndIndex,
    horizontalScale,
    verticalScale,
    verticalOffset,
    interactionMode,
    selectedDrawingTool,
    crosshairPosition,
    hoveredCandleIndex,
    stage,
    errorMessage,
    symbol,
    interval,
  ];
}
