import 'package:flutter/material.dart';
import '../models/notebook.dart';
import '../models/sticker_data.dart';
import '../widgets/draggable_sticker.dart';

class NotebookContentPage extends StatefulWidget {
  final Notebook notebook;

  const NotebookContentPage({super.key, required this.notebook});

  @override
  State<NotebookContentPage> createState() => _NotebookContentPageState();
}

class _NotebookContentPageState extends State<NotebookContentPage> {
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _addPage() {
    if (widget.notebook.pages.length >= 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notebook Full (Max 50 Pages)")),
      );
      return;
    }
    setState(() {
      widget.notebook.pages.add('');
    });
    // Scroll to the new page after a slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _pageController.animateToPage(
        widget.notebook.pages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Helper to add sticker
  void _addSticker(String assetPath) {
    int pageIndex = _pageController.page?.round() ?? 0;
    String key = pageIndex.toString();

    final newSticker = StickerData(
      id: DateTime.now().toString(),
      assetPath: assetPath,
    );

    setState(() {
      if (!widget.notebook.stickers.containsKey(key)) {
        widget.notebook.stickers[key] = [];
      }
      widget.notebook.stickers[key]!.add(newSticker);
    });
  }

  void _deleteSticker(String key, StickerData sticker) {
    setState(() {
      widget.notebook.stickers[key]?.remove(sticker);
    });
  }

  // Helper to pick sticker
  void _showStickerPicker() {
    final stickers = [
      'bandage.png', 'birdie.png', 'bow.png', 'cam.png', 'cat.png',
      'cd.png', 'chat.png', 'clouds.png', 'comp.png', 'computer.png',
      'crystal.png', 'cute.png', 'dream.png', 'ew.png', 'fireghost.png',
      'flower.png', 'flowerframe.png', 'flowerpixie.png', 'game.png', 'ghost.png',
      'heart.png', 'heart2.png', 'load.png', 'lostlove.png', 'message.png',
      'milk.png', 'nebula.png', 'nomore.png', 'over.png', 'pill.png',
      'pills.png', 'plane.png', 'pocky.png', 'pokemon.png', 'ring.png',
      'sea.png', 'spido.png', 'stars.png', 'sun.png', 'trees.png',
      'trying.png', 'willya.png', 'st4.png', 'st1.png', 'st2.png', 'st3.png',
      'fr1.png', 'fr2.png', 'fr3.png', 'fr4.png'
    ];
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 5,
          children: stickers.map((s) => GestureDetector(
            onTap: () {
              _addSticker('assets/stickers/$s');
              Navigator.pop(context);
            },
            child: Image.asset('assets/stickers/$s'),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: widget.notebook.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            tooltip: "Add Sticker",
            onPressed: _showStickerPicker,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.notebook.pages.length,
        itemBuilder: (context, index) {
          // Get stickers for this page
          final pageStickers = widget.notebook.stickers[index.toString()] ?? [];

          return Stack(
            children: [
              // LAYER 1: TEXT EDITOR
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("Page ${index + 1}", style: const TextStyle(color: Colors.grey)),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: widget.notebook.pages[index]),
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: "Start writing...",
                              border: InputBorder.none,
                            ),
                            onChanged: (text) {
                              widget.notebook.pages[index] = text;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // LAYER 2: STICKERS
              ...pageStickers.map((sticker) {
                 String key = index.toString(); 
                 return DraggableSticker(
                  data: sticker,
                  onUpdate: (updated) {
                    // Passed by ref
                  },
                  onDelete: () {
                    _deleteSticker(key, sticker);
                  },
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPage,
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
