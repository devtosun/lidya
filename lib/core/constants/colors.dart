import 'package:flutter/material.dart';

// ============================================================================
// Theme Colors
// ============================================================================

class ThemeColors {
  final Color background;
  final Color surface;
  final Color gridLine;
  final Color text;
  final Color textSecondary;
  final Color border;

  const ThemeColors({
    required this.background,
    required this.surface,
    required this.gridLine,
    required this.text,
    required this.textSecondary,
    required this.border,
  });

  // Dark theme default
  factory ThemeColors.dark() {
    return const ThemeColors(
      background: Color(0xFF1E222D),
      surface: Color(0xFF2A2E39),
      gridLine: Color(0xFF363A45),
      text: Color(0xFFD1D4DC),
      textSecondary: Color(0xFF787B86),
      border: Color(0xFF363A45),
    );
  }

  // Light theme default
  factory ThemeColors.light() {
    return const ThemeColors(
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF8F9FD),
      gridLine: Color(0xFFE0E3EB),
      text: Color(0xFF131722),
      textSecondary: Color(0xFF787B86),
      border: Color(0xFFE0E3EB),
    );
  }

  ThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? gridLine,
    Color? text,
    Color? textSecondary,
    Color? border,
  }) {
    return ThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      gridLine: gridLine ?? this.gridLine,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }
}

// ============================================================================
// Candle Colors
// ============================================================================

class CandleColors {
  final Color bullish;
  final Color bearish;
  final Color bullishDark;
  final Color bearishDark;

  const CandleColors({
    required this.bullish,
    required this.bearish,
    required this.bullishDark,
    required this.bearishDark,
  });

  factory CandleColors.defaultColors() {
    return const CandleColors(
      bullish: Color(0xFF26A69A),
      bearish: Color(0xFFEF5350),
      bullishDark: Color(0xFF00897B),
      bearishDark: Color(0xFFD32F2F),
    );
  }

  // Alternative color scheme - Classic
  factory CandleColors.classic() {
    return const CandleColors(
      bullish: Color(0xFF4CAF50),
      bearish: Color(0xFFF44336),
      bullishDark: Color(0xFF388E3C),
      bearishDark: Color(0xFFC62828),
    );
  }

  // Alternative color scheme - Monochrome
  factory CandleColors.monochrome() {
    return const CandleColors(
      bullish: Color(0xFF000000),
      bearish: Color(0xFFFFFFFF),
      bullishDark: Color(0xFF424242),
      bearishDark: Color(0xFFEEEEEE),
    );
  }

  CandleColors copyWith({
    Color? bullish,
    Color? bearish,
    Color? bullishDark,
    Color? bearishDark,
  }) {
    return CandleColors(
      bullish: bullish ?? this.bullish,
      bearish: bearish ?? this.bearish,
      bullishDark: bullishDark ?? this.bullishDark,
      bearishDark: bearishDark ?? this.bearishDark,
    );
  }
}

// ============================================================================
// Volume Colors
// ============================================================================

class VolumeColors {
  final Color bullish;
  final Color bearish;

  const VolumeColors({
    required this.bullish,
    required this.bearish,
  });

  factory VolumeColors.defaultColors() {
    return const VolumeColors(
      bullish: Color(0x8026A69A),
      bearish: Color(0x80EF5350),
    );
  }

  factory VolumeColors.fromCandleColors(CandleColors candleColors) {
    return VolumeColors(
      bullish: candleColors.bullish.withOpacity(0.5),
      bearish: candleColors.bearish.withOpacity(0.5),
    );
  }

  VolumeColors copyWith({
    Color? bullish,
    Color? bearish,
  }) {
    return VolumeColors(
      bullish: bullish ?? this.bullish,
      bearish: bearish ?? this.bearish,
    );
  }
}

// ============================================================================
// Indicator Colors
// ============================================================================

class IndicatorColors {
  final Color blue;
  final Color orange;
  final Color purple;
  final Color cyan;
  final Color pink;
  final Color teal;
  final Color amber;
  final Color lime;

