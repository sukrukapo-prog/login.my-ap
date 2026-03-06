import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  bool _musicEnabled = true;
  double _musicVolume = 0.4;
  int _selectedTrack = 0;
  bool _soundEffectsEnabled = true;
  String _appTheme = 'dark';
  String _displayName = '';

  bool get musicEnabled => _musicEnabled;
  double get musicVolume => _musicVolume;
  int get selectedTrack => _selectedTrack;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  String get appTheme => _appTheme;
  String get displayName => _displayName;

  static const List<Map<String, String>> tracks = [
    {'name': 'Birds',   'path': 'assets/images/meditation/audio/birds.mp3'},
    {'name': 'Morning', 'path': 'assets/images/meditation/audio/morning.mp3'},
    {'name': 'Ocean',   'path': 'assets/images/meditation/audio/ocean.mp3'},
    {'name': 'Energy',  'path': 'assets/images/meditation/audio/excited.mp3'},
  ];

  String get currentTrackPath => tracks[_selectedTrack]['path']!;
  String get currentTrackName => tracks[_selectedTrack]['name']!;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _musicEnabled        = prefs.getBool('musicEnabled')        ?? true;
    _musicVolume         = prefs.getDouble('musicVolume')       ?? 0.4;
    _selectedTrack       = prefs.getInt('selectedTrack')        ?? 0;
    _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
    _appTheme            = prefs.getString('appTheme')          ?? 'dark';
    _displayName         = prefs.getString('displayName')       ?? '';
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', value);
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', value);
    notifyListeners();
  }

  Future<void> setSelectedTrack(int index) async {
    _selectedTrack = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTrack', index);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) async {
    _soundEffectsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', value);
    notifyListeners();
  }

  Future<void> setDisplayName(String name) async {
    _displayName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', name);
    notifyListeners();
  }
}