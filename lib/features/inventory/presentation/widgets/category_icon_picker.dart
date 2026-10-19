import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'category_style.dart';

/// Cuadrícula de íconos (4 por fila). El elegido se pinta en teal.
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({super.key, required this.selectedKey, required this.onChanged});

  final String selectedKey;
  final ValueChanged<String> onChanged;

  static const int _perRow = 4;

  @override
  Widget build(BuildContext context) {
    final entries = CategoryStyle.icons.entries.toList();

    return Column(children: [
      for (int start = 0; start < entries.length; start += _perRow) ...[
        if (start > 0) const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final e in entries.skip(start).take(_perRow))
              _IconCell(
                icon: e.value,
                selected: e.key == selectedKey,
                onTap: () => onChanged(e.key),
              ),
          ],
        ),
      ],
    ]);
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({required this.icon, required this.selected, required this.onTap});

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.teal : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, size: 24, color: selected ? Colors.white : AppColors.inkMuted),
        ),
      ),
    );
  }
}