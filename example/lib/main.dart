import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:audiotagger/audiotagger.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final filePath = "/storage/emulated/0/Music/test.mp3";
  Widget result;
  Audiotagger tagger = new Audiotagger();

  Future _writeTags() async {
    final tags = <String, String>{
      "titolo": "Ciao belli",
      "artista": "Non lo so",
      "album": "Canzone bella",
      "anno": "1973",
    };

    final artworkPath = "/storage/emulated/0/Music/artwork.jpg";
    final artworkFile = new File(artworkPath);
    final artwork = await artworkFile.readAsBytes();

    final output = await tagger.writeTagsFromMap(
      path: filePath,
      tags: tags,
      artwork: artwork,
      checkPermission: true,
    );

    setState(() {
     result = Text(output.toString()); 
    });
  }

  Future _readTags() async {
    final output = await tagger.readTags(
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
