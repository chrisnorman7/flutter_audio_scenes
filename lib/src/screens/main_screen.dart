// ignore_for_file: lines_longer_than_80_chars
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

import '../extensions/string_x.dart';
import '../json/audio_scene_document.dart';
import '../json/audio_scene_element.dart';
import '../json/named_audio_scene_element.dart';

/// The formatter to use.
final formatter = DartFormatter(languageVersion: Version.parse('3.7.0'));

/// The main screen.
class MainScreen extends StatefulWidget {
  /// Create an instance.
  const MainScreen({super.key});

  /// Create state for this widget.
  @override
  MainScreenState createState() => MainScreenState();
}

/// State for [MainScreen].
class MainScreenState extends State<MainScreen> {
  /// The stream subscription to use.
  late final StreamSubscription<FileSystemEvent> _subscription;

  /// The loaded files.
  List<File> get files {
    final directory = Directory.current;
    return directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((final file) => file.path.endsWith('.scene.yaml'))
        .toList();
  }

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _subscription = Directory.current
        .watch(recursive: true)
        .listen((_) => setState(() {}));
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => SimpleScaffold(
    title: 'Files',
    body: ListView.builder(
      itemBuilder: (final context, final index) {
        final file = files[index];
        return ListTile(
          autofocus: index == 0,
          title: Text(path.relative(file.path)),
          onTap: () {
            try {
              writeAudioSceneFile(file);
            } on Exception catch (e) {
              context.showMessage(message: e.toString());
            }
          },
        );
      },
      itemCount: files.length,
    ),
  );

