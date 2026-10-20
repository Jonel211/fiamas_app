import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/tienda_model.dart';

class TiendaProvider with ChangeNotifier {
  final Dio _dio = DioClient.create();

  List<TiendaModel> _tiendas = []; // ✅ Ahora es una LISTA
  bool _isLoading = false;
  String? _error;

  List<TiendaModel> get tiendas => _tiendas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarMisTiendas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/tiendas/mis-tiendas');
      if (response.data['tiendas'] != null) {
        _tiendas = (response.data['tiendas'] as List)
            .map((t) => TiendaModel.fromJson(t))
            .toList();
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al obtener las tiendas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearTienda({
    required String nombre,
    String? direccion,
    String? ruc,
    String? telefono,
    required String tenderoId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'nombre': nombre,
        'tendero_id': tenderoId,
        if (direccion != null && direccion.isNotEmpty) 'direccion': direccion,
        if (ruc != null && ruc.isNotEmpty) 'ruc': ruc,
        if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
      };

      final response = await _dio.post('/tiendas', data: body);

      if (response.data['tienda'] != null) {
        // ✅ Agrega la nueva tienda al inicio de la lista sin recargar todo
        _tiendas.insert(0, TiendaModel.fromJson(response.data['tienda']));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al crear la tienda';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTienda({
    required String tiendaId,
    required String nombre,
    String? direccion,
    String? ruc,
    String? telefono,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'nombre': nombre,
        if (direccion != null) 'direccion': direccion,
        if (ruc != null) 'ruc': ruc,
        if (telefono != null) 'telefono': telefono,
      };

      final response = await _dio.put('/tiendas/$tiendaId', data: body);

      if (response.data['tienda'] != null) {
        final tiendaActualizada = TiendaModel.fromJson(response.data['tienda']);
        final index = _tiendas.indexWhere((t) => t.id == tiendaId);
        if (index != -1) {
          _tiendas[index] = tiendaActualizada; // ✅ Actualiza en la lista
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al actualizar la tienda';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarTienda(String tiendaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.delete('/tiendas/$tiendaId');
      _tiendas.removeWhere((t) => t.id == tiendaId); // ✅ Elimina de la lista
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al eliminar la tienda';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
