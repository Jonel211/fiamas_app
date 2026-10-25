import 'category_model.dart';

class Product {
  final String id;
  final String tiendaId;
  final String categoriaId;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final String? codigoBarras;
  final String tipoVenta;
  final String unidadMedida;
  final double precioVenta;
  final double? stockActual;
  final double? stockMinimo;
  final bool activo;
  final Category?
  categoria; // Incluye la categoría si el backend la devuelve en el include

  Product({
    required this.id,
    required this.tiendaId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    this.codigoBarras,
    this.tipoVenta = 'unidad',
    this.unidadMedida = 'unidad',
    required this.precioVenta,
    this.stockActual,
    this.stockMinimo,
    this.activo = true,
    this.categoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      tiendaId: json['tienda_id'] ?? '',
      categoriaId: json['categoria_id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'],
      codigoBarras: json['codigo_barras'],
      tipoVenta: json['tipo_venta'] ?? 'unidad',
      unidadMedida: json['unidad_medida'] ?? 'unidad',
      precioVenta:
          double.tryParse(json['precio_venta']?.toString() ?? '0') ?? 0.0,
      stockActual: json['stock_actual'] != null
          ? double.tryParse(json['stock_actual'].toString())
          : null,
      stockMinimo: json['stock_minimo'] != null
          ? double.tryParse(json['stock_minimo'].toString())
          : null,
      activo: json['activo'] ?? true,
      categoria: json['categoria'] != null
          ? Category.fromJson(json['categoria'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tienda_id': tiendaId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'codigo_barras': codigoBarras,
      'tipo_venta': tipoVenta,
      'unidad_medida': unidadMedida,
      'precio_venta': precioVenta,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'activo': activo,
    };
  }

  Product copyWith({
    String? id,
    String? tiendaId,
    String? categoriaId,
    String? nombre,
    String? descripcion,
    String? imagenUrl,
    String? codigoBarras,
    String? tipoVenta,
    String? unidadMedida,
    double? precioVenta,
    double? stockActual,
    double? stockMinimo,
    bool? activo,
    Category? categoria,
  }) {
    return Product(
      id: id ?? this.id,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      precioVenta: precioVenta ?? this.precioVenta,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      activo: activo ?? this.activo,
      categoria: categoria ?? this.categoria,
    );
  }
}
