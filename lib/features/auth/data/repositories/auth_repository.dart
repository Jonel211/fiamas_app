import 'dart:convert'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthRepository(this._remoteDataSource, this._storage);

  // Login 
  Future<UserModel> login({
    required String identificador,
    required String password,
  }) async {
    final data = await _remoteDataSource.login(
      identificador: identificador,
      password: password,
    );

    final token = data['token'] as String;
    final usuario = UserModel.fromJson(data['usuario'] as Map<String, dynamic>);

    await _storage.write(key: _tokenKey, value: token);
    // Usamos jsonEncode
    await _storage.write(key: _userKey, value: jsonEncode(usuario.toJson()));

    return usuario;
  }

  // Registro Tendero
  Future<void> registerTendero({
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
    required String nombreTienda,
  }) async {
    await _remoteDataSource.registerTendero(
      dni: dni,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      password: password,
      nombreTienda: nombreTienda,
    );
  }

  // Registro Cliente
  Future<void> registerCliente({
    required String telefono,
    required String nombres,
    required String apellidos,
    String? password,
    String? direccion,
  }) async {
    await _remoteDataSource.registerCliente(
      telefono: telefono,
      nombres: nombres,
      apellidos: apellidos,
      password: password,
      direccion: direccion,
    );
  }

  // Cambiar Contraseña
  Future<String> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    return await _remoteDataSource.cambiarPassword(
      passwordActual: passwordActual,
      passwordNuevo: passwordNuevo,
    );
  }

  // Token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Recuperar Usuario Guardado 
  Future<UserModel?> getSavedUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> resetPassword({
    required String identificador,
    required String nuevaPassword, 
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        identificador: identificador,
        nuevaPassword: nuevaPassword,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}