import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../audio_scene.dart';

/// A scene for a card game.
class CardsScene extends AudioScene {
  /// Create an instance.
  const CardsScene({
    required this.shuffle,
    required this.shuffleSource,
    required this.cardSounds,
    required this.cardSoundsSources,
  });

  /// The shuffle sound.
  final Sound shuffle;

  /// Loaded source for [shuffle].
  final AudioSource shuffleSource;

  /// The sounds which will be heard when cards are dealt.
  final List<Sound> cardSounds;

  /// Loaded sources for [cardSounds].
  final List<AudioSource> cardSoundsSources;

  /// Load this scene.
  static Future<CardsScene> load(
    final BuildContext context, {
    required final Sound shuffle,
    required final List<Sound> cardSounds,
  }) async {
    final loader = context.sourceLoader;
    return CardsScene(
      shuffle: shuffle,
      shuffleSource: await loader.loadSound(shuffle),
      cardSounds: cardSounds,
      cardSoundsSources: [
        for (final sound in cardSounds) await loader.loadSound(sound),
      ],
    );
  }

  /// Dispose of all sources.
  @override
  Future<void> deinit() async {
    await shuffleSource.dispose();
    for (final source in cardSoundsSources) {
      await source.dispose();
    }
  }
}
