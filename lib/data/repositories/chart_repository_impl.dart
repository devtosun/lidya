// data/repositories/chart_repository_impl.dart
import 'dart:async';
import 'package:lidya/data/models/candle_dto.dart';
import 'package:lidya/domain/entities/drawing/drawing.dart';

import '../../../../domain/entities/candle.dart';
import '../../../../domain/repositories/chart_repository.dart';
import '../datasources/remote/chart_api_service.dart';
import '../datasources/remote/fake_chart_api_service.dart';
import '../datasources/remote/price_stream_service.dart';

class ChartRepositoryImpl implements ChartRepository {
  final ChartApiService? _apiService;
  final FakeChartApiService _fakeApiService;
  final PriceStreamService _streamService;
  final bool useFakeData;

  // In-memory cache
  final Map<String, List<Candle>> _memoryCache = {};
  final Map<String, List<Drawing>> _drawingsCache = {};
  final Map<String, StreamController<Candle>> _liveDataControllers = {};

  ChartRepositoryImpl({
    ChartApiService? apiService,
    required FakeChartApiService fakeApiService,
    required PriceStreamService streamService,
    this.useFakeData = true, // Development için true
  })  : _apiService = apiService,
        _fakeApiService = fakeApiService,
        _streamService = streamService;

  @override
  Future<List<Candle>> getHistoricalData({
    required String symbol,
    required Duration interval,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    try {
      final cacheKey = '$symbol-${interval.inMinutes}';
      
      // Önce memory cache'e bak
      if (_memoryCache.containsKey(cacheKey)) {
        final cached = _memoryCache[cacheKey]!;
        if (from != null && to != null) {
          return cached.where((c) => 
            c.timestamp.isAfter(from) && c.timestamp.isBefore(to)
          ).toList();
        }
        return cached;
      }

      List<CandleDto> candleDtos;

      if (useFakeData) {
        // Fake data kullan
        candleDtos = await _fakeApiService.fetchLatestCandles(
          symbol: symbol,
          interval: interval,
          count: limit ?? 1000,
        );
      } else {
        // Gerçek API kullan
        if (_apiService == null) {
          throw RepositoryException('API service not available');
        }
        
        candleDtos = await _apiService.fetchLatestCandles(
          symbol: symbol,
          interval: interval,
          count: limit ?? 1000,
        );
      }

      final candles = candleDtos.map((dto) => dto.toDomain()).toList();
      
      // Memory cache'e kaydet
      _memoryCache[cacheKey] = candles;

      return candles;
    } catch (e) {
      throw RepositoryException('Failed to get historical data: $e');
    }
  }

  @override
  Stream<Candle> subscribeToLiveData(String symbol) {
    // Mevcut controller varsa onu döndür
    if (_liveDataControllers.containsKey(symbol)) {
      return _liveDataControllers[symbol]!.stream;
    }

    // Yeni controller oluştur
    final controller = StreamController<Candle>.broadcast(
      onCancel: () {
        _liveDataControllers.remove(symbol);
      },
    );

    _liveDataControllers[symbol] = controller;

    // WebSocket stream'ini dinle ve domain'e çevir
    _streamService.subscribeToPriceUpdates(symbol).listen(
      (candleDto) {
        controller.add(candleDto.toDomain());
      },
      onError: (error) {
        controller.addError(error);
      },
    );

    return controller.stream;
  }

  @override
  Future<List<Drawing>> getDrawings(String symbol) async {
    return _drawingsCache[symbol] ?? [];
  }

  @override
  Future<void> saveDrawing(String symbol, Drawing drawing) async {
    if (!_drawingsCache.containsKey(symbol)) {
      _drawingsCache[symbol] = [];
    }
    
    // Aynı id varsa güncelle, yoksa ekle
    final index = _drawingsCache[symbol]!.indexWhere((d) => d.id == drawing.id);
    if (index != -1) {
      _drawingsCache[symbol]![index] = drawing;
    } else {
      _drawingsCache[symbol]!.add(drawing);
    }
  }

  @override
  Future<void> deleteDrawing(String symbol, String drawingId) async {
    if (_drawingsCache.containsKey(symbol)) {
      _drawingsCache[symbol]!.removeWhere((d) => d.id == drawingId);
    }
  }

  @override
  Future<void> clearCache() async {
    _memoryCache.clear();
  }

  void dispose() {
    _apiService?.dispose();
    _fakeApiService.dispose();
    _streamService.dispose();
    
    for (var controller in _liveDataControllers.values) {
      controller.close();
    }
    _liveDataControllers.clear();
  }
}

class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}