  const IndicatorColors({
    required this.blue,
    required this.orange,
    required this.purple,
    required this.cyan,
    required this.pink,
    required this.teal,
    required this.amber,
    required this.lime,
  });

  factory IndicatorColors.defaultColors() {
    return const IndicatorColors(
      blue: Color(0xFF2196F3),
      orange: Color(0xFFFF9800),
      purple: Color(0xFF9C27B0),
      cyan: Color(0xFF00BCD4),
      pink: Color(0xFFE91E63),
      teal: Color(0xFF009688),
      amber: Color(0xFFFFC107),
      lime: Color(0xFFCDDC39),
    );
  }

  // Get color by index (for multiple indicators)
  Color getByIndex(int index) {
    final colors = [blue, orange, purple, cyan, pink, teal, amber, lime];
    return colors[index % colors.length];
  }

  List<Color> get allColors => [blue, orange, purple, cyan, pink, teal, amber, lime];

  IndicatorColors copyWith({
    Color? blue,
    Color? orange,
    Color? purple,
    Color? cyan,
    Color? pink,
    Color? teal,
    Color? amber,
    Color? lime,
  }) {
    return IndicatorColors(
      blue: blue ?? this.blue,
      orange: orange ?? this.orange,
      purple: purple ?? this.purple,
      cyan: cyan ?? this.cyan,
      pink: pink ?? this.pink,
      teal: teal ?? this.teal,
      amber: amber ?? this.amber,
      lime: lime ?? this.lime,
    );
  }
}

// ============================================================================
// Drawing Tool Colors
// ============================================================================

class DrawingToolColors {
  final Color trendLine;
  final Color horizontalLine;
  final Color fibonacci;
  final Color rectangle;
  final Color ellipse;

  const DrawingToolColors({
    required this.trendLine,
    required this.horizontalLine,
    required this.fibonacci,
    required this.rectangle,
    required this.ellipse,
  });

  factory DrawingToolColors.defaultColors() {
    return const DrawingToolColors(
      trendLine: Color(0xFF2196F3),
      horizontalLine: Color(0xFF9E9E9E),
      fibonacci: Color(0xFFFFD700),
      rectangle: Color(0x402196F3),
      ellipse: Color(0x4026A69A),
    );
  }

  DrawingToolColors copyWith({
    Color? trendLine,
    Color? horizontalLine,
    Color? fibonacci,
    Color? rectangle,
    Color? ellipse,
  }) {
    return DrawingToolColors(
      trendLine: trendLine ?? this.trendLine,
      horizontalLine: horizontalLine ?? this.horizontalLine,
      fibonacci: fibonacci ?? this.fibonacci,
      rectangle: rectangle ?? this.rectangle,
      ellipse: ellipse ?? this.ellipse,
    );
  }
}

// ============================================================================
// Fibonacci Colors
// ============================================================================

class FibonacciColors {
  final Map<double, Color> levelColors;

  const FibonacciColors({required this.levelColors});

factory FibonacciColors.defaultColors() {
  return FibonacciColors(
    levelColors: {
      0.0: const Color(0xFFD32F2F),
      0.236: const Color(0xFFFF6F00),
      0.382: const Color(0xFFFDD835),
      0.5: const Color(0xFF388E3C),
      0.618: const Color(0xFF1976D2),
      0.786: const Color(0xFF512DA8),
      1.0: const Color(0xFF7B1FA2),
    },
  );
}

factory FibonacciColors.rainbow() {
  return FibonacciColors(
    levelColors: {
      0.0: const Color(0xFFFF0000),
      0.236: const Color(0xFFFF7F00),
      0.382: const Color(0xFFFFFF00),
      0.5: const Color(0xFF00FF00),
      0.618: const Color(0xFF0000FF),
      0.786: const Color(0xFF4B0082),
      1.0: const Color(0xFF9400D3),
    },
  );
}

  Color getColorForLevel(double level) {
    return levelColors[level] ?? const Color(0xFF9E9E9E);
  }

  FibonacciColors copyWith({Map<double, Color>? levelColors}) {
    return FibonacciColors(
      levelColors: levelColors ?? this.levelColors,
    );
  }
}

