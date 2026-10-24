import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/category.dart';
import 'category_style.dart';

Color _parseColor(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) return Colors.blue;
  final hex = hexColor.replaceAll('#', '');
  final fullHex = hex.length == 6 ? 'FF$hex' : hex;
  return Color(int.parse(fullHex, radix: 16));
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
  });

  final Category category;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = category;
    final parsedColor = _parseColor(c.color);

    return Opacity(
      opacity: c.activo ? 1 : 0.5,
      child: Material(
        color: parsedColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: selected
              ? const BorderSide(color: AppColors.teal, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CategoryStyle.iconOf(c.icono ?? 'bag'),
                  size: 32,
                  color: parsedColor,
                ),
                const SizedBox(height: 10),
                Text(
                  c.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
