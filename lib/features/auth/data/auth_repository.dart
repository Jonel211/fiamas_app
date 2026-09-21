import '../../../core/services/api_service.dart';
import '../../../core/services/session_service.dart';

class AuthRepository {
  // ============================================================
  // REGISTRO: Tendero
  // El email se genera automáticamente en el backend desde el DNI
  // ============================================================
  Future<Map<String, dynamic>> registerTendero({
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    return await ApiService.post('/auth/register/tendero', {
      'dni': dni,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'password': password,
      // 👆 NO enviamos email: el backend lo genera como {dni}@tendero.fiamas.app
    });
  }

  // ============================================================
  // LOGIN: Tendero (por DNI, teléfono o email)
  // ============================================================
  Future<Map<String, dynamic>> loginTendero({
    required String identifier, // DNI, teléfono o email
    required String password,
  }) async {
    final result = await ApiService.post('/auth/login', {
      'identifier': identifier,
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
