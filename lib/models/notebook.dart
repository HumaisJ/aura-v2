import 'package:flutter/material.dart';
import 'sticker_data.dart';

class Notebook {
  final String id;
  final String title;
  final Color color;
  final String pattern; // NEW: Stores 'solid', 'gradient', 'stars', etc.
  final List<String> pages;
  final Map<String, List<StickerData>> stickers;

  Notebook({
    required this.id,
    required this.title,
    required this.color,
    this.pattern = 'solid', // Default
    required this.pages,
    Map<String, List<StickerData>>? stickers,
  }) : stickers = stickers ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.toARGB32(),
      'pattern': pattern,
      'pages': pages,
      'stickers': stickers.map((key, value) => MapEntry(key, value.map((s) => s.toJson()).toList())),
    };
  }

  factory Notebook.fromJson(Map<String, dynamic> json) {

     Map<String, List<StickerData>> loadedStickers = {};
    if (json['stickers'] != null) {
      final Map<String, dynamic> rawStickers = json['stickers'];
      rawStickers.forEach((key, value) {
        final list = (value as List).map((i) => StickerData.fromJson(i)).toList();
        loadedStickers[key] = list;
      });
    }

    return Notebook(
      id: json['id'],
      title: json['title'],
      color: Color(json['color']),
      pattern: json['pattern'] ?? 'solid',
      pages: List<String>.from(json['pages']),
      stickers: loadedStickers,
    );
  }
}
