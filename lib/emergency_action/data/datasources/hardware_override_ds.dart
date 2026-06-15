import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';

class HardwareOverrideEngine {
  static const MethodChannel _androidVolumeChannel = MethodChannel('com.family.phonefinder/volume_override');
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isStrobeActive = false;

  Future<void> triggerEmergencySequence() async {
    try {
      await _androidVolumeChannel.invokeMethod('forceMaxSystemVolume');
      
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource('asset:///assets/sounds/emergency_alarm.mp3'), volume: 1.0);
      
      _startStrobeLoop();
    } on PlatformException catch (e) {
      print("Failed to run hardware execution override map: ${e.message}");
    }
  }

  void _startStrobeLoop() async {
    final bool isTorchAvailable = await TorchLight.isTorchAvailable();
    if (!isTorchAvailable) return;

    _isStrobeActive = true;
    Future.doWhile(() async {
      if (!_isStrobeActive) return false;
      try {
        await TorchLight.enableTorch();
        await Future.delayed(const Duration(milliseconds: 100));
        await TorchLight.disableTorch();
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (_) {
        return false;
      }
      return true;
    });
  }

  Future<void> resetHardwareSequence() async {
    _isStrobeActive = false;
    await _audioPlayer.stop();
    try {
      await TorchLight.disableTorch();
      await _androidVolumeChannel.invokeMethod('restoreOriginalSystemVolume');
    } catch (_) {}
  }
}
