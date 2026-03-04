import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notebook.dart';
import 'create_notebook_page.dart';
import 'notebook_content_page.dart';

class ThoughtsPage extends StatefulWidget {
  const ThoughtsPage({super.key});

  @override
  State<ThoughtsPage> createState() => _ThoughtsPageState();
}

class _ThoughtsPageState extends State<ThoughtsPage> with AutomaticKeepAliveClientMixin {
  List<Notebook> _notebooks = [];
  bool _isGridView = true; // State variable for view toggle

  @override
  void initState() {
    super.initState();
    _loadNotebooks();
  }

  // --- SAVE & LOAD LOGIC ---
  Future<void> _saveNotebooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_notebooks.map((n) => n.toJson()).toList());
    await prefs.setString('notebooks_data', encodedData);
  }

  Future<void> _loadNotebooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('notebooks_data');
    if (encodedData != null) {
      final List<dynamic> decodedList = jsonDecode(encodedData);
      setState(() {
        _notebooks = decodedList.map((item) => Notebook.fromJson(item)).toList();
      });
    }
  }

  void _createNotebook() async {
        if (_notebooks.length >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Storage Limit Reached (Max 10 Notebooks)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Notebook? newNotebook = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNotebookPage()),
    );

    if (newNotebook != null) {
      setState(() {
        _notebooks.add(newNotebook);
      });
      _saveNotebooks(); // Save new book
    }
  }

    void _openNotebook(Notebook notebook) async {
    // 1. Navigate and wait for user to come back
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotebookContentPage(notebook: notebook),
      ),
    );
    
    // 2. Refresh the UI explicitly
    // Since objects are passed by reference, the 'notebook' object is actually updated in memory,
    // but the UI needs a nudge to redraw the "pages count".
    setState(() {}); 
    
    // 3. Persist changes
    _saveNotebooks();
  }


  // Show Options Dialog
  void _showNotebookOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Rename Notebook"),
              onTap: () {
                Navigator.pop(context);
                _renameNotebook(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Notebook", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteNotebook(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameNotebook(int index) {
    final notebook = _notebooks[index];
    final controller = TextEditingController(text: notebook.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Notebook"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "New Title"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _notebooks[index] = Notebook(
                    id: notebook.id,
                    title: controller.text.trim(),
                    color: notebook.color,
                    pattern: notebook.pattern,
                    pages: notebook.pages,
                  );
                });
                _saveNotebooks();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteNotebook(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notebook?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _notebooks.removeAt(index);
              });
              _saveNotebooks();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Thoughts"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: _notebooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text("No notebooks yet!",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : _isGridView
              // --- GRID VIEW ---
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _notebooks.length,
                  itemBuilder: (context, index) {
                    final notebook = _notebooks[index];
                    return GestureDetector(
                      onTap: () => _openNotebook(notebook),
                      onLongPress: () => _showNotebookOptions(index),
                      child: Container(
                        decoration: _buildNotebookDecoration(notebook),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  notebook.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 2,
                                          color: Colors.black45,
                                          offset: Offset(1, 1))
                                    ],
                                  ),
                                ),
                                if (notebook.pattern != 'solid')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Icon(Icons.auto_awesome,
                                        color: Colors.white
                                            .withValues(alpha: 0.5),
                                        size: 16),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              // --- LIST VIEW ---
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notebooks.length,
                  itemBuilder: (context, index) {
                    final notebook = _notebooks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: _buildNotebookDecoration(notebook)
                              .copyWith(borderRadius: BorderRadius.circular(8)),
                        ),
                        title: Text(notebook.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${notebook.pages.length} pages"),
                        onTap: () => _openNotebook(notebook),
                        onLongPress: () => _showNotebookOptions(index),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNotebook,
        child: const Icon(Icons.add),
      ),
    );
  }

  BoxDecoration _buildNotebookDecoration(Notebook notebook) {
    BoxDecoration base = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(2, 2))
      ],
    );

    switch (notebook.pattern) {
      case 'ocean':
        return base.copyWith(
            gradient: LinearGradient(
                colors: [notebook.color, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight));
      case 'sunset':
        return base.copyWith(
            gradient: LinearGradient(
                colors: [notebook.color, Colors.orangeAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter));
      case 'galaxy':
        return base.copyWith(
            color: Colors.black,
            gradient: RadialGradient(
                colors: [notebook.color, Colors.black],
                radius: 1.2,
                center: Alignment.topLeft));
      case 'forest':
        return base.copyWith(
            gradient: LinearGradient(
                colors: [notebook.color, Colors.green.shade900],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight));
      default:
        return base.copyWith(color: notebook.color);
    }
  }
}
