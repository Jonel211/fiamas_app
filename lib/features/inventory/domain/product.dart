class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
  });

  final String id;
  final String name;
  final String category;
  final double price;

  /// Nombre del ícono representativo (por ahora sustituye a una foto
  /// real del producto).
  final IconName icon;
}

/// Set reducido de íconos por tipo de producto, hasta tener fotos reales.
enum IconName { bottle, cookie, bread, generic }