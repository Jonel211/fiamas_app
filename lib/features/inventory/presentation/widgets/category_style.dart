import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';

/// Colores e íconos que se pueden elegir para una categoría.
///
/// Los íconos viven en [CategoryIcons]. Esta clase los expone con la API
/// anterior y traduce las claves viejas ('bag', 'food', ...) a las nuevas,
/// para que las categorías ya guardadas sigan viéndose bien.
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

  /// Clave antigua -> clave nueva de [CategoryIcons].
  static const Map<String, String> legacyKeys = {
    'bag': 'bolsos',
    'food': 'comida',
    'coffee': 'cafe',
    'laptop': 'computacion',
    'shirt': 'ropa',
    'tool': 'herramientas',
    'health': 'salud',
    'home': 'hogar',
  };

  /// Todos los íconos disponibles (clave -> ícono).
  static Map<String, IconData> get icons => CategoryIcons.all;

  /// Devuelve siempre una clave válida de [CategoryIcons].
  /// - null o vacía -> 'general'
  /// - clave antigua -> su equivalente nuevo
  /// - clave desconocida -> 'general'
  static String normalizeKey(String? key) {
    if (key == null || key.isEmpty) return 'general';
    if (CategoryIcons.all.containsKey(key)) return key;
    final mapped = legacyKeys[key];
    if (mapped != null && CategoryIcons.all.containsKey(mapped)) return mapped;
    return 'general';
  }

  /// Ícono para una clave guardada (nueva o antigua).
  static IconData iconOf(String? key) =>
      CategoryIcons.resolve(normalizeKey(key));
}