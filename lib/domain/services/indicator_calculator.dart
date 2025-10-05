import 'dart:math' as math;
import '../entities/candle.dart';
import '../entities/indicators/indicator.dart';
import '../entities/indicators/moving_average.dart';
import '../entities/indicators/bollinger_bands.dart';
import '../entities/indicators/rsi.dart';
import '../entities/indicators/macd.dart';

class IndicatorCalculator {
  /// Simple Moving Average (SMA) hesapla
  static Map<DateTime, double> calculateSMA({
    required List<Candle> candles,
    required int period,
  }) {
    final result = <DateTime, double>{};
    
    for (int i = period - 1; i < candles.length; i++) {
      double sum = 0;
      for (int j = 0; j < period; j++) {
        sum += candles[i - j].close;
      }
      result[candles[i].timestamp] = sum / period;
    }
    
    return result;
  }

  /// Exponential Moving Average (EMA) hesapla
  static Map<DateTime, double> calculateEMA({
    required List<Candle> candles,
    required int period,
  }) {
    if (candles.length < period) return {};
    
    final result = <DateTime, double>{};
    final multiplier = 2.0 / (period + 1);
    
    // İlk EMA değeri SMA ile başlar
    double ema = 0;
    for (int i = 0; i < period; i++) {
      ema += candles[i].close;
    }
    ema /= period;
    result[candles[period - 1].timestamp] = ema;
    
    // Sonraki değerler EMA formülü ile
    for (int i = period; i < candles.length; i++) {
      ema = (candles[i].close - ema) * multiplier + ema;
      result[candles[i].timestamp] = ema;
    }
    
    return result;
  }

  /// Double Exponential Moving Average (DEMA) hesapla
  static Map<DateTime, double> calculateDEMA({
    required List<Candle> candles,
    required int period,
  }) {
    final ema = calculateEMA(candles: candles, period: period);
    
    // EMA of EMA hesapla
    final emaCandles = candles.where((c) => ema.containsKey(c.timestamp)).map((c) {
      return c.copyWith(close: ema[c.timestamp]!);
    }).toList();
    
    final emaOfEma = calculateEMA(candles: emaCandles, period: period);
    
    // DEMA = 2 * EMA - EMA(EMA)
    final result = <DateTime, double>{};
    for (final timestamp in emaOfEma.keys) {
      result[timestamp] = 2 * ema[timestamp]! - emaOfEma[timestamp]!;
    }
    
    return result;
  }

  /// Bollinger Bands hesapla
  static BollingerBandsIndicator calculateBollingerBands({
    required String id,
    required List<Candle> candles,
    required int period,
    double standardDeviations = 2.0,
    String color = '#2962FF',
  }) {
    final sma = calculateSMA(candles: candles, period: period);
    final upperBand = <DateTime, double>{};
    final lowerBand = <DateTime, double>{};
    
    for (int i = period - 1; i < candles.length; i++) {
      final timestamp = candles[i].timestamp;
      final mean = sma[timestamp]!;
      
      // Standart sapma hesapla
      double variance = 0;
      for (int j = 0; j < period; j++) {
        final diff = candles[i - j].close - mean;
        variance += diff * diff;
      }
      final stdDev = math.sqrt(variance / period);
      
      upperBand[timestamp] = mean + (standardDeviations * stdDev);
      lowerBand[timestamp] = mean - (standardDeviations * stdDev);
    }
    
    return BollingerBandsIndicator(
      id: id,
      period: period,
      standardDeviations: standardDeviations,
      upperBand: upperBand,
      middleBand: sma,
      lowerBand: lowerBand,
      color: color,
    );
  }

  /// RSI (Relative Strength Index) hesapla
  static RSIIndicator calculateRSI({
    required String id,
    required List<Candle> candles,
    required int period,
    String color = '#7B1FA2',
  }) {
    if (candles.length < period + 1) {
      return RSIIndicator(id: id, period: period, values: {}, color: color);
    }
    
    final result = <DateTime, double>{};
    double avgGain = 0;
    double avgLoss = 0;
    
    // İlk period için ortalama gain/loss hesapla
    for (int i = 1; i <= period; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }
    avgGain /= period;
    avgLoss /= period;
    
    // İlk RSI değeri
    double rs = avgLoss == 0 ? 100 : avgGain / avgLoss;
    result[candles[period].timestamp] = 100 - (100 / (1 + rs));
    
    // Smoothed RSI
    for (int i = period + 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      final gain = change > 0 ? change : 0;
      final loss = change < 0 ? change.abs() : 0;
      
      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;
      
      rs = avgLoss == 0 ? 100 : avgGain / avgLoss;
      result[candles[i].timestamp] = 100 - (100 / (1 + rs));
    }
    
    return RSIIndicator(
      id: id,
      period: period,
      values: result,
      color: color,
    );
  }

