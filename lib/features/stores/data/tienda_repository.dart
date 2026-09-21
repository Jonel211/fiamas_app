import '../../../core/services/api_service.dart';

class TiendaRepository {
  /// Obtiene todas las tiendas del tendero autenticado
  /// GET /api/tiendas/mis-tiendas
  Future<Map<String, dynamic>> obtenerMisTiendas() async {
    return await ApiService.get('/tiendas/mis-tiendas');
  }

  /// Crea una nueva tienda
  /// POST /api/tiendas
  Future<Map<String, dynamic>> crearTienda({
    required String nombre,
    String? direccion,
    String? ruc,
    String? telefono,
  }) async {
    return await ApiService.post('/tiendas', {
      'nombre': nombre,
      if (direccion != null && direccion.isNotEmpty) 'direccion': direccion,
      if (ruc != null && ruc.isNotEmpty) 'ruc': ruc,
      if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
    });
  }
}
