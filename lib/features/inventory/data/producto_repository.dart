import '../../../core/services/api_service.dart';

class ProductoRepository {
  /// GET /api/productos/tienda/:tienda_id
  Future<Map<String, dynamic>> obtenerProductosPorTienda(
    String tiendaId, {
    String? busca,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String>[];
    if (busca != null && busca.isNotEmpty) {
      query.add('busca=${Uri.encodeComponent(busca)}');
    }
    query.add('page=$page');
    query.add('limit=$limit');
    final qs = query.isNotEmpty ? '?${query.join('&')}' : '';
    return await ApiService.get('/productos/tienda/$tiendaId$qs');
  }

  /// POST /api/productos
  Future<Map<String, dynamic>> crearProducto({
    required String tiendaId,
    required String nombre,
    required double precioVenta,
    double? precioCompra,
    int? stockActual,
    int? stockMinimo,
    String? codigoBarras,
    String? descripcion,
    String? unidadMedida,
  }) async {
    return await ApiService.post('/productos', {
      'tienda_id': tiendaId,
      'nombre': nombre,
      'precio_venta': precioVenta,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (codigoBarras != null && codigoBarras.isNotEmpty)
        'codigo_barras': codigoBarras,
      if (descripcion != null && descripcion.isNotEmpty)
        'descripcion': descripcion,
      if (unidadMedida != null) 'unidad_medida': unidadMedida,
    });
  }

  /// POST /api/productos/:id/stock  (entrada o salida)
  Future<Map<String, dynamic>> actualizarStock({
    required String productoId,
    required int cantidad,
    required String tipo, // 'entrada' o 'salida'
  }) async {
    return await ApiService.post('/productos/$productoId/stock', {
      'cantidad': cantidad,
      'tipo': tipo,
    });
  }
}
