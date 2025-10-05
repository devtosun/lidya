// data/providers/data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/remote/chart_api_service.dart';
import '../datasources/remote/fake_chart_api_service.dart';
import '../datasources/remote/price_stream_service.dart';
import '../repositories/chart_repository_impl.dart';
import '../../../../domain/repositories/chart_repository.dart';
import '../../../../domain/entities/candle.dart';


// Configuration
final useFakeDataProvider = Provider<bool>((ref) {
  return true; // Development için true, production'da false
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return 'https://api.example.com';
});

final wsUrlProvider = Provider<String>((ref) {
  return 'wss://ws.example.com';
});

// Fake API Service (Development)
final fakeChartApiServiceProvider = Provider<FakeChartApiService>((ref) {
  final service = FakeChartApiService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Real API Service (Production)
final chartApiServiceProvider = Provider<ChartApiService?>((ref) {
  final useFake = ref.watch(useFakeDataProvider);
  
  if (useFake) {
    return null; // Fake data kullanılıyorsa gerçek API'ye gerek yok
  }
  
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return ChartApiService(baseUrl: baseUrl);
});

// WebSocket Service
final priceStreamServiceProvider = Provider<PriceStreamService>((ref) {
  final wsUrl = ref.watch(wsUrlProvider);
  final service = PriceStreamService(wsUrl: wsUrl);
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Repository
final chartRepositoryProvider = Provider<ChartRepository>((ref) {
  final apiService = ref.watch(chartApiServiceProvider);
  final fakeApiService = ref.watch(fakeChartApiServiceProvider);
  final streamService = ref.watch(priceStreamServiceProvider);
  final useFake = ref.watch(useFakeDataProvider);
  
  final repository = ChartRepositoryImpl(
    apiService: apiService,
    fakeApiService: fakeApiService,
    streamService: streamService,
    useFakeData: useFake,
  );
  
  ref.onDispose(() {
    repository.dispose();
  });
  
  return repository;
});

// Helper: Candle Stream Provider
final candleStreamProvider = StreamProvider.family<List<Candle>, CandleStreamParams>(
  (ref, params) async* {
    final fakeService = ref.watch(fakeChartApiServiceProvider);
    
    await for (final candleDto in fakeService.generateRealisticCandlesStream(
      symbol: params.symbol,
      interval: params.interval,
      count: params.count,
      delay: params.delay,
      trendStrength: params.trendStrength,
    )) {
      yield [candleDto.toDomain()];
    }
  },
);

class CandleStreamParams {
  final String symbol;
  final Duration interval;
  final int count;
  final Duration delay;
  final double trendStrength;

  CandleStreamParams({
    required this.symbol,
    required this.interval,
    this.count = 1000,
    this.delay = const Duration(milliseconds: 50),
    this.trendStrength = 0.3,
  });
}