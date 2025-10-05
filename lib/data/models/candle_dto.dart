import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/candle.dart';

part 'candle_dto.g.dart';

@JsonSerializable()
class CandleDto {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  @JsonKey(name: 'timestamp')
  final int timestampMs;

  CandleDto({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.timestampMs,
  });

  // JSON serialization
  factory CandleDto.fromJson(Map<String, dynamic> json) => 
      _$CandleDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$CandleDtoToJson(this);

  // Domain'e dönüştürme
  Candle toDomain() {
    return Candle(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }

  // Domain'den oluşturma (cache için)
  factory CandleDto.fromDomain(Candle candle) {
    return CandleDto(
      open: candle.open,
      high: candle.high,
      low: candle.low,
      close: candle.close,
      volume: candle.volume,
      timestampMs: candle.timestamp.millisecondsSinceEpoch,
    );
  }
}