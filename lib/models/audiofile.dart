class AudioFile {
  int? length;
  int? bitRate;
  String? channels;
  String? encodingType;
  String? format;
  int? sampleRate;
  bool? isVariableBitRate;

  AudioFile({
    this.length,
    this.bitRate,
    this.channels,
    this.encodingType,
    this.format,
    this.sampleRate,
    this.isVariableBitRate,
  });

  AudioFile.fromMap(Map map) {
    this.length = map["length"];
    this.bitRate = map["bitRate"];
    this.channels = map["channels"];
    this.encodingType = map["encodingType"];
    this.format = map["format"];
    this.sampleRate = map["sampleRate"];
    this.isVariableBitRate = map["isVariableBitRate"];
  }

  Map<String, dynamic?> toMap() {
    return <String, dynamic?>{
      "length": length,
      "bitRate": bitRate,
      "channels": channels,
      "encodingType": encodingType,
      "format": format,
      "sampleRate": sampleRate,
      "isVariableBitRate": isVariableBitRate,
    };
  }
}
