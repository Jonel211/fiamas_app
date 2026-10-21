import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_client.dart'; // Ajusta si tu ruta es diferente
import '../../data/models/tendero_model.dart';

class AuthService {
  final Dio _dio = DioClient.create();
  final _storage = const FlutterSecureStorage();

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
        if (nombreTienda != null) 'nombre_tienda': nombreTienda,
      };

      final response = await _dio.post('/tenderos', data: body);

      if (response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Error al registrar el tendero',
      );
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
      throw Exception(e.response?.data['error'] ?? 'Credenciales incorrectas');
    }
  }

  Future<TenderoModel> getPerfil() async {
    try {
      final response = await _dio.get('/tenderos/perfil');
      return TenderoModel.fromJson(response.data['tendero']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error al obtener perfil');
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
