// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingDto _$DrawingDtoFromJson(Map<String, dynamic> json) => DrawingDto(
  id: json['id'] as String,
  type: json['type'] as String,
  points: (json['points'] as List<dynamic>)
      .map((e) => DrawingPointDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  color: json['color'] as String,
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
  settings: json['settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DrawingDtoToJson(DrawingDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'points': instance.points,
      'color': instance.color,
      'strokeWidth': instance.strokeWidth,
      'settings': instance.settings,
    };

DrawingPointDto _$DrawingPointDtoFromJson(Map<String, dynamic> json) =>
    DrawingPointDto(
      timestampMs: (json['timestampMs'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$DrawingPointDtoToJson(DrawingPointDto instance) =>
    <String, dynamic>{
      'timestampMs': instance.timestampMs,
      'price': instance.price,
    };
