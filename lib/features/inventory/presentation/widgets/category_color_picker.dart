import 'package:flutter/material.dart';
import 'category_style.dart';

/// Parrilla de círculos de colores. El elegido muestra un check.
/// Usa Wrap para soportar muchos colores en varias filas.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({super.key, required this.selected, required this.onChanged});

  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in CategoryStyle.colors)
          Material(
            color: color,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onChanged(color),
              child: SizedBox(
                width: 40,
                height: 40,
                child: color == selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            ),
          ),
      ],
    );
  }
}