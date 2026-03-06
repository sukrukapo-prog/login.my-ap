import 'package:audioplayers/audioplayers.dart';
import 'package:fitmetrics/core/app_settings.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isPaused = false;

  final AppSettings _settings = AppSettings();

  Future<void> init() async {
    await _settings.load();
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    if (_settings.musicEnabled) {
      await startMusic();
    }
  }

  Future<void> startMusic() async {
    if (_isPlaying) return;
    try {
      final path = _settings.currentTrackPath.replaceFirst('assets/', '');
      await _bgPlayer.setVolume(_settings.musicVolume);
      await _bgPlayer.play(AssetSource(path));
      _isPlaying = true;
      _isPaused = false;
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    await _bgPlayer.stop();
    _isPlaying = false;
    _isPaused = false;
  }

  Future<void> pauseMusic() async {
    if (_isPlaying && !_isPaused) {
      await _bgPlayer.pause();
      _isPaused = true;
    }
  }

  Future<void> resumeMusic() async {
    if (_settings.musicEnabled && _isPaused) {
      await _bgPlayer.resume();
      _isPaused = false;
    } else if (_settings.musicEnabled && !_isPlaying) {
      await startMusic();
    }
  }

  Future<void> changeTrack(int trackIndex) async {
    final wasPlaying = _isPlaying;
    await _settings.setSelectedTrack(trackIndex);
    await _bgPlayer.stop();
    _isPlaying = false;
    if (wasPlaying && _settings.musicEnabled) {
      await startMusic();
    }
  }

  Future<void> setVolume(double volume) async {
    await _settings.setMusicVolume(volume);
    await _bgPlayer.setVolume(volume);
  }

  Future<void> toggleMusic() async {
    if (_settings.musicEnabled) {
      await _settings.setMusicEnabled(false);
      await stopMusic();
    } else {
      await _settings.setMusicEnabled(true);
      await startMusic();
    }
  }

  Future<void> playClickSound() async {
    if (!_settings.soundEffectsEnabled) return;
    HapticFeedback.lightImpact();
  }

  void dispose() {
    _bgPlayer.dispose();
    _fxPlayer.dispose();
  }
}