// ============================================================================
// RSI Colors
// ============================================================================

class RSIColors {
  final Color line;
  final Color overbought;
  final Color oversold;
  final Color midLine;

  const RSIColors({
    required this.line,
    required this.overbought,
    required this.oversold,
    required this.midLine,
  });

  factory RSIColors.defaultColors() {
    return const RSIColors(
      line: Color(0xFF9C27B0),
      overbought: Color(0x40EF5350),
      oversold: Color(0x4026A69A),
      midLine: Color(0x40787B86),
    );
  }

  RSIColors copyWith({
    Color? line,
    Color? overbought,
    Color? oversold,
    Color? midLine,
  }) {
    return RSIColors(
      line: line ?? this.line,
      overbought: overbought ?? this.overbought,
      oversold: oversold ?? this.oversold,
      midLine: midLine ?? this.midLine,
    );
  }
}

// ============================================================================
// MACD Colors
// ============================================================================

class MACDColors {
  final Color macdLine;
  final Color signalLine;
  final Color histogramPositive;
  final Color histogramNegative;

  const MACDColors({
    required this.macdLine,
    required this.signalLine,
    required this.histogramPositive,
    required this.histogramNegative,
  });

  factory MACDColors.defaultColors() {
    return const MACDColors(
      macdLine: Color(0xFF2196F3),
      signalLine: Color(0xFFFF9800),
      histogramPositive: Color(0x8026A69A),
      histogramNegative: Color(0x80EF5350),
    );
  }

  MACDColors copyWith({
    Color? macdLine,
    Color? signalLine,
    Color? histogramPositive,
    Color? histogramNegative,
  }) {
    return MACDColors(
      macdLine: macdLine ?? this.macdLine,
      signalLine: signalLine ?? this.signalLine,
      histogramPositive: histogramPositive ?? this.histogramPositive,
      histogramNegative: histogramNegative ?? this.histogramNegative,
    );
  }
}

// ============================================================================
// Bollinger Bands Colors
// ============================================================================

class BollingerBandsColors {
  final Color middle;
  final Color upper;
  final Color lower;
  final Color fill;

  const BollingerBandsColors({
    required this.middle,
    required this.upper,
    required this.lower,
    required this.fill,
  });

  factory BollingerBandsColors.defaultColors() {
    return const BollingerBandsColors(
      middle: Color(0xFF2196F3),
      upper: Color(0xFFEF5350),
      lower: Color(0xFF26A69A),
      fill: Color(0x202196F3),
    );
  }

  BollingerBandsColors copyWith({
    Color? middle,
    Color? upper,
    Color? lower,
    Color? fill,
  }) {
    return BollingerBandsColors(
      middle: middle ?? this.middle,
      upper: upper ?? this.upper,
      lower: lower ?? this.lower,
      fill: fill ?? this.fill,
    );
  }
}

// ============================================================================
// Interaction Colors
// ============================================================================

class InteractionColors {
  final Color selection;
  final Color controlPoint;
  final Color controlPointBorder;
  final Color crosshair;

  const InteractionColors({
    required this.selection,
    required this.controlPoint,
    required this.controlPointBorder,
    required this.crosshair,
  });

  factory InteractionColors.defaultColors() {
    return const InteractionColors(
      selection: Color(0xFF2196F3),
      controlPoint: Color(0xFFFFFFFF),
      controlPointBorder: Color(0xFF2196F3),
      crosshair: Color(0x80787B86),
    );
  }

  InteractionColors copyWith({
    Color? selection,
    Color? controlPoint,
    Color? controlPointBorder,
    Color? crosshair,
  }) {
    return InteractionColors(
      selection: selection ?? this.selection,
      controlPoint: controlPoint ?? this.controlPoint,
      controlPointBorder: controlPointBorder ?? this.controlPointBorder,
      crosshair: crosshair ?? this.crosshair,
    );
  }
}

// ============================================================================
// Alert Colors
// ============================================================================

