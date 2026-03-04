import 'package:flutter/material.dart';
import '../models/notebook.dart';

class CreateNotebookPage extends StatefulWidget {
  const CreateNotebookPage({super.key});

  @override
  State<CreateNotebookPage> createState() => _CreateNotebookPageState();
}

class _CreateNotebookPageState extends State<CreateNotebookPage> {
  final TextEditingController _titleController = TextEditingController();
  Color _selectedColor = const Color(0xFF2196F3);
  String _selectedPattern = 'solid';

  final List<Color> _colors = [
    const Color.fromARGB(255, 72, 102, 153), const Color.fromARGB(255, 240, 171, 214), const Color.fromARGB(255, 86, 137, 112), const Color.fromARGB(255, 156, 128, 93),
    const Color.fromARGB(255, 141, 69, 154), const Color.fromARGB(255, 45, 113, 106), const Color.fromARGB(255, 16, 48, 64), const Color.fromARGB(255, 124, 33, 0),
    const Color.fromARGB(255, 244, 183, 255), const Color.fromRGBO(183, 223, 248, 1), const Color.fromARGB(255, 116, 197, 124), const Color.fromARGB(255, 243, 148, 135),
  ];

  final Map<String, String> _patterns = {
    'solid': 'Solid',
    'ocean': 'River 🌊',
    'sunset': 'Cafe ☕',
    'galaxy': 'Wind 🍃',
    'forest': 'Forest 🌲',
  };

  void _createNotebook() {
    if (_titleController.text.trim().isEmpty) return;

    final newNotebook = Notebook(
      id: DateTime.now().toString(),
      title: _titleController.text.trim(),
      color: _selectedColor,
      pattern: _selectedPattern,
      pages: [''],
    );

    Navigator.pop(context, newNotebook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Notebook")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Notebook Title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          
          // 1. Color Picker
          const Text("Base Color:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colors.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _selectedColor == color ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: [if(_selectedColor == color) BoxShadow(color: Colors.black.withValues(alpha:0.2), blurRadius: 4)],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // 2. Pattern Picker
          const Text("Cover Design:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _patterns.length,
            itemBuilder: (context, index) {
              String key = _patterns.keys.elementAt(index);
              String name = _patterns.values.elementAt(index);
              return RadioListTile<String>(
                title: Text(name),
                value: key,
                groupValue: _selectedPattern,
                activeColor: _selectedColor,
                onChanged: (val) => setState(() => _selectedPattern = val!),
                secondary: Container(
                  width: 30, height: 30,
                  decoration: _getPreviewDecoration(key, _selectedColor),
                ),
              );
            },
          ),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _createNotebook,
              icon: const Icon(Icons.check),
              label: const Text("Create Notebook"),
              style: FilledButton.styleFrom(backgroundColor: _selectedColor),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getPreviewDecoration(String pattern, Color color) {
    switch (pattern) {
      case 'ocean':
        return BoxDecoration(
          gradient: LinearGradient(colors: [color, Colors.blue.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(4),
        );
      case 'sunset':
        return BoxDecoration(
          gradient: LinearGradient(colors: [color, Colors.orangeAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(4),
        );
      case 'galaxy':
        return BoxDecoration(
          color: Colors.black,
          gradient: RadialGradient(colors: [color.withValues(alpha: 0.6), Colors.black], radius: 0.8),
          borderRadius: BorderRadius.circular(4),
        );
      case 'forest':
        return BoxDecoration(
          gradient: LinearGradient(colors: [color, Colors.green.shade900], begin: Alignment.bottomLeft, end: Alignment.topRight),
          borderRadius: BorderRadius.circular(4),
        );
      default:
        return BoxDecoration(color: color, borderRadius: BorderRadius.circular(4));
    }
  }
}
