import 'dart:async';
import 'dart:convert';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final filePath = "/storage/emulated/0/五音/音乐/麻雀 - 李荣浩.mp3";
  Widget result;
  Audiotagger tagger = new Audiotagger();

  Future _writeTags() async {
    String artwork = "/storage/emulated/0/五音/cover.jpg";
    Tag tags = Tag(
      title: "麻雀",
      artist: "李荣浩",
      album: "album",
      year: "2019",
      artwork: artwork,
    );

    final output = await tagger.writeTags(
      path: filePath,
      tag: tags,
      checkPermission: true,
    );

    setState(() {
      result = Text(output.toString());
    });
  }

  Future _readTags() async {
    final output = await tagger.readTagsAsMap(
      path: filePath,
      checkPermission: true,
    );
    setState(() {
      result = Text(jsonEncode(output));
    });
  }

  Future _readArtwork() async {
    final output = await tagger.readArtwork(
      path: filePath,
      checkPermission: true,
    );
    setState(() {
      result = Image.memory(output);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
