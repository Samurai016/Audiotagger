import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/models/tag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audiotagger/audiotagger.dart';

void main() {
  const MethodChannel channel = MethodChannel('audiotagger');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group("writing", () {
    test('writeTagsFromMap', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Viva la vita",
        "artist": "Renato Pozzetto",
        "album": "Viva la vita - album",
      };

      final result = await tagger.writeTagsFromMap(
        path: path,
        tags: tags,
        checkPermission: true,
      );

      expect(result, true);
    });

    test('writeTags', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Viva la vita",
        "artist": "Renato Pozzetto",
        "album": "Viva la vita - album",
      };
      final tag = Tag.fromMap(tags);

      final result = await tagger.writeTags(
        path: path,
        tag: tag,
        checkPermission: true,
      );

      expect(result, true);
    });
  });

  group("reading", () {
    test('readTagsFromMap', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Viva la vita",
        "artist": "Renato Pozzetto",
        "album": "Viva la vita - album",
      };

      final result = await tagger.readTagsAsMap(
        path: path,
        checkPermission: true,
      );

      expect(result, tags);
    });

    test('readTags', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Viva la vita",
        "artist": "Renato Pozzetto",
        "album": "Viva la vita - album",
      };
      final tag = Tag.fromMap(tags);

      final result = await tagger.readTags(
        path: path,
        checkPermission: true,
      );

      expect(result, tag);
    });

    test('readArtwork', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final pathToImage = "storage/emulated/0/image.jpg";
      
      final file = new File(pathToImage);
      final artwork = Uint8List.fromList(await file.readAsBytes());

      final result = await tagger.readArtwork(
        path: path,
        checkPermission: true,
      );

      expect(result, artwork);
    });
  });
}
