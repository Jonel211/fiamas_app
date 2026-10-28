import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/image_multipart.dart';
import '../../data/models/tendero_model.dart';

class AuthService {
  final Dio _dio = DioClient.create();
  final _storage = const FlutterSecureStorage();

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

  Future<Map<String, dynamic>> registroTendero({
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
    String? nombreTienda,
  }) async {
    try {
      final body = {
        'dni': dni,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
        'password': password,
        'nombre_tienda': ?nombreTienda,
      };

      final response = await _dio.post('/tenderos', data: body);

      if (response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al registrar el tendero'));
    }
  }

  Future<Map<String, dynamic>> login({
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'telefono': telefono, 'password': password},
      );

      if (response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Credenciales incorrectas'));
    }
  }

  Future<TenderoModel> getPerfil() async {
    try {
      final response = await _dio.get('/tenderos/perfil');
      return TenderoModel.fromJson(response.data['tendero']);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener perfil'));
    }
  }

  // Actualizar perfil del tendero
  Future<TenderoModel> updatePerfil({
    required String nombres,
    required String apellidos,
    required String telefono,
  }) async {
    try {
      await _dio.put(
        '/tenderos/perfil',
        data: {
          'nombres': nombres.trim(),
          'apellidos': apellidos.trim(),
          'telefono': telefono.trim(),
        },
      );
      return await getPerfil();
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al actualizar perfil'));
    }
  }

  // Subir foto de perfil del tendero
  Future<TenderoModel> subirFotoPerfil(File file) async {
    try {
      final form = FormData.fromMap({'foto': await imageMultipart(file)});

      await _dio.patch('/tenderos/perfil/foto', data: form);
      return await getPerfil();
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al subir la foto'));
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}

final authService = AuthService();