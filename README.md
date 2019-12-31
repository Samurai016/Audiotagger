# audiotagger
![build status](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square)
[![pub](https://img.shields.io/pub/v/audiotagger?style=flat-square)](https://pub.dev/packages/audiotagger)

This library allow yoy to read and write ID3 tags to MP3 files.

> **Library actually works only on Android.**

## Add dependency
```yaml
dependencies:
  audiotagger: ^1.0.3
```
Audiotagger need accesso to read and write storage. To do this, add this lines in your `AndroidManifest.xml` (inside `manifest` tag, see [example manifest](./example/android/app/src/main/AndroidManifest.xml#L4) to check).
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```
Than you can use you preferred way to request them or simply set `checkPermission` flag to `true`.

## Table of contents
- [Basic usage](#basic-usage-for-any-operation)
- [Reading operations](#reading-operations)
    - [Read tags as `Map`](#read-tags-as-map)
    - [Read tags as `Tag` object](#read-tags-as-tag-object)
    - [Read artwork](#read-artwork)
- [Writing operations](#writing-operations)
    - [Write tags from `Map`](#write-tags-from-map)
    - [Write tags from `Tag` object](#write-tags-from-tag-object)
- [Models](#models)
    - [`Map` of tags](#map-of-tag)
    - [`Tag` class](#tag-class)


## Basic usage for any operation
Initialize a new instance of the tagger;
```dart
final tagger = new Audiotagger();
```

Any operation has a `checkPermission` boolean parameter. By setting it to `true`, 
the tagger will check for storage read and write permission, before to start the operations.

## Reading operations

### Read tags as map
You can get a `Map` of the ID3 tags.
```dart
void getTagsAsMap() async {
    final String filePath = "/storage/emulated/0/file.mp3";
    final Map map = await tagger.readTagsAsMap(
        path: filePath,
        checkPermission: true,
    );
}
```
[**This method does not read the artwork of the song. To do this, use the `readArtwork` method.**](#read-artwork)

The map has this schema:[Tag schema](#map-of-tags).

### Read tags as `Tag` object
You can get a `Tag` object of the ID3 tags.
```dart
void getTags() async {
    final String filePath = "/storage/emulated/0/file.mp3";
    final Tag tag = await tagger.readTags(
        path: filePath,
        checkPermission: true,
    );
}
```

[**This method does not read the artwork of the song. To do this, use the `readArtwork` method.**](#read-artwork)

The `Tag` object has this schema: [Tag schema](#tag-class).

### Read artwork
To get the artwork of the song, use this method.
```dart
void getArtwork() async {
    final String filePath = "/storage/emulated/0/file.mp3";
    final Uint8List bytes = await tagger.readArtwork(
        path: filePath,
        checkPermission: true,
    );
}
```

It return a `Uint8List` of the bytes of the artwork.

## Writing operations

### Write tags from map
You can write the ID3 tags from a `Map`.
```dart
void setTagsFromMap() async {
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
}
```

The map has this schema:[Tag schema](#map-of-tags).

### Write tags from `Tag` object
You can write the ID3 tags from a `Tag` object.
```dart
void setTags() async {
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
}
```

The `Tag` object has this schema: [Tag schema](#tag-class).

## Models

These are the schemes of the `Map` asked and returned by Audiotagger and of the `Tag` class.

### `Map` of tags
```dart
<String, String>{
    "title": value,
    "artist": value,
    "genre": value,
    "trackNumber": value,
    "trackTotal": value,
    "discNumber": value,
    "discTotal": value,
    "lyrics": value,
    "comment": value,
    "album": value,
    "albumArtist": value,
    "year": value,
};
```

### Tag class
```dart
    String title;
    String artist;
    String genre;
    String trackNumber;
    String trackTotal;
    String discNumber;
    String discTotal;
    String lyrics;
    String comment;
    String album;
    String albumArtist;
    String year;
    Uint8List artwork;
```

## Copyright and license
This library is developed and maintained by Nicolò Rebaioli  
:globe_with_meridians: [My website](https://rebaioli.altervista.org)  
:mailbox: [niko.reba@gmail.com](mailto:niko.reba@gmail.com)

Released under [MIT license](LICENSE)

Copyright 2019 Nicolò Rebaioli