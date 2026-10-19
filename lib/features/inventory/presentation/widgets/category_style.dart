import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Colores e íconos que se pueden elegir para una categoría.
class CategoryStyle {
  CategoryStyle._();

  /// Colores de identificación (son datos del usuario, no del tema).
  static const List<Color> colors = [
    AppColors.ink,
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFA855F7),
  ];

  /// Clave → ícono. El orden es el que se muestra en el selector.
  static const Map<String, IconData> icons = {
    'bag': Icons.shopping_bag_outlined,
    'food': Icons.restaurant,
    'coffee': Icons.coffee_outlined,
    'laptop': Icons.laptop_outlined,
    'shirt': Icons.checkroom_outlined,
    'tool': Icons.build_outlined,
    'health': Icons.monitor_heart_outlined,
    'home': Icons.home_outlined,
  };

  static IconData iconOf(String key) => icons[key] ?? Icons.category_outlined;
}