import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../providers/timer_provider.dart'; // Import the Timer Provider
import '../providers/stats_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")), // Renamed to Settings as it does more now
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ------------------------------------------------
          // 1. LIGHT/DARK MODE TOGGLE
          // ------------------------------------------------
          
                    // ... inside ListView children ...
          const SizedBox(height: 24),
          _buildHeader("Data & Storage 💾"),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text("Export Backup"),
                  subtitle: const Text("Save your tasks, notes, and stats as JSON"),
                  onTap: () {
                    // Call the export function
                    // Note: We need to access StatsProvider here. 
                    // Make sure to add `final statsProvider = Provider.of<StatsProvider>(context, listen: false);` at top of build method.
                    Provider.of<StatsProvider>(context, listen: false).exportAllData();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Clear All Data", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    // Ideally show a confirmation dialog first!
                    // For now, let's keep it safe and just show a SnackBar saying "Feature coming soon" 
                    // or implement a real wipe if you are brave.
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Safety Lock: Manual Clear disabled for now.")));
                  },
                ),
              ],
            ),
          ),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: Text(
                themeManager.isDarkMode ? "Dark Mode 🌙" : "Light Mode ☀️",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text("Adjust the brightness of your Aura"),
              value: themeManager.isDarkMode,
              onChanged: (val) {
                themeManager.toggleBrightness(val);
              },
            ),
          ),

          // ------------------------------------------------
          // 2. TIMER CONFIGURATION (NEW SECTION ADDED HERE)
          // ------------------------------------------------
          const SizedBox(height: 24),
          _buildHeader("Timer Configuration ⏱️"),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Work Duration Dropdown
                  _buildDropdownRow(
                    "Work Duration",
                    timerProvider.workDuration,
                    [15, 25, 30, 40, 60],
                    (val) => timerProvider.setWorkDuration(val!),
                  ),
                  const Divider(),

                  // Short Break Dropdown
                  _buildDropdownRow(
                    "Short Break",
                    timerProvider.shortBreakDuration,
                    [5, 10, 13, 15, 20],
                    (val) => timerProvider.setShortBreakDuration(val!),
                  ),
                  const Divider(),

                  // Long Break Dropdown
                  _buildDropdownRow(
                    "Long Break",
                    timerProvider.longBreakDuration,
                    [25, 30, 35, 40, 55],
                    (val) => timerProvider.setLongBreakDuration(val!),
                  ),
                  const Divider(),

                  // Cycles Count Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sessions before Long Break", style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: timerProvider.sessionsBeforeLongBreak,
                        underline: Container(),
                        items: [2, 3, 4, 5, 6].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text("$value sessions", style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) => timerProvider.setSessionsBeforeLongBreak(val!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------
          // 3. THEME SELECTOR
          // ------------------------------------------------
          const SizedBox(height: 24),
          _buildHeader("Select Theme 🎨"),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: themeManager.availableThemes.length,
            itemBuilder: (context, index) {
              final theme = themeManager.availableThemes[index];
              final name = theme['name'] as String;
              final primary = theme['primary'] as Color;

              // Determine preview colors
              final bg = themeManager.isDarkMode 
                  ? theme['background'] as Color 
                  : const Color(0xFFF9F9F9);

              final isSelected = themeManager.currentThemeName == name;

              return GestureDetector(
                onTap: () => themeManager.setTheme(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.withValues(alpha: 0.2),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      if (isSelected) 
                        BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Color Strip
                      Container(
                        width: 12,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text Name
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: themeManager.isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                         Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: Icon(Icons.check_circle, color: primary, size: 18),
                         ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildDropdownRow(String title, int currentValue, List<int> options, Function(int?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        DropdownButton<int>(
          value: currentValue,
          underline: Container(),
          items: options.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text("$value min", style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
