import 'dart:async';
import 'dart:math'; // For Random
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // REQUIRED IMPORT

import '../services/notification_service.dart';
import '../providers/timer_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/sound_provider.dart'; // Import Sound Provider
import '../models/quotes.dart'; // Your new file
import '../theme/theme_manager.dart'; // To get current theme name

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with AutomaticKeepAliveClientMixin {
  // --- STATE ---
  int _remainingSeconds = 0;
  bool _isWorkSession = true;
  bool _isRunning = false;
  Timer? _timer;
  int _sessionsCompleted = 0;
  
  // Track if we have synced with the provider yet
  bool _initialSettingsSynced = false; 

  // --- LIFECYCLE ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Listen to the provider to sync settings on startup
    final settings = Provider.of<TimerProvider>(context);
    
    // Only sync if:
    // 1. Data is loaded from storage
    // 2. We haven't synced yet
    // 3. The timer is NOT running (don't interrupt a session)
    if (settings.isDataLoaded && !_initialSettingsSynced && !_isRunning) {
      setState(() {
        _remainingSeconds = settings.workDuration * 60;
        _initialSettingsSynced = true;
      });
    }
  }

  // --- ANIMATION MAPPING ---
  String _getAnimationForTheme(String themeName) {
    switch (themeName) {
      case 'FloraBlush Garden': return 'assets/animations/flower.json';
      case 'Rustic Meridian': return 'assets/animations/wheat.json';
      case 'Crimson Horizon': return 'assets/animations/sunset.json';
      case 'Nocturne Tide': return 'assets/animations/moon.json';
      case 'Velvet Roast': return 'assets/animations/coffee.json';
      case 'Imperial Blush': return 'assets/animations/rose.json';
      case 'Verdant Empress': return 'assets/animations/crown.json';
      case 'Solar Marina': return 'assets/animations/waves.json';
      case 'Arctic Dominion': return 'assets/animations/snow.json';
      case 'Nebula Regent': return 'assets/animations/galaxy.json';
      case 'Harvest Sovereign': return 'assets/animations/harvest.json';
      case 'Pearl Meridian': return 'assets/animations/pearl.json';
      case 'Neon Dominion': return 'assets/animations/neon.json';
      case 'Velour Machine': return 'assets/animations/car.json';
      case 'Monarch Noir': return 'assets/animations/chess.json';
      case 'Imperial Inferno': return 'assets/animations/fire.json';
      default: return 'assets/animations/default.json';
    }
  }

  // --- SOUND MENU UI ---
  void _showSoundMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<SoundProvider>(
          builder: (context, soundProvider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ambient Sound 🎧", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // Volume Slider
                  Row(
                    children: [
                      const Icon(Icons.volume_down),
                      Expanded(
                        child: Slider(
                          value: soundProvider.volume,
                          onChanged: (val) => soundProvider.setVolume(val),
                        ),
                      ),
                      const Icon(Icons.volume_up),
                    ],
                  ),
                  const Divider(),
                  
                  // Sound List
                  Expanded(
                    child: ListView(
                      children: soundProvider.availableSounds.keys.map((name) {
                        final isPlaying = soundProvider.currentSound == name && soundProvider.isPlaying;
                        return ListTile(
                          title: Text(name),
                          leading: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, 
                                        color: isPlaying ? Colors.blue : null),
                          trailing: isPlaying ? const Icon(Icons.graphic_eq, color: Colors.blue) : null,
                          onTap: () {
                            if (isPlaying) {
                              soundProvider.stopSound();
                            } else {
                              soundProvider.playSound(name);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- LOGIC ---

  void _showQuoteDialog() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final quotes = themeQuotes[themeManager.currentThemeName] ?? ["Great job! Keep going."];
    final randomQuote = quotes[Random().nextInt(quotes.length)];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Session Complete"),
        content: Text(
          randomQuote,
          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome"),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    if (_timer != null) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _handleTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    final settings = Provider.of<TimerProvider>(context, listen: false);
    setState(() {
      _isWorkSession = true;
      _remainingSeconds = settings.workDuration * 60;
    });
  }

  void _handleTimerComplete() {
    _pauseTimer();
    final settings = Provider.of<TimerProvider>(context, listen: false);
    if (_isWorkSession) {
      // --- WORK SESSION ENDED ---
      _sessionsCompleted++;
      
      bool isLongBreak = (_sessionsCompleted % settings.sessionsBeforeLongBreak == 0);
      
      NotificationService.showNotification(
        title: "Work Session Complete! 🎉",
        body: isLongBreak 
            ? "You earned a LONG break! Relax. 🛋️" 
            : "Take a short break. You earned it.",
      );
      
      _showQuoteDialog();

      setState(() {
        _isWorkSession = false;
        _remainingSeconds = isLongBreak 
            ? settings.longBreakDuration * 60 
            : settings.shortBreakDuration * 60;
      });

      // Log Stats
      final stats = Provider.of<StatsProvider>(context, listen: false);
      final timerSettings = Provider.of<TimerProvider>(context, listen: false);
      stats.logPomodoro(timerSettings.workDuration); 

    } else {
      // --- BREAK ENDED ---
      bool wasLongBreak = (_sessionsCompleted > 0 && 
          _sessionsCompleted % settings.sessionsBeforeLongBreak == 0);

      if (wasLongBreak) {
         NotificationService.showNotification(
          title: "Cycle Complete! 🏆",
          body: "Congratulations! You finished a full cycle.",
        );
        setState(() {
          _sessionsCompleted = 0;
        });
      } else {
        NotificationService.showNotification(
          title: "Break is Over! ⏳",
          body: "Time to focus again.",
        );
      }

      setState(() {
        _isWorkSession = true;
        _remainingSeconds = settings.workDuration * 60;
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  bool get wantKeepAlive => true;

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = Provider.of<TimerProvider>(context);
    final themeManager = Provider.of<ThemeManager>(context); // Get Theme Manager

    int totalDuration;
    if (_isWorkSession) {
      totalDuration = settings.workDuration * 60;
    } else {
      bool isLongBreak = (_sessionsCompleted > 0 && _sessionsCompleted % settings.sessionsBeforeLongBreak == 0);
      totalDuration = isLongBreak ? settings.longBreakDuration * 60 : settings.shortBreakDuration * 60;
    }

    if (totalDuration == 0) totalDuration = 1; 

    final double progress = _remainingSeconds / totalDuration;
    final Color currentColor = _isWorkSession 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.secondary;

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showSoundMenu,
        child: const Icon(Icons.music_note),
        heroTag: "sound_fab",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isWorkSession ? "Focus Time 🎯" : "Rest & Recharge ☕",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          
          Text(
            "Sessions: $_sessionsCompleted / ${settings.sessionsBeforeLongBreak}",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // --- ANIMATED TIMER STACK ---
          Stack(
            alignment: Alignment.center,
            children: [
              // 1. Lottie Animation
              Opacity(
                opacity: 0.5,
                child: Lottie.asset(
                  _getAnimationForTheme(themeManager.currentThemeName),
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  animate: _isRunning,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.timer, size: 100, color: currentColor.withValues(alpha: 0.2));
                  },
                ),
              ),
              // 2. Progress Ring
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 15,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  color: currentColor,
                ),
              ),
              // 3. Text
              Text(
                _formatTime(_remainingSeconds),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentColor,
                      shadows: [
                        const Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 20),
              FloatingActionButton.large(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                backgroundColor: currentColor,
                foregroundColor: Colors.white,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 40,
                onPressed: _handleTimerComplete,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
