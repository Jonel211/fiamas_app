import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/image_multipart.dart';
import '../../data/models/tienda_model.dart';

class TiendaProvider extends ChangeNotifier {
  static const _prefsKey = 'tienda_seleccionada_id';

  final Dio _dio = DioClient.create();

  List<TiendaModel> _tiendas = [];
  String? _tiendaSeleccionadaId;
  bool _isLoading = false;
  String? _error;

  List<TiendaModel> get tiendas => _tiendas;
  String? get tiendaSeleccionadaId => _tiendaSeleccionadaId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TiendaModel? get tiendaSeleccionada {
    if (_tiendaSeleccionadaId == null) return null;
    final index = _tiendas.indexWhere((t) => t.id == _tiendaSeleccionadaId);
    return index == -1 ? null : _tiendas[index];
  }

  TiendaProvider() {
    _cargarTiendaSeleccionada();
  }

  /// Mensaje legible aunque el servidor responda HTML o no responda.
  String _msg(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    if (e.response?.statusCode == 413) return 'La imagen es demasiado grande.';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor.';
    }
    return fallback;
  }

  Future<void> _cargarTiendaSeleccionada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _tiendaSeleccionadaId = prefs.getString(_prefsKey);
      notifyListeners();
    } catch (e) {
      // Ignorar error silenciosamente en carga inicial
    }
  }

  Future<void> seleccionarTienda(String tiendaId) async {
    _tiendaSeleccionadaId = tiendaId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, tiendaId);
    notifyListeners();
  }

  Future<void> limpiarSeleccion() async {
    _tiendaSeleccionadaId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  /// Llamar al cerrar sesión: otro usuario no debe heredar tiendas ni selección.
  Future<void> limpiarSesion() async {
    _tiendas = [];
    _error = null;
    _isLoading = false;
    await limpiarSeleccion(); // ya notifica
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

      // Si la tienda guardada ya no existe (eliminada o de otro usuario), olvidarla.
      if (_tiendaSeleccionadaId != null &&
          !_tiendas.any((t) => t.id == _tiendaSeleccionadaId)) {
        _tiendaSeleccionadaId = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefsKey);
      }
    } on DioException catch (e) {
      _error = _msg(e, 'Error al cargar tiendas');
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
    File? logo,
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
        final tienda = TiendaModel.fromJson(response.data['tienda']);
        _tiendas.add(tienda);
        if (logo != null) {
          await _subirLogo(tienda.id, logo);
        }
      }
      return true;
    } on DioException catch (e) {
      _error = _msg(e, 'Error al crear tienda');
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
    File? logo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.put(
        '/tiendas/$tiendaId',
        data: {
          'nombre': nombre,
          'direccion': ?direccion,
          'ruc': ?ruc,
          'telefono': ?telefono,
        },
      );
      if (response.data['tienda'] != null) {
        final index = _tiendas.indexWhere((t) => t.id == tiendaId);
        if (index != -1) {
          _tiendas[index] = TiendaModel.fromJson(response.data['tienda']);
        }
      }
      if (logo != null) {
        await _subirLogo(tiendaId, logo);
      }
      return true;
    } on DioException catch (e) {
      _error = _msg(e, 'Error al actualizar tienda');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _subirLogo(String tiendaId, File file) async {
    try {
      final form = FormData.fromMap({'foto': await imageMultipart(file)});

      final response = await _dio.patch('/tiendas/$tiendaId/logo', data: form);
      if (response.data['tienda'] != null) {
        final index = _tiendas.indexWhere((t) => t.id == tiendaId);
        if (index != -1) {
          _tiendas[index] = TiendaModel.fromJson(response.data['tienda']);
        }
      }
      return true;
    } on DioException catch (e) {
      _error = _msg(e, 'No se pudo subir el logo');
      return false;
    }
  }

  Future<bool> eliminarTienda(String tiendaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.delete('/tiendas/$tiendaId');
      _tiendas.removeWhere((t) => t.id == tiendaId);
      if (_tiendaSeleccionadaId == tiendaId) {
        _tiendaSeleccionadaId = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefsKey);
      }
      return true;
    } on DioException catch (e) {
      _error = _msg(e, 'Error al eliminar tienda');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}