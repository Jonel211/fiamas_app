import 'package:flutter/material.dart';

/// Categoría de productos de la tienda.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.iconKey,
    this.description = '',
    this.active = true,
  });

  final String id;
  final String name;
  final String description;

  /// Color de identificación (uno de CategoryStyle.colors).
  final Color color;

  /// Clave del ícono (una de las de CategoryStyle.icons), ej: 'coffee'.
  /// Se guarda la clave y no el IconData para poder enviarla a la API.
  final String iconKey;
  final bool active;
}