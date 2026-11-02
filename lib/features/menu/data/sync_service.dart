import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'sync_preferences.dart';

class SyncService {
  SyncService({Dio? dio, SyncPreferences? preferences})
    : _dio = dio ?? DioClient.create(),
      _preferences = preferences ?? SyncPreferences();

  final Dio _dio;
  final SyncPreferences _preferences;

  Future<bool> sincronizar(String tiendaId) async {
    if (!await _preferences.isSyncActiva()) return false;

    try {
      await Future.wait([
        _dio.get('/clientes', queryParameters: {'tienda_id': tiendaId}),
        _dio.get('/productos/tienda/$tiendaId'),
        _dio.get('/fiados', queryParameters: {'tienda_id': tiendaId}),
      ]);
      await _preferences.setUltimaSincronizacion(DateTime.now());
      return true;
    } catch (_) {
      return false;
    }
  }
}
