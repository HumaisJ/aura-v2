import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'theme/theme_manager.dart';
import 'providers/timer_provider.dart';
import 'services/notification_service.dart';
import 'providers/stats_provider.dart';
import 'providers/sound_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Providers FIRST
  final themeManager = ThemeManager();
  final timerProvider = TimerProvider();
  final soundProvider = SoundProvider(); // Assuming you have this
  final statsProvider = StatsProvider(); // Assuming you have this

  // Initialize Services
  try {
    await NotificationService.init();
    debugPrint("🔔 Notification Service Ready");
  } catch (e) {
    debugPrint("⚠️ Notification Service Failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeManager),
        ChangeNotifierProvider(create: (_) => timerProvider),
        ChangeNotifierProvider(create: (_) => soundProvider),
        ChangeNotifierProvider(create: (_) => statsProvider),
      ],
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

        return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: themeManager.currentTheme,
      home: const HomePage(),
      builder: (context, child) {
        return MediaQuery(
          // Prevent user font scaling from breaking layout
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
