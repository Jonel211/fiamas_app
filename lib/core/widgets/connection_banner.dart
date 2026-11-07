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
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _setupConnectivity();
  }

  Future<void> _setupConnectivity() async {
    final service = ConnectivityService();
    
    if (service.isInitialized) {
      setState(() {
        _isConnected = service.lastKnownStatus;
        _serviceReady = true;
      });
    } else {
      await service.init();
      setState(() {
        _isConnected = service.lastKnownStatus;
        _serviceReady = true;
      });
    }

    service.connectionStatusStream.listen((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    });
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    
    final syncService = SyncService();
    await syncService.forceSync();
    final pendingCount = await syncService.getPendingCount();
    
    if (!mounted) return;
    setState(() => _isSyncing = false);
    
    if (pendingCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Todos los datos sincronizados'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Quedan $pendingCount operaciones pendientes'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 8),
          TextButton(
            onPressed: _isSyncing ? null : _handleSync,
            child: _isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
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