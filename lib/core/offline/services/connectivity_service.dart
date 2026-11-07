import 'dart:async';
import 'dart:developer' as dev;
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

    _lastKnownStatus = await _hasConnection();
    _isInitialized = true;
    _connectionStatusController.add(_lastKnownStatus);

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final result = results.first;
      _lastKnownStatus = (result != ConnectivityResult.none);
      _connectionStatusController.add(_lastKnownStatus);
    });
  }

  Future<bool> isConnected() async {
    return await _hasConnection();
  }

  Future<bool> _hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results != ConnectivityResult.none;
    } catch (e) {
      dev.log('Error verificando conexión: $e', name: 'CONNECTIVITY');
      return false;
    }
  }

  bool get isInitialized => _isInitialized;
  bool get lastKnownStatus => _lastKnownStatus;

  void dispose() {
    _connectionStatusController.close();
  }
}