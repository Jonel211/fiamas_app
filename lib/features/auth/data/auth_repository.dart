import '../../../core/services/api_service.dart';
import '../../../core/services/session_service.dart';

class AuthRepository {
  /// Registra un tendero en el backend
  Future<Map<String, dynamic>> registerTendero({
    required String dni,
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String password,
  }) async {
    return await ApiService.post('/auth/register/tendero', {
      'dni': dni,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'password': password,
    });
  }

  /// Login del tendero
  Future<Map<String, dynamic>> loginTendero({
    required String email,
    required String password,
  }) async {
    final result = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
      'rol': 'tendero',
    });

    // Si el login fue exitoso, guardamos la sesión
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      await SessionService.saveSession(
        token: data['token'],
        usuario: Map<String, dynamic>.from(data['usuario']),
      );
    }

    return result;
  }
}
