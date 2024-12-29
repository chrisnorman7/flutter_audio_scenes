import 'audio_scene_element.dart';

/// An [AudioSceneElement] with a [na,e].
class NamedAudioSceneElement {
  /// Create an instance.
  const NamedAudioSceneElement({
    required this.name,
    required this.element,
    required this.elementType,
    required this.sourceName,
    required this.sourceType,
  });

  /// The name of this [element].
  final String name;

  /// The element to use.
  final AudioSceneElement element;

  /// The type of the generated element.
  final String elementType;

  /// The name of the generated source(s).
  final String sourceName;

  /// The type of the generated source(s) type.
  final String sourceType;
}
