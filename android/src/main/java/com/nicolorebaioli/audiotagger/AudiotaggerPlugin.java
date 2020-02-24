package com.nicolorebaioli.audiotagger;

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.MediaScannerConnection;
import android.net.Uri;

import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.jaudiotagger.tag.FieldDataInvalidException;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.flac.FlacTag;
import org.jaudiotagger.tag.id3.ID3v1Tag;
import org.jaudiotagger.tag.id3.ID3v24Tag;
import org.jaudiotagger.tag.id3.valuepair.ImageFormats;
import org.jaudiotagger.tag.images.Artwork;
import org.jaudiotagger.tag.images.ArtworkFactory;
import org.jaudiotagger.tag.mp4.Mp4Tag;
import org.jaudiotagger.tag.reference.PictureTypes;
import org.jaudiotagger.tag.vorbiscomment.VorbisCommentFieldKey;
import org.jaudiotagger.tag.vorbiscomment.VorbisCommentTag;
import org.jaudiotagger.tag.vorbiscomment.util.Base64Coder;

import java.io.File;
import java.io.RandomAccessFile;
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
                if (call.hasArgument("path") && call.hasArgument("tags") && call.hasArgument("artwork")) {
                    String path = call.argument("path");
                    HashMap<String, String> map = call.argument("tags");
                    String artwork = call.argument("artwork");
                    result.success(writeTags(path, map, artwork));
                } else
                    result.error("400", "Missing parameters", null);
                break;
            case "readTags":
                if (call.hasArgument("path"))
                    result.success(readTags((String) call.argument("path")));
                else
                    result.error("400", "Missing parameter", null);
                break;
            case "readArtwork":
                if (call.hasArgument("path"))
                    result.success(readArtwork((String) call.argument("path")));
                else
                    result.error("400", "Missing parameter", null);
                break;
            default:
                result.notImplemented();
        }
    }

    private boolean writeTags(String path, HashMap<String, String> map, String artwork) {
        try {
            File mp3File = new File(path);
            AudioFile audioFile = AudioFileIO.read(mp3File);

            Tag newTag = audioFile.getTag();

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

            Artwork cover = null;
            if (artwork != null && artwork.trim().length() > 0) {

                // 删除已有的专辑封面
                newTag.deleteArtworkField();

                // dui下面的内容做特殊处理
                cover = ArtworkFactory.createArtworkFromFile(new File(artwork));

                if (newTag instanceof Mp4Tag) {
                    RandomAccessFile imageFile = new RandomAccessFile(new File(artwork), "r");
                    byte[] imageData = new byte[(int) imageFile.length()];
                    imageFile.read(imageData);
                    newTag.setField(((Mp4Tag) newTag).createArtworkField(imageData));
                }else if (newTag instanceof FlacTag) {
                    RandomAccessFile imageFile = new RandomAccessFile(new File(artwork), "r");
                    byte[] imageData = new byte[(int) imageFile.length()];
                    imageFile.read(imageData);
                    newTag.setField(((FlacTag) newTag).createArtworkField(imageData,
                            PictureTypes.DEFAULT_ID,
                            ImageFormats.MIME_TYPE_JPEG,
                            "test",
                            0,
                            0,
                            24,
                            0));
                }else if (newTag instanceof VorbisCommentTag) {
                    RandomAccessFile imageFile = new RandomAccessFile(new File(artwork), "r");
                    byte[] imageData = new byte[(int) imageFile.length()];
                    imageFile.read(imageData);
                    char[] base64Data = Base64Coder.encode(imageData);
                    String base64image = new String(base64Data);
                    newTag.setField(((VorbisCommentTag) newTag).createField(VorbisCommentFieldKey.COVERART, base64image));
                    newTag.setField(((VorbisCommentTag) newTag).createField(VorbisCommentFieldKey.COVERARTMIME, "image/png"));
                }else {
                    cover = ArtworkFactory.createArtworkFromFile(new File(artwork));
                    newTag.setField(cover);
                }
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

    enum Version {ID3V1, ID3V2}

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
