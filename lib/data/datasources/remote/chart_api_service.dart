// data/datasources/remote/chart_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/candle_dto.dart';

class ChartApiService {
  final String baseUrl;
  final http.Client client;

  ChartApiService({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Tarihsel mum verilerini çeker
  Future<List<CandleDto>> fetchCandles({
    required String symbol,
    required Duration interval,
    required DateTime from,
    required DateTime to,
    int? limit,
  }) async {
    try {
      final intervalParam = _intervalToDuration(interval);
      final fromTimestamp = from.millisecondsSinceEpoch ~/ 1000;
      final toTimestamp = to.millisecondsSinceEpoch ~/ 1000;

      final uri = Uri.parse('$baseUrl/candles').replace(
        queryParameters: {
          'symbol': symbol,
          'interval': intervalParam,
          'from': fromTimestamp.toString(),
          'to': toTimestamp.toString(),
          if (limit != null) 'limit': limit.toString(),
        },
      );

      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CandleDto.fromJson(json)).toList();
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to fetch candles: ${response.body}',
        );
      }
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }

  /// Son N adet mumu çeker
  Future<List<CandleDto>> fetchLatestCandles({
    required String symbol,
    required Duration interval,
    int count = 1000,
  }) async {
    final to = DateTime.now();
    final from = to.subtract(interval * count);

    return fetchCandles(
      symbol: symbol,
      interval: interval,
      from: from,
      to: to,
      limit: count,
    );
  }

  /// Interval duration'ı API formatına çevirir
  String _intervalToDuration(Duration interval) {
    if (interval.inMinutes < 60) {
      return '${interval.inMinutes}m';
    } else if (interval.inHours < 24) {
      return '${interval.inHours}h';
    } else {
      return '${interval.inDays}d';
    }
  }

  void dispose() {
    client.close();
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}