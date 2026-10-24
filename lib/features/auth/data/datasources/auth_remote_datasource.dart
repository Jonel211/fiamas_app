import 'package:dio/dio.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  // Base URL ya configurada en el Dio

  Future<Map<String, dynamic>> login({
    required String identificador,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'identificador': identificador, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> registerTendero({
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
    required String nombreTienda,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/tendero',
        data: {
          'dni': dni,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'password': password,
          'nombre_tienda': nombreTienda,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> registerCliente({
    required String telefono,
    required String nombres,
    required String apellidos,
    String? password,
    String? direccion,
  }) async {
    try {
      final data = {
        'telefono': telefono,
        'nombres': nombres,
        'apellidos': apellidos,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      if (direccion != null && direccion.isNotEmpty) {
        data['direccion'] = direccion;
      }

      final response = await _dio.post('/auth/register/cliente', data: data);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cambiar contraseña de tendero
  Future<String> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    try {
      final response = await _dio.put(
        '/tenderos/cambiar-password',
        data: {
          'password_actual': passwordActual,
          'password_nuevo': passwordNuevo,
        },
      );

      final data = response.data;
      if (data is Map && data['msg'] != null) {
        return data['msg'] as String;
      }
      return 'Contraseña actualizada exitosamente.';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map && data['error'] != null) {
        String error = data['error'] as String;

  
        if (error.contains('email/teléfono') ||
            error.contains('email/telefono')) {
          error = 'Credenciales inválidas. Verifica tu teléfono y contraseña.';
        }

        return error;
      }

      return 'Error del servidor (${e.response?.statusCode})';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Revisa tu conexión.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar al servidor. Verifica tu internet.';
    }

    return 'Ocurrió un error inesperado';
  }
}
