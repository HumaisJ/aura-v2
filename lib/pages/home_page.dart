import 'package:flutter/material.dart';
import 'timer_page.dart';
import 'tasks_page.dart';
import 'thoughts_page.dart';
import 'settings_page.dart';
import 'stats_page.dart'; // Import the new page


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(); // 1. Controller

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 2. Animate to the page instead of replacing it
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aura"),
        actions: [
           // NEW STATS BUTTON
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "Insights",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      // 3. Use PageView to keep pages alive
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to switch tabs
        children: const [
          TimerPage(),
          TasksPage(),
          ThoughtsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Thoughts'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
