import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/models/tendero_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/network/dio_client.dart';

class AuthProvider with ChangeNotifier {
  late final AuthRepository _repository;

  UserModel? _user;
  String? _token;
  TenderoModel? _perfil;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  String? get tiendaId => _user?.tiendaId;
  TenderoModel? get perfil => _perfil;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    final dio = DioClient.create();
    final remote = AuthRemoteDataSource(dio);
    const storage = FlutterSecureStorage();
    _repository = AuthRepository(remote, storage);
  }

  // ─── Sesión ──────────────────────────────────────────────

  /// Devuelve true si el token JWT ya venció (o no se puede leer).
  bool _tokenVencido(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) return false;
      final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return ahora >= exp.toInt();
    } catch (_) {
      return true;
    }
  }

  /// Restaura token y usuario guardados. Llamar desde el splash.
  /// Devuelve true si hay una sesión válida.
  Future<bool> restaurarSesion() async {
    final token = await _repository.getToken();
    if (token == null || token.isEmpty || _tokenVencido(token)) {
      await _repository.logout();
      return false;
    }

    final user = await _repository.getSavedUser();
    if (user == null) {
      await _repository.logout();
      return false;
    }

    _token = token;
    _user = user;
    notifyListeners();
    cargarPerfil(); // refresca foto y datos en segundo plano
    return true;
  }

  Future<bool> login({
    required String identificador,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.login(
        identificador: identificador,
        password: password,
      );
      _token = await _repository.getToken();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerTendero({
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
    required String nombreTienda,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.registerTendero(
        dni: dni,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        password: password,
        nombreTienda: nombreTienda,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerCliente({
    required String telefono,
    required String nombres,
    required String apellidos,
    String? password,
    String? direccion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.registerCliente(
        telefono: telefono,
        nombres: nombres,
        apellidos: apellidos,
        password: password,
        direccion: direccion,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.cambiarPassword(
        passwordActual: passwordActual,
        passwordNuevo: passwordNuevo,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarPerfil() async {
    try {
      _perfil = await authService.getPerfil();
      notifyListeners();
    } catch (_) {}
  }

  // Actualizar perfil del tendero
  Future<bool> updatePerfil({
    required String nombres,
    required String apellidos,
    required String telefono,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _perfil = await authService.updatePerfil(
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Subir foto de perfil del tendero
  Future<bool> subirFotoPerfil(File file) async {
    _errorMessage = null;

    try {
      _perfil = await authService.subirFotoPerfil(file);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _token = null;
    _perfil = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}