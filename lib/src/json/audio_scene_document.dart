import 'package:json_annotation/json_annotation.dart';

import '../audio_scene.dart';

part 'audio_scene_document.g.dart';

/// A document which describes an [AudioScene].
@JsonSerializable()
class AudioSceneDocument {
  /// Create an instance.
  const AudioSceneDocument({required this.sounds, this.comment});

  /// Create an instance from a JSON object.
  factory AudioSceneDocument.fromJson(final Map<String, dynamic> json) =>
      _$AudioSceneDocumentFromJson(json);

  /// The comment for this document.
  final String? comment;

  /// The map of entries.
  final Map<String, Map<String, dynamic>?> sounds;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AudioSceneDocumentToJson(this);
}
