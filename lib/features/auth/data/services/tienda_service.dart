import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/tienda_model.dart';

class TiendaService {
  final Dio _dio = DioClient.create();

  Future<TiendaModel?> getMiTienda() async {
    try {
      final response = await _dio.get('/tiendas/mi-tienda');
      if (response.data['tienda'] != null) {
        return TiendaModel.fromJson(response.data['tienda']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Error al obtener la tienda',
      );
    }
  }

  Future<TiendaModel> crearTienda({
    required String nombre,
    String? direccion,
    String? ruc,
    String? telefono,
  }) async {
    try {
      final response = await _dio.post(
        '/tiendas',
        data: {
          'nombre': nombre,
          if (direccion != null) 'direccion': direccion,
          if (ruc != null) 'ruc': ruc,
          if (telefono != null) 'telefono': telefono,
        },
      );
      return TiendaModel.fromJson(response.data['tienda']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error al crear la tienda');
    }
  }

  Future<TiendaModel> actualizarTienda(
    String tiendaId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await _dio.put('/tiendas/$tiendaId', data: datos);
      return TiendaModel.fromJson(response.data['tienda']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error al actualizar');
    }
  }

  Future<void> eliminarTienda(String tiendaId) async {
    try {
      await _dio.delete('/tiendas/$tiendaId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error al eliminar');
    }
  }
}

final tiendaService = TiendaService();