  /// MACD hesapla
  static MACDIndicator calculateMACD({
    required String id,
    required List<Candle> candles,
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
    String color = '#FF6D00',
  }) {
    final fastEMA = calculateEMA(candles: candles, period: fastPeriod);
    final slowEMA = calculateEMA(candles: candles, period: slowPeriod);
    
    // MACD Line = Fast EMA - Slow EMA
    final macdLine = <DateTime, double>{};
    for (final timestamp in fastEMA.keys) {
      if (slowEMA.containsKey(timestamp)) {
        macdLine[timestamp] = fastEMA[timestamp]! - slowEMA[timestamp]!;
      }
    }
    
    // Signal Line = EMA of MACD Line
    final macdCandles = candles.where((c) => macdLine.containsKey(c.timestamp)).map((c) {
      return c.copyWith(close: macdLine[c.timestamp]!);
    }).toList();
    
    final signalLine = calculateEMA(candles: macdCandles, period: signalPeriod);
    
    // Histogram = MACD - Signal
    final histogram = <DateTime, double>{};
    for (final timestamp in signalLine.keys) {
      histogram[timestamp] = macdLine[timestamp]! - signalLine[timestamp]!;
    }
    
    return MACDIndicator(
      id: id,
      fastPeriod: fastPeriod,
      slowPeriod: slowPeriod,
      signalPeriod: signalPeriod,
      macdLine: macdLine,
      signalLine: signalLine,
      histogram: histogram,
      color: color,
    );
  }

  /// İndikatör ekle
  static Indicator createIndicator({
    required IndicatorType type,
    required List<Candle> candles,
    Map<String, dynamic>? params,
  }) {
    final id = '${type.name}_${DateTime.now().millisecondsSinceEpoch}';
    
    switch (type) {
      case IndicatorType.sma:
        final period = params?['period'] ?? 20;
        final color = params?['color'] ?? '#2196F3';
        return MovingAverageIndicator(
          id: id,
          period: period,
          values: calculateSMA(candles: candles, period: period),
          color: color,
          isExponential: false,
        );
        
      case IndicatorType.ema:
        final period = params?['period'] ?? 200;
        final color = params?['color'] ?? '#FF9800';
        return MovingAverageIndicator(
          id: id,
          period: period,
          values: calculateEMA(candles: candles, period: period),
          color: color,
          isExponential: true,
        );
        
      case IndicatorType.dema:
        final period = params?['period'] ?? 200;
        final color = params?['color'] ?? '#4CAF50';
        return MovingAverageIndicator(
          id: id,
          period: period,
          values: calculateDEMA(candles: candles, period: period),
          color: color,
          isExponential: true,
        );
        
      case IndicatorType.bollingerBands:
        final period = params?['period'] ?? 20;
        final stdDev = params?['standardDeviations'] ?? 2.0;
        final color = params?['color'] ?? '#2962FF';
        return calculateBollingerBands(
          id: id,
          candles: candles,
          period: period,
          standardDeviations: stdDev,
          color: color,
        );
        
      case IndicatorType.rsi:
        final period = params?['period'] ?? 14;
        final color = params?['color'] ?? '#7B1FA2';
        return calculateRSI(
          id: id,
          candles: candles,
          period: period,
          color: color,
        );
        
      case IndicatorType.macd:
        final fast = params?['fastPeriod'] ?? 12;
        final slow = params?['slowPeriod'] ?? 26;
        final signal = params?['signalPeriod'] ?? 9;
        final color = params?['color'] ?? '#FF6D00';
        return calculateMACD(
          id: id,
          candles: candles,
          fastPeriod: fast,
          slowPeriod: slow,
          signalPeriod: signal,
          color: color,
        );
    }
  }
}