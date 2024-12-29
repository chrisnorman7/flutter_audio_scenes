import 'package:json_annotation/json_annotation.dart';

import '../audio_scene.dart';

part 'audio_scene_element.g.dart';

/// The types for [AudioSceneElement]s.
enum ElementType {
  /// The element is a single sound.
  sound,

  /// The element is a list of sounds.
  list,
}

/// The load mode to use.
///
/// Copies the [flutter_soloud](https://pub.dev/documentation/flutter_soloud/latest/flutter_soloud/LoadMode.html) version.
enum LoadMode {
  /// Load from memory (default).
  memory,

  /// Load from disk.
  disk,
}

/// An element in an [AudioScene].
@JsonSerializable()
class AudioSceneElement {
  /// Create an instance.
  const AudioSceneElement({
    this.comment,
    this.type = ElementType.sound,
    this.asset,
    this.file,
    this.url,
    this.custom,
    this.destroy = true,
    this.volume = 0.7,
    this.looping = false,
    this.loadMode = LoadMode.memory,
  });

  /// Create an instance from a JSON object.
  factory AudioSceneElement.fromJson(final Map<String, dynamic> json) =>
      _$AudioSceneElementFromJson(json);

  /// The doc comment for this element.
  final String? comment;

  /// The type of this element.
  final ElementType type;

  /// The asset to load the sound from.
  final String? asset;

  /// The file to load the sound from.
  final String? file;

  /// The URL to load the sound from.
  final String? url;

  /// The custom path to load the sound from.
  final String? custom;

  /// Whether the sound should be destroyed.
  final bool destroy;

  /// The volume of the sound.
  final double volume;

  /// The load mode for the sound.
  final LoadMode loadMode;

  /// Whether or not the sound should loop.
  final bool looping;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AudioSceneElementToJson(this);
}
