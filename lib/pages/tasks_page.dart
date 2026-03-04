import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Needed for Provider.of
import '../providers/stats_provider.dart'; // Import your new class


// --- CATEGORIES DEFINITION ---
final Map<String, Color> taskCategories = {
  'Study': Colors.blueAccent,
  'Work': Colors.orangeAccent,
  'Chore': Colors.green,
  'Fun': Colors.purpleAccent,
  'Other': Colors.grey,
};

class TaskItem {
  String id;
  String title;
  bool isCompleted;
  String category;

  TaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Other',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'category': category,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String? ?? DateTime.now().toString(), // Safety
      title: json['title'] as String? ?? 'Untitled',          // Safety
      isCompleted: json['isCompleted'] as bool? ?? false,     // Safety
      category: json['category'] as String? ?? 'Other',       // Safety
    );
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with AutomaticKeepAliveClientMixin {
  List<TaskItem> _tasks = [];
    String _currentFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

    Widget _buildFilterBar() {
    // "All" + List of Categories
    final filters = ['All', ...taskCategories.keys];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _currentFilter == filter;
          final color = filter == 'All' ? Colors.black : (taskCategories[filter] ?? Colors.grey);

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            selectedColor: color.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = filter);
              }
            },
          );
        },
      ),
    );
  }


  // --- SAVE & LOAD ---
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks_data', encodedData);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('tasks_data');
    if (encodedData != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(encodedData);
        setState(() {
          _tasks = decodedList.map((item) => TaskItem.fromJson(item)).toList();
        });
      } catch (e) {
        debugPrint("Error loading tasks: $e");
        // If data is corrupt, clear it to prevent crash loop
        await prefs.remove('tasks_data');
        setState(() => _tasks = []);
      }
    }
  }

  // --- LOGIC ---
  void _addTask(String title, String category) {
    setState(() {
      _tasks.insert(0, TaskItem(
        id: DateTime.now().toString(),
        title: title,
        category: category,
      ));
    });
    _saveTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;

      if (_tasks[index].isCompleted) {
        Provider.of<StatsProvider>(context, listen: false).logTaskCompletion();
    }
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _editTask(int index) {
    final task = _tasks[index];
    final editController = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                setState(() {
                  _tasks[index].title = editController.text.trim();
                });
                _saveTasks();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final TaskItem item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
    _saveTasks();
  }

  // --- NEW: ADD TASK SHEET ---
  void _showAddTaskSheet() {
    String selectedCategory = 'Study';
    final tempController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("New Task", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: tempController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "What needs to be done?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Category:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: taskCategories.keys.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: taskCategories[cat]?.withValues(alpha: 0.3),
                    onSelected: (bool selected) {
                      setSheetState(() => selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (tempController.text.trim().isNotEmpty) {
                      _addTask(tempController.text.trim(), selectedCategory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add Task"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

    @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // 1. Filter Tasks
    final visibleTasks = _tasks.where((t) {
      if (_currentFilter == 'All') return true;
      return t.category == _currentFilter;
    }).toList();

    // 2. Split into Active and Completed
    final activeTasks = visibleTasks.where((t) => !t.isCompleted).toList();
    final completedTasks = visibleTasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),
          const SizedBox(height: 10),
          
          // Task List (Expanded)
          Expanded(
            child: visibleTasks.isEmpty
                ? Center(child: Text("No tasks in $_currentFilter", style: const TextStyle(color: Colors.grey)))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      // Active Tasks (Reorderable only if 'All' is selected to keep indices simple, 
                      // or we map back to original indices. For simplicity in Sprint 2, let's just show list items for filtered view)
                      
                      ...activeTasks.map((task) {
                        final originalIndex = _tasks.indexOf(task);
                        return _buildTaskCard(task, originalIndex);
                      }),

                      if (completedTasks.isNotEmpty) ...[
                        const Divider(height: 30),
                        ExpansionTile(
                          title: Text("Completed (${completedTasks.length})", style: const TextStyle(color: Colors.grey)),
                          children: completedTasks.map((task) {
                            final originalIndex = _tasks.indexOf(task);
                            return _buildTaskCard(task, originalIndex);
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper Widget to reduce code duplication
  Widget _buildTaskCard(TaskItem task, int index) {
    final categoryColor = taskCategories[task.category] ?? Colors.grey;
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _deleteTask(index),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: task.isCompleted ? 0 : 2,
        color: task.isCompleted ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : null,
        child: ListTile(
          onLongPress: () => _editTask(index),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _toggleTask(index),
            shape: const CircleBorder(),
            activeColor: categoryColor,
          ),
          title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
          subtitle: !task.isCompleted
              ? Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(task.category, style: TextStyle(fontSize: 10, color: categoryColor, fontWeight: FontWeight.bold)),
                  ),
                ])
              : null,
        ),
      ),
    );
  }
}