class AlertColors {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AlertColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  factory AlertColors.defaultColors() {
    return const AlertColors(
      success: Color(0xFF4CAF50),
      warning: Color(0xFFFFC107),
      error: Color(0xFFF44336),
      info: Color(0xFF2196F3),
    );
  }

  AlertColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AlertColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }
}

// ============================================================================
// Main Chart Colors - Combines all color schemes
// ============================================================================

class ChartColors {
  final ThemeColors theme;
  final CandleColors candle;
  final VolumeColors volume;
  final IndicatorColors indicator;
  final DrawingToolColors drawingTool;
  final FibonacciColors fibonacci;
  final RSIColors rsi;
  final MACDColors macd;
  final BollingerBandsColors bollingerBands;
  final InteractionColors interaction;
  final AlertColors alert;

  const ChartColors({
    required this.theme,
    required this.candle,
    required this.volume,
    required this.indicator,
    required this.drawingTool,
    required this.fibonacci,
    required this.rsi,
    required this.macd,
    required this.bollingerBands,
    required this.interaction,
    required this.alert,
  });

  // Dark theme preset
  factory ChartColors.dark() {
    return ChartColors(
      theme: ThemeColors.dark(),
      candle: CandleColors.defaultColors(),
      volume: VolumeColors.defaultColors(),
      indicator: IndicatorColors.defaultColors(),
      drawingTool: DrawingToolColors.defaultColors(),
      fibonacci: FibonacciColors.defaultColors(),
      rsi: RSIColors.defaultColors(),
      macd: MACDColors.defaultColors(),
      bollingerBands: BollingerBandsColors.defaultColors(),
      interaction: InteractionColors.defaultColors(),
      alert: AlertColors.defaultColors(),
    );
  }

  // Light theme preset
  factory ChartColors.light() {
    return ChartColors(
      theme: ThemeColors.light(),
      candle: CandleColors.defaultColors(),
      volume: VolumeColors.defaultColors(),
      indicator: IndicatorColors.defaultColors(),
      drawingTool: DrawingToolColors.defaultColors(),
      fibonacci: FibonacciColors.defaultColors(),
      rsi: RSIColors.defaultColors(),
      macd: MACDColors.defaultColors(),
      bollingerBands: BollingerBandsColors.defaultColors(),
      interaction: InteractionColors.defaultColors(),
      alert: AlertColors.defaultColors(),
    );
  }

  // Classic trading view style
  factory ChartColors.tradingView() {
    return ChartColors(
      theme: ThemeColors.dark().copyWith(
        background: const Color(0xFF131722),
        surface: const Color(0xFF1E222D),
      ),
      candle: CandleColors.classic(),
      volume: VolumeColors.defaultColors(),
      indicator: IndicatorColors.defaultColors(),
      drawingTool: DrawingToolColors.defaultColors(),
      fibonacci: FibonacciColors.rainbow(),
      rsi: RSIColors.defaultColors(),
      macd: MACDColors.defaultColors(),
      bollingerBands: BollingerBandsColors.defaultColors(),
      interaction: InteractionColors.defaultColors(),
      alert: AlertColors.defaultColors(),
    );
  }

  ChartColors copyWith({
    ThemeColors? theme,
    CandleColors? candle,
    VolumeColors? volume,
    IndicatorColors? indicator,
    DrawingToolColors? drawingTool,
    FibonacciColors? fibonacci,
    RSIColors? rsi,
    MACDColors? macd,
    BollingerBandsColors? bollingerBands,
    InteractionColors? interaction,
    AlertColors? alert,
  }) {
    return ChartColors(
      theme: theme ?? this.theme,
      candle: candle ?? this.candle,
      volume: volume ?? this.volume,
      indicator: indicator ?? this.indicator,
      drawingTool: drawingTool ?? this.drawingTool,
      fibonacci: fibonacci ?? this.fibonacci,
      rsi: rsi ?? this.rsi,
      macd: macd ?? this.macd,
      bollingerBands: bollingerBands ?? this.bollingerBands,
      interaction: interaction ?? this.interaction,
      alert: alert ?? this.alert,
    );
  }
}