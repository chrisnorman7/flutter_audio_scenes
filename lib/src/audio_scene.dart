/// The base class for audio scenes.
///
/// To create audio scenes, create a yaml file with the `.scene.yaml` extension.
// ignore: one_member_abstracts
abstract class AudioScene {
  /// Make subclasses constant.
  const AudioScene();

  /// Dispose of this scene.
  ///
  /// Subclasses should override this method to clean up their sources.
  Future<void> dispose();
}
