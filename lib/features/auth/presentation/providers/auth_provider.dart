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
  bool get isPremium => _perfil?.isPremium ?? _user?.esPremium ?? false;
  String get tenderoNombreCompleto =>
      (_perfil?.fullName ?? _user?.nombre ?? '').trim();
  String? get tenderoFotoUrl {
    final photoUrl = _perfil != null ? _perfil!.fotoUrl : _user?.fotoPerfilUrl;
    final normalizedUrl = photoUrl?.trim();
    return normalizedUrl == null || normalizedUrl.isEmpty ? null : normalizedUrl;
  }

  AuthProvider() {
    final dio = DioClient.create();
    final remote = AuthRemoteDataSource(dio);
    const storage = FlutterSecureStorage();
    _repository = AuthRepository(remote, storage);
  }

  // Verificar sesión guardada al iniciar la app
  Future<bool> checkAuthStatus() async {
    try {
      final savedToken = await _repository.getToken();
      final savedUser = await _repository.getSavedUser();

      if (savedToken != null && savedToken.isNotEmpty && savedUser != null) {
        if (!savedUser.isTendero) {
          await _repository.logout();
          _token = null;
          _user = null;
          return false;
        }

        _token = savedToken;
        _user = savedUser;

        // Solo notificamos que hay sesión para que el splash pueda avanzar.
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login({
    required String identificador,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(
        identificador: identificador,
        password: password,
      );

      if (!user.isTendero) {
        await _repository.logout();
        _user = null;
        _token = null;
        _errorMessage = 'Esta cuenta pertenece a un cliente. Esta aplicación es exclusiva para tenderos.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = user;
      _token = await _repository.getToken();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
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
    String? direccion,
    String? ruc,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.registerTendero(
        dni: dni,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        password: password,
        nombreTienda: nombreTienda,
        direccion: direccion,
        ruc: ruc,
      );
      _user = user;
      _token = await _repository.getToken();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
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
      await _syncUserWithPerfil();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _syncUserWithPerfil() async {
    final perfil = _perfil;
    final user = _user;
    if (perfil == null || user == null) return;

    final photoUrl = perfil.fotoUrl?.trim();
    _user = user.copyWith(
      esPremium: perfil.isPremium,
      fotoPerfilUrl: photoUrl == null || photoUrl.isEmpty ? null : photoUrl,
      clearFotoPerfilUrl: photoUrl == null || photoUrl.isEmpty,
    );
    await _repository.saveUser(_user!);
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
      await _syncUserWithPerfil();
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
      await _syncUserWithPerfil();
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
  Future<bool> resetPassword({
    required String identificador,
    required String nuevaPassword, 
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.resetPassword(
        identificador: identificador,
        nuevaPassword: nuevaPassword,
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
  
}