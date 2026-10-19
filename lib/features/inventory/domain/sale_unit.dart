/// Forma en que se vende un producto.
enum SaleUnit {
  unit('Unidad'),
  kilo('Kilo (kg)');

  const SaleUnit(this.label);
  final String label;
}