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
  final String? clienteId;
  final String tipo;
  final String clienteNombre;
  final String? clienteFotoUrl;
  final double monto;
  final DateTime fecha;
  final String detalle;

  MovimientoReciente({
    required this.id,
    this.clienteId,
    required this.tipo,
    required this.clienteNombre,
    this.clienteFotoUrl,
    required this.monto,
    required this.fecha,
    required this.detalle,
  });

  factory MovimientoReciente.fromJson(Map<String, dynamic> json) {
    // Se convierte la fecha a la hora local del dispositivo con .toLocal()
    final fechaUtc =
        DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now();

    return MovimientoReciente(
      id: json['id']?.toString() ?? '',
      clienteId: _clienteId(json),
      tipo: json['tipo']?.toString() ?? 'fiado',
      clienteNombre: json['cliente_nombre']?.toString() ?? 'Cliente',
      clienteFotoUrl: _clienteFotoUrl(json),
      monto: double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      fecha: fechaUtc.toLocal(),
      detalle: json['detalle']?.toString() ?? '',
    );
  }

  static String? _clienteId(Map<String, dynamic> json) {
    final direct = json['cliente_id'];
    if (direct != null) return direct.toString();

    final cliente = json['cliente'];
    if (cliente is Map) {
      final id = Map<String, dynamic>.from(cliente)['id'];
      if (id != null) return id.toString();
    }
    return null;
  }

  static String? _clienteFotoUrl(Map<String, dynamic> json) {
    final cliente = json['cliente'];
    if (cliente is Map) {
      final nested = _firstNonEmpty(
        Map<String, dynamic>.from(cliente),
        _fotoKeys,
      );
      if (nested != null) return nested;
    }

    return _firstNonEmpty(json, _fotoKeys);
  }

  static const _fotoKeys = <String>[];

  static String? _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
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
  Future<List<MovimientoReciente>> getMovimientosRecientes(
    String tiendaId,
  ) async {
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
