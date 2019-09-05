package com.nicolorebaioli.audiotagger;

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.MediaScannerConnection;
import android.net.Uri;

import com.google.gson.Gson;

import  org.json.*;

import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.jaudiotagger.tag.FieldDataInvalidException;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.id3.ID3v1Tag;
import org.jaudiotagger.tag.id3.ID3v24Tag;
import org.jaudiotagger.tag.images.Artwork;
import org.jaudiotagger.tag.images.ArtworkFactory;

import java.io.File;
import java.util.HashMap;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AudiotaggerPlugin
 */
public class AudiotaggerPlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    private Context context;

    enum Version {ID3V1, ID3V2}

    private AudiotaggerPlugin(Context context) {
        this.context = context;
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "audiotagger");
        channel.setMethodCallHandler(new AudiotaggerPlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "writeTags":
                if (call.hasArgument("path") && call.hasArgument("tags") && call.hasArgument("version")) {
                    String path = call.argument("path");
                    HashMap<String, String> map = call.argument("tags");
                    byte[] artwork = call.argument("artwork");
                    Version version = Version.values()[(int) call.argument("version")];
                    result.success(writeTags(path, map, artwork, version));
                } else
                    result.error("400", "Missing parameters", null);
                break;
            case "readTags":
                if (call.hasArgument("path"))
                    result.success(readTags((String)call.argument("path")));
                else
                    result.error("400", "Missing parameter", null);
                break;
            case "readArtwork":
                if (call.hasArgument("path"))
                    result.success(readArtwork((String)call.argument("path")));
                else
                    result.error("400", "Missing parameter", null);
                break;
            default:
                result.notImplemented();
        }
    }

    private boolean writeTags(String path, HashMap<String, String> map, byte[] artwork, Version version) {
        try {
            File mp3File = new File(path);
            AudioFile audioFile = AudioFileIO.read(mp3File);

            audioFile.setTag(version.equals(Version.ID3V1) ? new ID3v1Tag() : new ID3v24Tag());
            Tag newTag = audioFile.getTagAndConvertOrCreateAndSetDefault();

            Util.setFieldIfExist(newTag, FieldKey.TITLE, map, "title");
            Util.setFieldIfExist(newTag, FieldKey.ARTIST, map, "artist");
            Util.setFieldIfExist(newTag, FieldKey.GENRE, map, "genre");
            Util.setFieldIfExist(newTag, FieldKey.TRACK, map, "trackNumber");
            Util.setFieldIfExist(newTag, FieldKey.TRACK_TOTAL, map, "trackTotal");
            Util.setFieldIfExist(newTag, FieldKey.DISC_NO, map, "discNumber");
            Util.setFieldIfExist(newTag, FieldKey.DISC_TOTAL, map, "discTotal");
            Util.setFieldIfExist(newTag, FieldKey.LYRICS, map, "lyrics");
            Util.setFieldIfExist(newTag, FieldKey.COMMENT, map, "comment");
            Util.setFieldIfExist(newTag, FieldKey.ALBUM, map, "album");
            Util.setFieldIfExist(newTag, FieldKey.ALBUM_ARTIST, map, "albumArtist");
            Util.setFieldIfExist(newTag, FieldKey.YEAR, map, "year");

            if (artwork != null) {
                Artwork cover = ArtworkFactory.getNew();
                cover.setBinaryData(artwork);
                newTag.setField(cover);
            }

            audioFile.commit();

            String[] urls = {path};
            String[] mimes = {"audio/mpeg"};
            MediaScannerConnection.scanFile(
                    context,
                    urls,
                    mimes,
                    new MediaScannerConnection.OnScanCompletedListener() {
                        @Override
                        public void onScanCompleted(String path, Uri uri) {
                            Log.i("SCANNING", "Success");
                        }
                    }
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @SuppressLint("NewApi")
    private HashMap<String, String> readTags(String path) {
        try {
            File mp3File = new File(path);
            AudioFile audioFile = AudioFileIO.read(mp3File);

            Tag tag = audioFile.getTag();
            HashMap<String, String> map = new HashMap<>();

            map.put("title", tag.getFirst(FieldKey.TITLE));
            map.put("artist", tag.getFirst(FieldKey.ARTIST));
            map.put("genre", tag.getFirst(FieldKey.GENRE));
            map.put("trackNumber", tag.getFirst(FieldKey.TRACK));
            map.put("trackTotal", tag.getFirst(FieldKey.TRACK_TOTAL));
            map.put("discNumber", tag.getFirst(FieldKey.DISC_NO));
            map.put("discTotal", tag.getFirst(FieldKey.DISC_TOTAL));
            map.put("lyrics", tag.getFirst(FieldKey.LYRICS));
            map.put("comment", tag.getFirst(FieldKey.COMMENT));
            map.put("album", tag.getFirst(FieldKey.ALBUM));
            map.put("albumArtist", tag.getFirst(FieldKey.ALBUM_ARTIST));
            map.put("year", tag.getFirst(FieldKey.YEAR));

            return map;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private byte[] readArtwork(String path) {
        try {
            File mp3File = new File(path);
            AudioFile audioFile = AudioFileIO.read(mp3File);
            return audioFile.getTag().getFirstArtwork().getBinaryData();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    static class Util {
        @SuppressLint("NewApi")
        static void setFieldIfExist(Tag tag, FieldKey field, HashMap<String, String> map, String key) throws FieldDataInvalidException {
            String value = map.getOrDefault(key, "");
            if (value != null && !value.equals("")) {
                tag.setField(field, value);
            }
        }

    }
}
