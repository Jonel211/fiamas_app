import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/category.dart';
import 'category_style.dart';

/// Cuadro de la lista: ícono y nombre, teñido con el color de la categoría.
/// Las categorías inactivas se ven apagadas.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, required this.onTap, this.selected = false});

  final Category category;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = category;

    return Opacity(
      opacity: c.active ? 1 : 0.5,
      child: Material(
        color: c.color.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: selected ? const BorderSide(color: AppColors.teal, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(CategoryStyle.iconOf(c.iconKey), size: 32, color: c.color),
              const SizedBox(height: 10),
              Text(c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
            ]),
          ),
        ),
      ),
    );
  }
}