// data/datasources/remote/price_stream_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/candle_dto.dart';

class PriceStreamService {
  final String wsUrl;
  WebSocketChannel? _channel;
  StreamController<CandleDto>? _controller;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  String? _currentSymbol;
  bool _isDisposed = false;

  PriceStreamService({required this.wsUrl});

  /// Belirli bir sembol için fiyat akışını başlatır
  Stream<CandleDto> subscribeToPriceUpdates(String symbol) {
    if (_controller != null && _currentSymbol == symbol) {
      return _controller!.stream;
    }

    _disconnect();
    _currentSymbol = symbol;
    _controller = StreamController<CandleDto>.broadcast(
      onCancel: () => _disconnect(),
    );

    _connect(symbol);
    return _controller!.stream;
  }

  void _connect(String symbol) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Subscribe message gönder
      _channel!.sink.add(json.encode({
        'action': 'subscribe',
        'symbol': symbol,
      }));

      // Mesajları dinle
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      // Ping timer başlat (30 saniyede bir)
      _startPingTimer();
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);

      if (data['type'] == 'candle') {
        final candleDto = CandleDto.fromJson(data['data']);
        _controller?.add(candleDto);
      } else if (data['type'] == 'tick') {
        // Tick verisini muma çevir
        final candleDto = _convertTickToCandle(data['data']);
        _controller?.add(candleDto);
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  CandleDto _convertTickToCandle(Map<String, dynamic> tickData) {
    final price = tickData['price'] as double;
    final timestamp = tickData['timestamp'] as int;

    return CandleDto(
      open: price,
      high: price,
      low: price,
      close: price,
      volume: tickData['volume'] ?? 0.0,
      timestampMs: timestamp,
    );
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _scheduleReconnect();
  }

  void _handleDone() {
    print('WebSocket connection closed');
    _scheduleReconnect();
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_channel != null) {
          _channel!.sink.add(json.encode({'action': 'ping'}));
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_isDisposed || _currentSymbol == null) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: 5),
      () {
        if (!_isDisposed && _currentSymbol != null) {
          print('Reconnecting WebSocket...');
          _connect(_currentSymbol!);
        }
      },
    );
  }

  void _disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _isDisposed = true;
    _disconnect();
    _controller?.close();
    _controller = null;
  }
}