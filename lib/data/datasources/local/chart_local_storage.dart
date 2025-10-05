// data/datasources/local/chart_local_storage.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/candle_dto.dart';
import '../../models/drawing_dto.dart';

class ChartLocalStorage {
  static const String _candleCacheBox = 'candle_cache';
  // static const String _drawingsBox = 'drawings';

  late Box<List<CandleDto>> _candleBox;
  late Box<List<DrawingDto>> _drawingsBox;
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    // if (!Hive.isAdapterRegistered(1)) {
    //   Hive.registerAdapter(DrawingDtoAdapter());
    // }
    // if (!Hive.isAdapterRegistered(2)) {
    //   Hive.registerAdapter(DrawingPointDtoAdapter());
    // }

    _candleBox = await Hive.openBox<List<CandleDto>>(_candleCacheBox);
    // _drawingsBox = await Hive.openBox<List<DrawingDto>>(_drawingsBox);
    _prefs = await SharedPreferences.getInstance();
  }

  // ============ Candle Cache ============
  
  Future<void> cacheCandles({
    required String symbol,
    required Duration interval,
    required List<CandleDto> candles,
  }) async {
    final key = _getCandleCacheKey(symbol, interval);
    await _candleBox.put(key, candles);
  }

  List<CandleDto>? getCachedCandles({
    required String symbol,
    required Duration interval,
  }) {
    final key = _getCandleCacheKey(symbol, interval);
    return _candleBox.get(key);
  }

  Future<void> clearCandleCache() async {
    await _candleBox.clear();
  }

  String _getCandleCacheKey(String symbol, Duration interval) {
    return '${symbol}_${interval.inMinutes}';
  }

  // ============ Drawings ============

  Future<void> saveDrawings({
    required String symbol,
    required List<DrawingDto> drawings,
  }) async {
    await _drawingsBox.put(symbol, drawings);
  }

  List<DrawingDto> getDrawings(String symbol) {
    return _drawingsBox.get(symbol) ?? [];
  }

  Future<void> deleteDrawing({
    required String symbol,
    required String drawingId,
  }) async {
    final drawings = getDrawings(symbol);
    drawings.removeWhere((d) => d.id == drawingId);
    await _drawingsBox.put(symbol, drawings);
  }

  Future<void> clearDrawings(String symbol) async {
    await _drawingsBox.delete(symbol);
  }

  // ============ Settings ============

  Future<void> saveLastSymbol(String symbol) async {
    await _prefs.setString('last_symbol', symbol);
  }

  String? getLastSymbol() {
    return _prefs.getString('last_symbol');
  }

  Future<void> saveLastInterval(Duration interval) async {
    await _prefs.setInt('last_interval_minutes', interval.inMinutes);
  }

  Duration getLastInterval() {
    final minutes = _prefs.getInt('last_interval_minutes') ?? 60;
    return Duration(minutes: minutes);
  }

  void dispose() {
    _candleBox.close();
    _drawingsBox.close();
  }
}