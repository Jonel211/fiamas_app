import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  DioClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://fiamas-tiendas.onrender.com/api',
  );

  /// Se ejecuta cuando el servidor rechaza el token (vencido o inválido).
  /// Lo configura main.dart.
  static void Function()? onUnauthorized;
  static bool _manejando401 = false;

  /// main.dart lo llama al terminar de cerrar la sesión.
  static void resetUnauthorized() => _manejando401 = false;

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'auth_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          if (_esTokenRechazado(error) &&
              onUnauthorized != null &&
              !_manejando401) {
            _manejando401 = true;
            onUnauthorized!();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Solo cuenta como "sesión vencida" un 401 que menciona el token.
  /// Así una contraseña actual incorrecta (también 401) no cierra la sesión.
  static bool _esTokenRechazado(DioException error) {
    if (error.response?.statusCode != 401) return false;
    if (error.requestOptions.headers['Authorization'] == null) return false;
    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      return (data['error'] as String).toLowerCase().contains('token');
    }
    return false;
  }
}