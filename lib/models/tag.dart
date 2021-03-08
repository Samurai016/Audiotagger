class Tag {
  String? title;
  String? artist;
  String? genre;
  String? trackNumber;
  String? trackTotal;
  String? discNumber;
  String? discTotal;
  String? lyrics;
  String? comment;
  String? album;
  String? albumArtist;
  String? year;
  String? artwork;

  Tag({
    this.title,
    this.artist,
    this.genre,
    this.trackNumber,
    this.trackTotal,
    this.discNumber,
    this.discTotal,
    this.lyrics,
    this.comment,
    this.album,
    this.albumArtist,
    this.year,
    this.artwork,
  });

  Tag.fromMap(Map map) {
    title = map["title"];
    artist = map["artist"];
    genre = map["genre"];
    trackNumber = map["trackNumber"];
    trackTotal = map["trackTotal"];
    discNumber = map["discNumber"];
    discTotal = map["discTotal"];
    lyrics = map["lyrics"];
    comment = map["comment"];
    album = map["album"];
    albumArtist = map["albumArtist"];
    year = map["year"];
    artwork = map["artwork"];
  }

  Map<String, String?> toMap() {
    return <String, String?>{
      "title": title,
      "artist": artist,
      "genre": genre,
      "trackNumber": trackNumber,
      "trackTotal": trackTotal,
      "discNumber": discNumber,
      "discTotal": discTotal,
      "lyrics": lyrics,
      "comment": comment,
      "album": album,
      "albumArtist": albumArtist,
      "year": year,
      "artwork": artwork,
    };
  }
}
