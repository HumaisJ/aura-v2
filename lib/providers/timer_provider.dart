import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerProvider with ChangeNotifier {
  // --- STATE ---
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 25;
  int _sessionsBeforeLongBreak = 4;
  
  // New Flag: Tells the UI if we have finished loading from storage
  bool _isDataLoaded = false; 

  // --- GETTERS ---
  int get workDuration => _workDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;
  bool get isDataLoaded => _isDataLoaded;

  // --- INITIALIZATION ---
  TimerProvider() {
    _loadSettings();
  }

  // --- ACTIONS ---
  void setWorkDuration(int minutes) {
    _workDuration = minutes;
    notifyListeners();
    _saveSettings();
  }

  void setShortBreakDuration(int minutes) {
    _shortBreakDuration = minutes;
    notifyListeners();
    _saveSettings();
  }

  void setLongBreakDuration(int minutes) {
    _longBreakDuration = minutes;
    notifyListeners();
    _saveSettings();
  }

  void setSessionsBeforeLongBreak(int count) {
    _sessionsBeforeLongBreak = count;
    notifyListeners();
    _saveSettings();
  }

  // --- PERSISTENCE ---
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('work_dur', _workDuration);
    await prefs.setInt('short_break_dur', _shortBreakDuration);
    await prefs.setInt('long_break_dur', _longBreakDuration);
    await prefs.setInt('sessions_before_long', _sessionsBeforeLongBreak);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = prefs.getInt('work_dur') ?? 25;
    _shortBreakDuration = prefs.getInt('short_break_dur') ?? 5;
    _longBreakDuration = prefs.getInt('long_break_dur') ?? 25;
    _sessionsBeforeLongBreak = prefs.getInt('sessions_before_long') ?? 4;
    
    // Mark as loaded and update UI
    _isDataLoaded = true;
    notifyListeners();
  }
}
