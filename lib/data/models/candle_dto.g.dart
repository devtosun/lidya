// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandleDto _$CandleDtoFromJson(Map<String, dynamic> json) => CandleDto(
  open: (json['open'] as num).toDouble(),
  high: (json['high'] as num).toDouble(),
  low: (json['low'] as num).toDouble(),
  close: (json['close'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
  timestampMs: (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$CandleDtoToJson(CandleDto instance) => <String, dynamic>{
  'open': instance.open,
  'high': instance.high,
  'low': instance.low,
  'close': instance.close,
  'volume': instance.volume,
  'timestamp': instance.timestampMs,
};
