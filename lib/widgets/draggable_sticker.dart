import 'package:flutter/material.dart';
import '../models/sticker_data.dart';
import 'dart:math';

class DraggableSticker extends StatefulWidget {
  final StickerData data;
  final Function(StickerData) onUpdate;
  final VoidCallback onDelete;

  const DraggableSticker({super.key, required this.data, required this.onUpdate, required this.onDelete });

  @override
  State<DraggableSticker> createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<DraggableSticker> {
  late double x;
  late double y;
  late double scale;
  late double rotation;

  // Temp values during gesture
  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  @override
  void initState() {
    super.initState();
    x = widget.data.x;
    y = widget.data.y;
    scale = widget.data.scale;
    rotation = widget.data.rotation;
  }

   @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        // 1. Handle Movement, Scale, and Rotation
        onScaleStart: (details) {
          _baseScale = scale;
          _baseRotation = rotation;
        },
        onScaleUpdate: (details) {
          setState(() {
            // Move (dx/dy)
            x += details.focalPointDelta.dx;
            y += details.focalPointDelta.dy;

            // Scale (clamped to keep stickers reasonable)
            scale = (_baseScale * details.scale).clamp(0.5, 5.0);

            // Rotation (radians)
            rotation = _baseRotation + details.rotation;
          });
        },
        onScaleEnd: (details) {
          // Save final state
          widget.data.x = x;
          widget.data.y = y;
          widget.data.scale = scale;
          widget.data.rotation = rotation;
          widget.onUpdate(widget.data);
        },
        // 2. Handle Deletion (Double Tap)
        onDoubleTap: widget.onDelete,
        
        // The Sticker Itself
        child: Transform(
          transform: Matrix4.identity()
            ..scale(scale)
            ..rotateZ(rotation),
          alignment: Alignment.center,
          child: Image.asset(
            widget.data.assetPath,
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}
