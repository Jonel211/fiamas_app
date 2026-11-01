import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class StoreSummary {
  StoreSummary({
    required this.tiendaId,
    required this.nombre,
    required this.montoPorCobrar,
    required this.fiadosPendientes,
    required this.totalClientes,
    required this.totalProductos,
    required this.totalCategorias,
    required this.productosStockBajo,
    required this.alertasPendientes,
    required this.cobradoEsteMes, 
  });

  final String tiendaId;
  final String nombre;
  final double montoPorCobrar;
  final int fiadosPendientes;
  final int totalClientes;
  final int totalProductos;
  final int totalCategorias;
  final int productosStockBajo;
  final int alertasPendientes;
  final double cobradoEsteMes; 

  factory StoreSummary.fromJson(Map<String, dynamic> j) {
    int i(String k) => (j[k] as num?)?.toInt() ?? 0;
    return StoreSummary(
      tiendaId: j['tienda_id'].toString(),
      nombre: (j['tienda_nombre'] ?? '').toString(),
      montoPorCobrar: (j['monto_por_cobrar'] as num?)?.toDouble() ?? 0,
      fiadosPendientes: i('fiados_pendientes'),
      totalClientes: i('total_clientes'),
      totalProductos: i('total_productos'),
      totalCategorias: i('total_categorias'),
      productosStockBajo: i('productos_stock_bajo'),
      alertasPendientes: i('alertas_pendientes'),
      cobradoEsteMes: (j['cobrado_este_mes'] as num?)?.toDouble() ?? 0, 
    );
  }
}

class MovimientoReciente {
  final String id;
  final String tipo; 
  final String clienteNombre;
  final double monto;
  final DateTime fecha;
  final String detalle;

  MovimientoReciente({
    required this.id,
    required this.tipo,
    required this.clienteNombre,
    required this.monto,
    required this.fecha,
    required this.detalle,
  });

  factory MovimientoReciente.fromJson(Map<String, dynamic> json) {
    // Se convierte la fecha a la hora local del dispositivo con .toLocal()
    final fechaUtc = DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now();
    
    return MovimientoReciente(
      id: json['id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'fiado',
      clienteNombre: json['cliente_nombre']?.toString() ?? 'Cliente',
      monto: double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      fecha: fechaUtc.toLocal(), 
      detalle: json['detalle']?.toString() ?? '',
    );
  }
}

class DashboardService {
  final Dio _dio = DioClient.create();

  /// GET /tiendas/resumen?tienda_id=...
  Future<StoreSummary> getResumen(String tiendaId) async {
    try {
      final res = await _dio.get(
        '/tiendas/resumen',
        queryParameters: {'tienda_id': tiendaId},
      );
      return StoreSummary.fromJson(
        Map<String, dynamic>.from(res.data['resumen'] as Map),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        throw Exception(data['error']);
      }
      throw Exception('No se pudo cargar el resumen de la tienda.');
    }
  }

  /// GET /tiendas/movimientos-recientes?tienda_id=...
  Future<List<MovimientoReciente>> getMovimientosRecientes(String tiendaId) async {
    try {
      final res = await _dio.get(
        '/tiendas/movimientos-recientes',
        queryParameters: {'tienda_id': tiendaId},
      );
      
      final List<dynamic> data = res.data['movimientos'] ?? [];
      return data.map((json) => MovimientoReciente.fromJson(json)).toList();
      
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        throw Exception(data['error']);
      }
      throw Exception('No se pudieron cargar los movimientos recientes.');
    }
  }
}