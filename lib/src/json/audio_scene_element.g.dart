// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_scene_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioSceneElement _$AudioSceneElementFromJson(Map<String, dynamic> json) =>
    AudioSceneElement(
      comment: json['comment'] as String?,
      type:
          $enumDecodeNullable(_$ElementTypeEnumMap, json['type']) ??
          ElementType.sound,
      asset: json['asset'] as String?,
      file: json['file'] as String?,
      url: json['url'] as String?,
      custom: json['custom'] as String?,
      destroy: json['destroy'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.7,
      looping: json['looping'] as bool? ?? false,
      loadMode:
          $enumDecodeNullable(_$LoadModeEnumMap, json['loadMode']) ??
          LoadMode.memory,
    );

Map<String, dynamic> _$AudioSceneElementToJson(AudioSceneElement instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'type': _$ElementTypeEnumMap[instance.type]!,
      'asset': instance.asset,
      'file': instance.file,
      'url': instance.url,
      'custom': instance.custom,
      'destroy': instance.destroy,
      'volume': instance.volume,
      'loadMode': _$LoadModeEnumMap[instance.loadMode]!,
      'looping': instance.looping,
    };

const _$ElementTypeEnumMap = {
  ElementType.sound: 'sound',
  ElementType.list: 'list',
};

const _$LoadModeEnumMap = {LoadMode.memory: 'memory', LoadMode.disk: 'disk'};
