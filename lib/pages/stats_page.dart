import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/stats_provider.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = Provider.of<StatsProvider>(context);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayData = stats.dailyStats[todayKey] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text("Productivity Insights 📊")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Today's Summary
          _buildSummaryCard(todayData),
          const SizedBox(height: 20),

          // 2. Weekly Chart
          const Text("Last 7 Days (Focus Minutes)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            height: 200,
            padding: const EdgeInsets.only(right: 16),
            child: _buildWeeklyChart(stats.dailyStats, context),
          ),
          
          const SizedBox(height: 20),
          
          // 3. Task Stats
          const Text("Total Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTotalStats(stats.dailyStats),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, int> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.timer, "${data['pomodoros'] ?? 0}", "Sessions"),
            _buildStatItem(Icons.access_time, "${data['study_minutes'] ?? 0}m", "Focus Time"),
            _buildStatItem(Icons.check_circle, "${data['tasks'] ?? 0}", "Tasks Done"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeeklyChart(Map<String, Map<String, int>> data, BuildContext context) {
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    double maxMinutes = 0;

    // Generate last 7 days data
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final minutes = (data[dateKey]?['study_minutes'] ?? 0).toDouble();
      if (minutes > maxMinutes) maxMinutes = minutes;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i, // 0 is oldest day, 6 is today
          barRods: [
            BarChartRodData(
              toY: minutes,
              color: Theme.of(context).primaryColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxMinutes + 10, // Add buffer
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(date), // Mon, Tue
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildTotalStats(Map<String, Map<String, int>> data) {
    int totalPomodoros = 0;
    int totalTasks = 0;
    
    data.forEach((_, metrics) {
      totalPomodoros += metrics['pomodoros'] ?? 0;
      totalTasks += metrics['tasks'] ?? 0;
    });

    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
        title: const Text("Lifetime Achievements"),
        subtitle: Text("$totalPomodoros Focus Sessions • $totalTasks Tasks Crushed"),
      ),
    );
  }
}
