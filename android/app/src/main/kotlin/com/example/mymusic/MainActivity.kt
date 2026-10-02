package com.example.mymusic

import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native MediaSession for WebView playback.
 *
 * It has no audio source and never claims that the WebView is a just_audio
 * track. Flutter updates it only after a trusted WebView bridge event.
 */
class MainActivity : AudioServiceActivity() {
    companion object {
        private const val STREAM_MEDIA_CHANNEL = "com.example.mymusic/stream_media"
    }

    private var streamChannel: MethodChannel? = null
    private var streamSession: MediaSession? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        streamChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STREAM_MEDIA_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler(::handleStreamMediaCall)
        }
    }

    private fun handleStreamMediaCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                ensureStreamSession()
                result.success(null)
            }
            "update" -> {
                updateStreamSession(call.arguments as? Map<*, *> ?: emptyMap<Any, Any>())
                result.success(null)
            }
            "clear" -> {
                clearStreamSession()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun ensureStreamSession(): MediaSession {
        streamSession?.let { return it }

        return MediaSession(this, "MyMusicWebStream").also { session ->
            session.setCallback(object : MediaSession.Callback() {
                override fun onPlay() = sendStreamCommand("play")
                override fun onPause() = sendStreamCommand("pause")
                override fun onStop() = sendStreamCommand("stop")
            })
            streamSession = session
        }
    }

    private fun sendStreamCommand(command: String) {
        streamChannel?.invokeMethod("command", mapOf("command" to command))
    }

    private fun updateStreamSession(arguments: Map<*, *>) {
        val active = arguments["active"] as? Boolean ?: false
        if (!active) {
            clearStreamSession()
            return
        }

        val session = ensureStreamSession()
        val isPlaying = arguments["isPlaying"] as? Boolean ?: false
        val title = arguments["title"] as? String ?: "YouTube Music"
        val artist = arguments["artist"] as? String ?: ""
        val artUrl = arguments["artUrl"] as? String

        val metadata = MediaMetadata.Builder()
            .putString(MediaMetadata.METADATA_KEY_TITLE, title)
            .putString(MediaMetadata.METADATA_KEY_ARTIST, artist)
            .apply {
                if (!artUrl.isNullOrBlank()) {
                    putString(MediaMetadata.METADATA_KEY_ART_URI, artUrl)
                }
            }
            .build()
        session.setMetadata(metadata)

        val state = if (isPlaying) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
        val actions = PlaybackState.ACTION_PLAY or
            PlaybackState.ACTION_PAUSE or
            PlaybackState.ACTION_STOP or
            PlaybackState.ACTION_PLAY_PAUSE
        session.setPlaybackState(
            PlaybackState.Builder()
                .setActions(actions)
                .setState(state, PlaybackState.PLAYBACK_POSITION_UNKNOWN, 1f)
                .build(),
        )
        session.isActive = true
    }

    private fun clearStreamSession() {
        streamSession?.let { session ->
            session.setPlaybackState(
                PlaybackState.Builder()
                    .setState(PlaybackState.STATE_NONE, 0L, 0f)
                    .build(),
            )
            session.setMetadata(null)
            session.isActive = false
        }
    }

    override fun onDestroy() {
        streamChannel?.setMethodCallHandler(null)
        streamChannel = null
        streamSession?.release()
        streamSession = null
        super.onDestroy()
    }
}
