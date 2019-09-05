import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/tag.dart';

/// Audiotagger is the main class of the plugin.
/// Create an instance with constructor:
/// ```dart
/// final tagger = new Audiotagger();
/// ```
class Audiotagger {
  MethodChannel _channel;

  Audiotagger() {
    _channel = MethodChannel('audiotagger');
  }

  /// Method to write ID3 tags to MP3 file.
  ///
  /// [path]: The path of the file.
  ///
  /// [tags]: A map of the tags.
  ///
  /// [artwork]: An array of bytes which represent the song artwork.
  ///
  /// [checkPermission]: If setted to true,
  /// the tagger will check for storage read and write before before
  /// to start writing. By default set to false.
  ///
  /// [version]: The version of ID3 tag frame you want to write.  By default set to ID3V2.
  ///
  /// [return]: `true` if the operation has success, `false` instead.
  Future<bool> writeTagsFromMap({
    @required String path,
    @required Map tags,
    bool checkPermission = false,
    Version version = Version.ID3V2,
    List<int> artwork,
  }) async {
    if (checkPermission) await _checkPermissions();

    return await _channel.invokeMethod("writeTags", {
      "path": path,
      "tags": tags,
      "artwork": Uint8List.fromList(artwork),
      "version": version.index,
    });
  }

    /// Method to write ID3 tags to MP3 file.
  ///
  /// [path]: The path of the file.
  ///
  /// [tags]: A tag object.
  ///
  /// [artwork]: An array of bytes which represent the song artwork.
  ///
  /// [checkPermission]: If setted to true,
  /// the tagger will check for storage read and write before before
  /// to start writing. By default set to false.
  ///
  /// [version]: The version of ID3 tag frame you want to write.  By default set to ID3V2.
  ///
  /// [return]: `true` if the operation has success, `false` instead.
  Future<bool> writeTags({
    @required String path,
    @required Tag tag,
    bool checkPermission = false,
    Version version = Version.ID3V2,
  }) async {
    if (checkPermission) await _checkPermissions();

    return await _channel.invokeMethod("writeTags", {
      "path": path,
      "tags": tag.toMap(),
      "artwork": Uint8List.fromList(tag.artwork),
      "version": version.index,
    });
  }

  /// Method to read ID3 tags from MP3 file.
  ///
  /// [path]: The path of the file.
  ///
  /// [checkPermission]: If setted to true,
  /// the tagger will check for storage read and write before before
  /// to start writing. By default set to false.
  ///
  /// [return]: A map of the tags
  Future<Map> readTagsAsMap({
    @required String path,
    bool checkPermission = false,
  }) async {
    if (checkPermission) await _checkPermissions();

    return await _channel.invokeMethod("readTags", {
      "path": path,
    });
  }

  /// Method to read ID3 tags from MP3 file.
  ///
  /// [path]: The path of the file.
  ///
  /// [checkPermission]: If setted to true,
  /// the tagger will check for storage read and write before before
  /// to start writing. By default set to false.
  ///
  /// [return]: A tag object of the ID3 tags of the song;
  Future<Tag> readTags({
    @required String path,
    bool checkPermission = false,
  }) async {
    return Tag.fromMap(await readTagsAsMap(
      path: path,
      checkPermission: checkPermission,
    ));
  }

  /// Method to read Artwork image from MP3 file.
  ///
  /// [path]: The path of the file.
  ///
  /// [checkPermission]: If setted to true,
  /// the tagger will check for storage read and write before before
  /// to start writing. By default set to false.
  ///
  /// [return]: A byte array representation of the image.
  Future<Uint8List> readArtwork({
    @required String path,
    bool checkPermission = false,
  }) async {
    if (checkPermission) await _checkPermissions();

    return await _channel.invokeMethod("readArtwork", {
      "path": path,
    });
  }

  Future _checkPermissions() async {
    var isChecked = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (isChecked != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }
  }
}

enum Version {
  ID3V1,
  ID3V2,
}
