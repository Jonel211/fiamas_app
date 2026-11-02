import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  bool _isInitialized = false;
  bool _lastKnownStatus = true;

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Verificar estado inicial
    _lastKnownStatus = await _checkConnection();
    _isInitialized = true;
    
    // Emitir estado inicial
    _connectionStatusController.add(_lastKnownStatus);

    // Escuchar cambios de conectividad
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.first;
      final isConnected = result != ConnectivityResult.none;
      
      if (isConnected != _lastKnownStatus) {
        _lastKnownStatus = isConnected;
        _connectionStatusController.add(isConnected);
      }
    });
  }

  Future<bool> isConnected() async {
    return await _checkConnection();
  }

  bool get isInitialized => _isInitialized;
  bool get lastKnownStatus => _lastKnownStatus;

  Future<bool> _checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}