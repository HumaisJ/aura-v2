class StickerData {
  String id;
  String assetPath;
  double x;
  double y;
  double scale;
  double rotation;

  StickerData({
    required this.id,
    required this.assetPath,
    this.x = 100,
    this.y = 100,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'asset': assetPath, 'x': x, 'y': y, 'scale': scale, 'rot': rotation
  };

  factory StickerData.fromJson(Map<String, dynamic> json) {
    return StickerData(
      id: json['id'],
      assetPath: json['asset'],
      x: json['x'],
      y: json['y'],
      scale: json['scale'],
      rotation: json['rot'],
    );
  }
}
