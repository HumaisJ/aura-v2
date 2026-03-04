import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? _currentSound; // null = off
  double _volume = 0.5;
  bool _isPlaying = false;

  String? get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  // Sound Map (Name -> Filename)
  final Map<String, String> availableSounds = {
    'Rain 🌧️': 'rain.mp3',
    'Forest 🌲': 'forest.mp3',
    'Fireplace 🔥': 'fire.mp3',
    'Café ☕': 'cafe.mp3',
    'Wind 🍃': 'wind.mp3',
    'Forest River 🌊': 'forest_river.mp3',
  };

  SoundProvider() {
    _player.setReleaseMode(ReleaseMode.loop); // Loop forever
    _loadSettings();
  }

  // --- ACTIONS ---

  void setVolume(double val) {
    _volume = val;
    _player.setVolume(val);
    notifyListeners();
    _saveSettings();
  }

  void playSound(String name) async {
    if (_currentSound == name && _isPlaying) {
      // Toggle Off
      stopSound();
    } else {
      // Play New
      _currentSound = name;
      _isPlaying = true;
      final filename = availableSounds[name]!;
      await _player.setSource(AssetSource('sounds/$filename'));
      await _player.setVolume(_volume);
      await _player.resume();
      notifyListeners();
      _saveSettings();
    }
  }

  void stopSound() async {
    await _player.stop();
    _isPlaying = false;
    _currentSound = null;
    notifyListeners();
    _saveSettings();
  }

  // --- PERSISTENCE ---
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_volume', _volume);
    // We don't save "current sound" to auto-play on next app launch 
    // because that might startle the user. Only volume is persistent.
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('sound_volume') ?? 0.5;
    notifyListeners();
  }
}
