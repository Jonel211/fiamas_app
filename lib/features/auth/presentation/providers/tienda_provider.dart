import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/tienda_model.dart';

class TiendaProvider extends ChangeNotifier {
  final Dio _dio = DioClient.create();

  List<TiendaModel> _tiendas = [];
  String? _tiendaSeleccionadaId;
  bool _isLoading = false;
  String? _error;

  List<TiendaModel> get tiendas => _tiendas;
  String? get tiendaSeleccionadaId => _tiendaSeleccionadaId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TiendaProvider() {
    _cargarTiendaSeleccionada();
  }

  Future<void> _cargarTiendaSeleccionada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _tiendaSeleccionadaId = prefs.getString('tienda_seleccionada_id');
      notifyListeners();
    } catch (e) {
      // Ignorar error silenciosamente en carga inicial
    }
  }

  Future<void> seleccionarTienda(String tiendaId) async {
    _tiendaSeleccionadaId = tiendaId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tienda_seleccionada_id', tiendaId);
    notifyListeners();
  }

  Future<void> limpiarSeleccion() async {
    _tiendaSeleccionadaId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tienda_seleccionada_id');
    notifyListeners();
  }

  Future<void> cargarMisTiendas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/tiendas/mis-tiendas');
      if (response.data['tiendas'] != null) {
        _tiendas = (response.data['tiendas'] as List)
            .map((json) => TiendaModel.fromJson(json))
            .toList();
      } else {
        _tiendas = [];
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al cargar tiendas';
    } catch (e) {
      _error = 'Error desconocido: $e';
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
      final response = await _dio.post(
        '/tiendas',
        data: {
          'nombre': nombre,
          'tendero_id': tenderoId,
          if (direccion != null && direccion.isNotEmpty) 'direccion': direccion,
          if (ruc != null && ruc.isNotEmpty) 'ruc': ruc,
          if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        },
      );
      if (response.data['tienda'] != null) {
        _tiendas.add(TiendaModel.fromJson(response.data['tienda']));
      }
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al crear tienda';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final response = await _dio.put(
        '/tiendas/$tiendaId',
        data: {
          'nombre': nombre,
          if (direccion != null) 'direccion': direccion,
          if (ruc != null) 'ruc': ruc,
          if (telefono != null) 'telefono': telefono,
        },
      );
      if (response.data['tienda'] != null) {
        final index = _tiendas.indexWhere((t) => t.id == tiendaId);
        if (index != -1)
          _tiendas[index] = TiendaModel.fromJson(response.data['tienda']);
      }
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al actualizar tienda';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarTienda(String tiendaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.delete('/tiendas/$tiendaId');
      _tiendas.removeWhere((t) => t.id == tiendaId);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al eliminar tienda';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
