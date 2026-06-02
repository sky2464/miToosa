import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'puzzle.dart';

/// Color palette for shapes in puzzles.
enum ShapeColor {
  purple(Color(0xFF7B2CBF), 'Purple'),
  blue(Color(0xFF3A86FF), 'Blue'),
  teal(Color(0xFF00B4D8), 'Teal'),
  orange(Color(0xFFFF8800), 'Orange'),
  pink(Color(0xFFFF006E), 'Pink'),
  green(Color(0xFF06D6A0), 'Green'),
  red(Color(0xFFEF233C), 'Red'),
  yellow(Color(0xFFFFBE0B), 'Yellow');

  final Color value;
  final String label;
  const ShapeColor(this.value, this.label);
}

/// Fill style for shapes.
enum ShapeFill { filled, outlined, striped }

/// A single shape element with shape type, color, and fill.
class ShapeItem extends Equatable {
  final Shape shape;
  final ShapeColor color;
  final ShapeFill fill;

  const ShapeItem({
    required this.shape,
    this.color = ShapeColor.purple,
    this.fill = ShapeFill.filled,
  });

  ShapeItem copyWith({Shape? shape, ShapeColor? color, ShapeFill? fill}) {
    return ShapeItem(
      shape: shape ?? this.shape,
      color: color ?? this.color,
      fill: fill ?? this.fill,
    );
  }

  @override
  List<Object?> get props => [shape, color, fill];
}
