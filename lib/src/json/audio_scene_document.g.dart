// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_scene_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioSceneDocument _$AudioSceneDocumentFromJson(Map<String, dynamic> json) =>
    AudioSceneDocument(
      sounds: (json['sounds'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>?),
      ),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$AudioSceneDocumentToJson(AudioSceneDocument instance) =>
    <String, dynamic>{'comment': instance.comment, 'sounds': instance.sounds};
