import 'category.dart';
import 'sale_unit.dart';

class Product {
  final String id;
  final String tiendaId;
  final String categoriaId;
  final String nombre;
  final String? descripcion;
  final String? codigoBarras;
  final SaleUnit tipoVenta;
  final String unidadMedida;
  final double precioVenta;
  final bool activo;
  final String? imagenUrl;
  final Category? categoria;
  final int? stockActual;

  Product({
    required this.id,
    required this.tiendaId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.codigoBarras,
    this.tipoVenta = SaleUnit.unit,
    this.unidadMedida = 'unidad',
    required this.precioVenta,
    this.activo = true,
    this.imagenUrl,
    this.categoria,
    this.stockActual,
  });

  bool get hasLowStock => stockActual != null && stockActual! <= 10;

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ PARSEO SEGURO DE PRECIO (maneja String, double, int, null)
    double precioParseado = 0.0;
    final precioRaw = json['precio_venta'];
    if (precioRaw is double) {
      precioParseado = precioRaw;
    } else if (precioRaw is int) {
      precioParseado = precioRaw.toDouble();
    } else if (precioRaw is String) {
      precioParseado = double.tryParse(precioRaw) ?? 0.0;
    }

    // ✅ PARSEO SEGURO DE STOCK
    int? stockParseado;
    final stockRaw = json['stock_actual'];
    if (stockRaw is int) {
      stockParseado = stockRaw;
    } else if (stockRaw is double) {
      stockParseado = stockRaw.toInt();
    } else if (stockRaw is String) {
      stockParseado = int.tryParse(stockRaw);
    }

    return Product(
      id: json['id']?.toString() ?? '',
      tiendaId: json['tienda_id']?.toString() ?? '',
      categoriaId: json['categoria_id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      codigoBarras: json['codigo_barras']?.toString(),
      tipoVenta: SaleUnit.fromString(
        json['tipo_venta']?.toString() ?? 'unidad',
      ),
      unidadMedida: json['unidad_medida']?.toString() ?? 'unidad',
      precioVenta: precioParseado,
      activo:
          json['activo'] == true ||
          json['activo'] == 1 ||
          json['activo'] == 'true',
      imagenUrl: json['imagen_url']?.toString(),
      categoria: json['categoria'] != null
          ? Category.fromJson(json['categoria'])
          : null,
      stockActual: stockParseado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tienda_id': tiendaId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo_barras': codigoBarras,
      'tipo_venta': tipoVenta.value,
      'unidad_medida': unidadMedida,
      'precio_venta': precioVenta,
      'activo': activo,
      'imagen_url': imagenUrl,
    };
  }
}
