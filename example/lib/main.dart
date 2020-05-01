import 'dart:async';
import 'dart:convert';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final filePath = "/storage/emulated/0/Download/test.mp3";
  Widget result;
  Audiotagger tagger = new Audiotagger();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  Future _checkPermissions() async {
    if (!await Permission.storage.request().isGranted) {
      await _checkPermissions();
    }
  }

  Future _writeTags() async {
    String artwork = "/storage/emulated/0/Download/cover.jpg";
    Tag tags = Tag(
      title: "Title of the song",
      artist: "A fake artist",
      album: "A fake album",
      year: "2020",
      artwork: artwork,
    );

    final output = await tagger.writeTags(
      path: filePath,
      tag: tags,
    );

    setState(() {
      result = Text(output.toString());
    });
  }

  Future _readTags() async {
    final output = await tagger.readTagsAsMap(
      path: filePath,
    );
    setState(() {
      result = Text(jsonEncode(output));
    });
  }

  Future _readArtwork() async {
    final output = await tagger.readArtwork(
      path: filePath,
    );
    setState(() {
      result = output != null ? Image.memory(output) : Text("No artwork found");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audiotagger example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              result != null ? result : Text("Ready.."),
              RaisedButton(
                child: Text("Read tags"),
                onPressed: () async {
                  await _readTags();
                },
              ),
              RaisedButton(
                child: Text("Read artwork"),
                onPressed: () async {
                  await _readArtwork();
                },
              ),
              RaisedButton(
                child: Text("Write tags"),
                onPressed: () async {
                  await _writeTags();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
