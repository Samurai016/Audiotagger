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
        "title": "Title of the song",
        "artist": "A fake artist",
        "album": "A fake album",
        "year": "2020",
      };

      final result = await tagger.writeTagsFromMap(
        path: path,
        tags: tags,
      );

      expect(result, true);
    });

    test('writeTags', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Title of the song",
        "artist": "A fake artist",
        "album": "A fake album",
        "year": "2020",
      };
      final tag = Tag.fromMap(tags);

      final result = await tagger.writeTags(
        path: path,
        tag: tag,
      );

      expect(result, true);
    });
  });

  group("reading", () {
    test('readTagsFromMap', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Title of the song",
        "artist": "A fake artist",
        "album": "A fake album",
        "year": "2020",
      };

      final result = await tagger.readTagsAsMap(
        path: path,
      );

      expect(result, tags);
    });

    test('readTags', () async {
      final tagger = new Audiotagger();

      final path = "storage/emulated/0/Music/test.mp3";
      final tags = <String, String>{
        "title": "Title of the song",
        "artist": "A fake artist",
        "album": "A fake album",
        "year": "2020",
      };
      final tag = Tag.fromMap(tags);

      final result = await tagger.readTags(
        path: path,
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
      );

      expect(result, artwork);
    });
  });
}
