import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _items = [
    (icon: Icons.home_outlined, label: 'Inicio'),
    (icon: Icons.people_outline, label: 'Fiados'),
    (icon: Icons.inventory_2_outlined, label: 'Productos'),
    (icon: Icons.help_outline, label: 'Ayuda'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.mist)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final selected = i == currentIndex;
          final item = _items[i];
          final color = selected ? AppColors.teal : AppColors.inkMuted;
          return InkWell(
            onTap: () => onTap?.call(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(
                  item.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}