import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
   static const String _tiendaKey = 'tienda_actual';

  /// Guarda el token y los datos del usuario al iniciar sesión
  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> usuario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(usuario));
  }

  /// Recupera el token (null si no hay sesión)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Recupera los datos del usuario
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// Verifica si hay una sesión activa
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Cierra la sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Guarda el id y nombre de la tienda seleccionada
  static Future<void> saveTiendaActual({
    required String id,
    required String nombre,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tiendaKey, '$id|$nombre');
  }

  /// Devuelve { id, nombre } de la tienda actual o null
  static Future<Map<String, String>?> getTiendaActual() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tiendaKey);
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length < 2) return null;
    return {'id': parts[0], 'nombre': parts[1]};
  }

  static Future<void> clearTiendaActual() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tiendaKey);
  }
}
