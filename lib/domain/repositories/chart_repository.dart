import '../entities/candle.dart';
import '../entities/drawing/drawing.dart';

abstract class ChartRepository {
  /// Tarihsel mum verilerini getir
  Future<List<Candle>> getHistoricalData({
    required String symbol,
    required Duration interval,
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Canlı veri akışına abone ol
  Stream<Candle> subscribeToLiveData(String symbol);

  /// Çizimleri getir
  Future<List<Drawing>> getDrawings(String symbol);

  /// Çizim kaydet
  Future<void> saveDrawing(String symbol, Drawing drawing);

  /// Çizim sil
  Future<void> deleteDrawing(String symbol, String drawingId);

  /// Cache temizle
  Future<void> clearCache();
}