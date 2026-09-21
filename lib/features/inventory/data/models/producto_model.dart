class ProductoModel {
  final String id;
  final String tiendaId;
  final String? categoriaId;
  final String nombre;
  final String? descripcion;
  final String? codigoBarras;
  final double precioCompra;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;
  final String unidadMedida;
  final bool activo;
  final String? categoriaNombre;

  ProductoModel({
    required this.id,
    required this.tiendaId,
    this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.codigoBarras,
    required this.precioCompra,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidadMedida,
    required this.activo,
    this.categoriaNombre,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'] ?? '',
      tiendaId: json['tienda_id'] ?? '',
      categoriaId: json['categoria_id'],
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      codigoBarras: json['codigo_barras'],
      precioCompra:
          double.tryParse(json['precio_compra']?.toString() ?? '0') ?? 0,
      precioVenta:
          double.tryParse(json['precio_venta']?.toString() ?? '0') ?? 0,
      stockActual: (json['stock_actual'] ?? 0) as int,
      stockMinimo: (json['stock_minimo'] ?? 0) as int,
      unidadMedida: json['unidad_medida'] ?? 'unidad',
      activo: json['activo'] ?? true,
      categoriaNombre: json['categoria']?['nombre'] as String?,
    );
  }
}
