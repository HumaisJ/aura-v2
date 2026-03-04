import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class StatsProvider with ChangeNotifier {
  // Map<DateString, Map<MetricName, Count>>
  // Example: "2023-10-27": {"pomodoros": 5, "tasks": 3, "study_minutes": 125}
  Map<String, Map<String, int>> _dailyStats = {};

  Map<String, Map<String, int>> get dailyStats => _dailyStats;

  StatsProvider() {
    _loadStats();
  }

  // --- ACTIONS ---
  
  void logPomodoro(int minutes) {
    final today = _getTodayKey();
    _incrementStat(today, 'pomodoros', 1);
    _incrementStat(today, 'study_minutes', minutes);
    notifyListeners();
    _saveStats();
  }

  void logTaskCompletion() {
    final today = _getTodayKey();
    _incrementStat(today, 'tasks', 1);
    notifyListeners();
    _saveStats();
  }

  void _incrementStat(String dateKey, String metric, int amount) {
    if (!_dailyStats.containsKey(dateKey)) {
      _dailyStats[dateKey] = {'pomodoros': 0, 'tasks': 0, 'study_minutes': 0};
    }
    _dailyStats[dateKey]![metric] = (_dailyStats[dateKey]![metric] ?? 0) + amount;
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // --- PERSISTENCE ---
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aura_stats', jsonEncode(_dailyStats));
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('aura_stats');
    if (data != null) {
      try {
        // Complex decoding for Map<String, Map<String, int>>
        final Map<String, dynamic> decoded = jsonDecode(data);
        _dailyStats = decoded.map((key, value) {
          final Map<String, dynamic> innerMap = value;
          return MapEntry(key, innerMap.map((k, v) => MapEntry(k, v as int)));
        });
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading stats: $e");
      }
    }
  }

      Future<void> exportAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Gather all data
      final Map<String, dynamic> exportMap = {
        'timestamp': DateTime.now().toIso8601String(),
        'stats': _dailyStats,
        'tasks': jsonDecode(prefs.getString('tasks_data') ?? '[]'),
        'notebooks': jsonDecode(prefs.getString('notebooks_data') ?? '[]'),
      };

      // 2. Create JSON String
      final String jsonString = const JsonEncoder.withIndent('  ').convert(exportMap);
      debugPrint("📦 Backup JSON Generated: ${jsonString.length} chars");

      // 3. Save to temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/aura_backup.json'; // Fixed name to avoid weird chars
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      debugPrint("📂 File saved to: $filePath");

      // 4. Share File
      final result = await Share.shareXFiles(
        [XFile(filePath)], 
        text: 'My Aura Backup'
      );
      
      if (result.status == ShareResultStatus.dismissed) {
        debugPrint("❌ Share dismissed");
      } else {
        debugPrint("✅ Share successful");
      }

    } catch (e) {
      debugPrint("🚨 Export Failed: $e");
    }
  }

}
