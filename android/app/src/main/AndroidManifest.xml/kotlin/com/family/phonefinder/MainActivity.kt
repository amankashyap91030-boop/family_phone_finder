package com.family.phonefinder

import android.content.Context
import android.media.AudioManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.family.phonefinder/volume_override"
    private var originalVolume: Int = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            
            when (call.method) {
                "forceMaxSystemVolume" -> {
                    originalVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    
                    audioManager.setStreamVolume(
                        AudioManager.STREAM_MUSIC,
                        audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
                        AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE
                    )
                    result.success(true)
                }
                "restoreOriginalSystemVolume" -> {
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, originalVolume, 0)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
