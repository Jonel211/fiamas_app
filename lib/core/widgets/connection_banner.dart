import 'package:flutter/material.dart';
import '../offline/services/connectivity_service.dart';
import '../offline/services/sync_service.dart';

class ConnectionBanner extends StatefulWidget {
  const ConnectionBanner({super.key});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  bool _isConnected = true;
  bool _serviceReady = false;

  @override
  void initState() {
    super.initState();
    _setupConnectivity();
  }

  Future<void> _setupConnectivity() async {
    final service = ConnectivityService();
    
    // Si el servicio ya está inicializado, usar el estado conocido
    if (service.isInitialized) {
      setState(() {
        _isConnected = service.lastKnownStatus;
        _serviceReady = true;
      });
    } else {
      // Si no está inicializado, esperar a que lo esté
      await service.init();
      setState(() {
        _isConnected = service.lastKnownStatus;
        _serviceReady = true;
      });
    }

    // Escuchar cambios futuros
    service.connectionStatusStream.listen((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras el servicio no esté listo, no mostrar nada
    if (!_serviceReady) {
      return const SizedBox.shrink();
    }

    if (_isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.orangeAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Modo sin conexión. Los cambios se guardarán localmente.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () {
              SyncService().forceSync();
            },
            child: const Text(
              'Sincronizar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}