  /// Convert [file] to dart.
  void writeAudioSceneFile(final File file) {
    final document = loadYaml(file.readAsStringSync());
    final loaded = json.decode(json.encode(document));
    final scene = AudioSceneDocument.fromJson(loaded);
    var rootDirectory = file.parent;
    while (rootDirectory
        .listSync()
        .whereType<File>()
        .where((final file) => path.basename(file.path) == 'pubspec.yaml')
        .isEmpty) {
      rootDirectory = rootDirectory.parent;
    }
    final imports = {
      'package:flutter/material.dart',
      'package:flutter_audio_games/flutter_audio_games.dart',
      'package:flutter_soloud/flutter_soloud.dart',
    };
    final buffer = StringBuffer();
    final comment = scene.comment;
    if (comment != null) {
      buffer.write(comment.dartComment);
    }
    final className = path.basenameWithoutExtension(file.path).pascalCase;
    buffer
      ..writeln('class $className extends AudioScene {')
      ..writeln('/// Create an instance.')
      ..writeln('const $className({');
    final elements = <NamedAudioSceneElement>[];
    final requiredElements = <NamedAudioSceneElement>[];
    final optionalElements = <NamedAudioSceneElement>[];
    final assetsImports =
        'package:${path.basename(rootDirectory.path)}/gen/assets.gen.dart';
    for (final MapEntry(:key, value: map) in scene.sounds.entries) {
      final element = AudioSceneElement.fromJson(map ?? {});
      final type = element.type;
      final namedElement = NamedAudioSceneElement(
        name: key,
        element: element,
        elementType: switch (type) {
          ElementType.sound => 'Sound',
          ElementType.list => 'List<Sound>',
        },
        sourceName: switch (type) {
          ElementType.sound => '${key}Source',
          ElementType.list => '${key}Sources',
        },
        sourceType: switch (type) {
          ElementType.sound => 'AudioSource',
          ElementType.list => 'List<AudioSource>',
        },
      );
      elements.add(namedElement);
      if (element.asset == null &&
          element.file == null &&
          element.url == null &&
          element.custom == null) {
        requiredElements.add(namedElement);
      } else {
        optionalElements.add(namedElement);
        if (element.asset != null) {
          imports.add(assetsImports);
        } else if (element.file != null) {
          imports.add('dart:io');
        }
      }
      buffer
        ..writeln('required this.$key,')
        ..writeln('required this.${namedElement.sourceName},');
    }
    buffer.writeln('});');
    for (final namedElement in elements) {
      final comment = namedElement.element.comment;
      if (comment != null) {
        buffer.write(comment.dartComment);
      } else {
        buffer.writeln();
      }
      final sourceDesignation = switch (namedElement.element.type) {
        ElementType.sound => 'source',
        ElementType.list => 'sources',
      };
      buffer
        ..writeln('final ${namedElement.elementType} ${namedElement.name};')
        ..writeln('/// Loaded $sourceDesignation for [${namedElement.name}].')
        ..writeln(
          'final ${namedElement.sourceType} ${namedElement.sourceName};',
        );
    }
    buffer
      ..writeln('/// Load this scene.')
      ..write('static Future<$className> load(final BuildContext context');
    if (requiredElements.isNotEmpty) {
      buffer.writeln(', {');
      for (final namedElement in requiredElements) {
        buffer.write(
          'required ${namedElement.elementType} ${namedElement.name},',
        );
      }
      buffer.write('}');
    }
    buffer
      ..writeln(') async {')
      ..writeln('final loader = context.sourceLoader;');
    for (final namedElement in optionalElements) {
      final name = namedElement.name;
      final element = namedElement.element;
      final asset = element.asset;
      final file = element.file;
      final url = element.url;
      final custom = element.custom;
      if ([asset, file, url, custom].where((final e) => e != null).length > 1) {
        throw StateError(
          'The `$name` sound should specify no more than 1 of `asset`, `file`, `directory`, `url`, or `custom`.',
        );
      }
      final String path;
      final String soundType;
      if (asset != null) {
        path = asset;
        soundType = 'asset';
      } else if (file != null) {
        path = file.dartString;
        soundType = 'file';
      } else if (url != null) {
        if (element.type == ElementType.list) {
          throw StateError('Cannot get a list of sounds from a URL: `$name`.');
        }
        path = url.dartString;
        soundType = 'url';
      } else if (custom != null) {
        if (element.type == ElementType.list) {
          throw StateError('Cannot get a list of sounds from custom: `$name`.');
        }
        path = custom.dartString;
        soundType = 'custom';
      } else {
        throw StateError(
          'The `$name` sound should not have ended up in `optionalElements`.',
        );
      }
      buffer.write('final $name = ');
      switch (element.type) {
        case ElementType.sound:
          buffer
            ..writeln('Sound(')
            ..writeln('path: $path,');
        case ElementType.list:
          if (asset != null) {
            buffer.write('$asset.values.asSoundList(');
          } else if (file != null) {
            buffer.write(
              'Directory($path).listSync().whereType<File>().map((file) => file.path).toList().asSoundList(',
            );
          } else {
            throw StateError(
              'Cannot generate sound directive for $name: ${element.toJson()}.',
            );
          }
      }
      buffer
        ..writeln('destroy: ${element.destroy},')
        ..writeln('soundType: SoundType.$soundType,');
      if (element.volume != 0.7) {
        buffer.writeln('volume: ${element.volume},');
      }
      if (element.looping) {
        buffer.writeln('looping: ${element.looping},');
      }
      if (element.loadMode != LoadMode.memory) {
        buffer.writeln('loadMode: ${element.loadMode},');
      }
      buffer.writeln(');');
    }
    buffer.writeln('return $className(');
    for (final namedElement in elements) {
      final name = namedElement.name;
      buffer
        ..writeln('$name: $name,')
        ..write('${namedElement.sourceName}: ');
      switch (namedElement.element.type) {
        case ElementType.sound:
          buffer.writeln('await loader.loadSound(${namedElement.name}),');
        case ElementType.list:
          buffer.writeln(
            '[for (final sound in ${namedElement.name}) await loader.loadSound(sound)],',
          );
      }
    }
    buffer
      ..writeln(');')
      ..writeln('}')
      ..writeln('/// Dispose of all sources.')
      ..writeln('@override')
      ..writeln('Future<void> dispose() async {');
    for (final namedElement in elements) {
      switch (namedElement.element.type) {
        case ElementType.sound:
          buffer.writeln('await ${namedElement.sourceName}.dispose();');
        case ElementType.list:
          buffer
            ..writeln('for (final source in ${namedElement.sourceName}) {')
            ..writeln('await source.dispose();')
            ..writeln('}');
      }
    }
    buffer
      ..writeln('}')
      ..writeln('}');
    final codeBuffer = StringBuffer();
    final stringImports = List<String>.from(imports)..sort();
    for (final importName in stringImports) {
      codeBuffer.writeln("import '$importName';");
    }
    codeBuffer.write(buffer);
    final code = codeBuffer.toString()..copyToClipboard();
    formatter.format(code).copyToClipboard();
  }
}
