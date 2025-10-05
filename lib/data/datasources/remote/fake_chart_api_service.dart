// data/datasources/remote/fake_chart_api_service.dart
import 'dart:async';
import 'dart:math';
import '../../models/candle_dto.dart';

class FakeChartApiService {
  final Random _random = Random();
  double _basePrice = 50000.0;
  
  /// Tane tane candle datası üreten stream
  Stream<CandleDto> generateCandlesStream({
    required String symbol,
    required Duration interval,
    required int count,
    Duration delay = const Duration(milliseconds: 100),
  }) async* {
    final now = DateTime.now();
    
    for (int i = count - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);
      final candle = _generateSingleCandle(timestamp);
      
      yield candle;
      
      // Delay ekle (stream akışı simülasyonu)
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }
    }
  }

  /// Belirli sayıda candle listesi döndürür
  Future<List<CandleDto>> fetchLatestCandles({
    required String symbol,
    required Duration interval,
    int count = 1000,
  }) async {
    final candles = <CandleDto>[];
    final now = DateTime.now();
    
    for (int i = count - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);
      final candle = _generateSingleCandle(timestamp);
      candles.add(candle);
    }
    
    return candles;
  }

  /// Tarihsel mum verilerini çeker
  Future<List<CandleDto>> fetchCandles({
    required String symbol,
    required Duration interval,
    required DateTime from,
    required DateTime to,
    int? limit,
  }) async {
    final candles = <CandleDto>[];
    DateTime current = from;
    int count = 0;
    
    while (current.isBefore(to)) {
      if (limit != null && count >= limit) break;
      
      final candle = _generateSingleCandle(current);
      candles.add(candle);
      
      current = current.add(interval);
      count++;
    }
    
    return candles;
  }

  /// Tek bir candle üretir
  CandleDto _generateSingleCandle(DateTime timestamp) {
    // Fiyat değişimi (-2% ile +2% arası)
    final priceChange = _basePrice * (_random.nextDouble() * 0.04 - 0.02);
    _basePrice += priceChange;
    
    // Open fiyatı
    final open = _basePrice;
    
    // High ve Low hesapla
    final volatility = _basePrice * 0.01; // %1 volatilite
    final high = open + _random.nextDouble() * volatility;
    final low = open - _random.nextDouble() * volatility;
    
    // Close fiyatı (high-low aralığında)
    final close = low + _random.nextDouble() * (high - low);
    _basePrice = close; // Bir sonraki candle için base fiyat
    
    // Volume (rastgele)
    final volume = 1000000 + _random.nextDouble() * 5000000;
    
    return CandleDto(
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      timestampMs: timestamp.millisecondsSinceEpoch,
    );
  }

  /// Gerçekçi trend oluşturan candle generator
  Stream<CandleDto> generateRealisticCandlesStream({
    required String symbol,
    required Duration interval,
    required int count,
    Duration delay = const Duration(milliseconds: 50),
    double trendStrength = 0.3, // 0 = rastgele, 1 = güçlü trend
  }) async* {
    final now = DateTime.now();
    bool isUptrend = _random.nextBool();
    int trendDuration = 10 + _random.nextInt(20);
    int candleCount = 0;
    
    for (int i = count - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);
      
      // Trend yönünü belirli aralıklarla değiştir
      if (candleCount >= trendDuration) {
        isUptrend = !isUptrend;
        trendDuration = 10 + _random.nextInt(20);
        candleCount = 0;
      }
      
      final candle = _generateTrendCandle(timestamp, isUptrend, trendStrength);
      yield candle;
      
      candleCount++;
      
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }
    }
  }

  CandleDto _generateTrendCandle(DateTime timestamp, bool isUptrend, double strength) {
    // Trend yönüne göre fiyat değişimi
    final trendBias = isUptrend ? strength : -strength;
    final randomFactor = (_random.nextDouble() * 2 - 1) * (1 - strength);
    final priceChange = _basePrice * 0.02 * (trendBias + randomFactor);
    
    _basePrice += priceChange;
    
    final open = _basePrice;
    final volatility = _basePrice * 0.015;
    
    // Trend yönüne göre candle şekli
    final bodySize = _random.nextDouble() * volatility;
    final close = isUptrend 
        ? open + bodySize * (0.5 + _random.nextDouble() * 0.5)
        : open - bodySize * (0.5 + _random.nextDouble() * 0.5);
    
    final high = max(open, close) + _random.nextDouble() * volatility * 0.5;
    final low = min(open, close) - _random.nextDouble() * volatility * 0.5;
    
    _basePrice = close;
    
    final volume = 1000000 + _random.nextDouble() * 5000000;
    
    return CandleDto(
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      timestampMs: timestamp.millisecondsSinceEpoch,
    );
  }

  /// Base fiyatı sıfırla
  void resetBasePrice(double price) {
    _basePrice = price;
  }

  void dispose() {
    // Cleanup if needed
  }
}