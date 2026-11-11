import 'package:flutter/material.dart';
import 'category_style.dart';

/// Fila de círculos de colores. El elegido muestra un check.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({super.key, required this.selected, required this.onChanged});

  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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