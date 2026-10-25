/// Forma en que se vende un producto.
enum SaleUnit {
  unit('unidad'),
  kilo('kg'),
  gram('g'),
  liter('L'),
  milliliter('ml');

  const SaleUnit(this.value);
  final String value;

  String get label {
    switch (this) {
      case SaleUnit.unit:
        return 'Unidad';
      case SaleUnit.kilo:
        return 'Kilo (kg)';
      case SaleUnit.gram:
        return 'Gramo (g)';
      case SaleUnit.liter:
        return 'Litro (L)';
      case SaleUnit.milliliter:
        return 'Mililitro (ml)';
    }
  }

  factory SaleUnit.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'unidad':
        return SaleUnit.unit;
      case 'kg':
        return SaleUnit.kilo;
      case 'g':
        return SaleUnit.gram;
      case 'L':
        return SaleUnit.liter;
      case 'ml':
        return SaleUnit.milliliter;
      default:
        return SaleUnit.unit;
    }
  }
}
