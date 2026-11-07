import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fiamas_app/core/network/dio_client.dart';

class ReporteService {
  final Dio _dio = DioClient.create();

  Future<Map<String, dynamic>> getResumenReportes(
    String tiendaId,
    String periodo, {
    String? clienteId,
  }) async {
    try {
      final params = <String, dynamic>{
        'tienda_id': tiendaId,
        'periodo': periodo,
        if (clienteId != null && clienteId.isNotEmpty) 'cliente_id': clienteId,
      };

      final res = await _dio.get('/reportes/resumen-app', queryParameters: params);

      final data = res.data['resumen'];
      if (data == null) {
        throw Exception('El servidor no devolvió los datos correctamente.');
      }
      final mapa = Map<String, dynamic>.from(data as Map);

      debugPrint('>>> REPORTE params=$params version=${mapa['version']} '
          'filtros=${mapa['filtros']} totalFiados=${mapa['totalFiados']} '
          'listaFiados=${(mapa['listaFiados'] as List?)?.length} '
          'listaCobros=${(mapa['listaCobros'] as List?)?.length}');

      return mapa;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        throw Exception(data['error']);
      }
      throw Exception('No se pudieron cargar los reportes.');
    }
  }
}