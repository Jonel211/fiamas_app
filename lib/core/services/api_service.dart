import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'session_service.dart';

class ApiService {
  /// Headers con token si hay sesión activa
  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// POST genérico
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }

  /// GET genérico (con token)
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _headers(),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }

  /// Manejo uniforme de respuestas
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': data};
    }
    return {
      'success': false,
      'error':
          data['message'] ??
          data['error'] ??
          'Error desconocido (${response.statusCode})',
    };
  }
}
