import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/network/dio_client.dart';
import '../database/database_helper.dart';
import '../models/sync_operation.dart';
import 'connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();
  bool _isSyncing = false;

  Future<void> init() async {
    _connectivity.connectionStatusStream.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        _processQueue();
      }
    });
  }

  Future<void> addToQueue(SyncOperation operation) async {
    final db = await _dbHelper.database;
    await db.insert('sync_queue', operation.toMap());
  }

  Future<void> _processQueue() async {
    if (_isSyncing) return;
    
    final isConnected = await _connectivity.isConnected();
    if (!isConnected) return;

    _isSyncing = true;
    final db = await _dbHelper.database;

    try {
      final pendingOps = await db.query(
        'sync_queue',
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
        limit: 10,
      );

      for (final opMap in pendingOps) {
        final operation = SyncOperation.fromMap(opMap);
        await _executeOperation(operation);
      }
    } catch (e) {
      print('❌ Error procesando la cola de sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _executeOperation(SyncOperation op) async {
    final db = await _dbHelper.database;
    final dio = DioClient.create();

    try {
      await db.update(
        'sync_queue',
        {'status': 'syncing'},
        where: 'id = ?',
        whereArgs: [op.id],
      );

      dynamic response;
      
      switch (op.type) {
        case 'create_fiado':
          // ✅ CORRECTO: op.payload ya es un Map válido, Dio lo convierte a JSON automáticamente
          response = await dio.post('/fiados', data: op.payload);
          break;
        case 'register_payment':
          response = await dio.post('/pagos', data: op.payload);
          break;
        case 'create_client':
          response = await dio.post('/clientes', data: op.payload);
          break;
        default:
          throw Exception('Tipo de operación no soportado: ${op.type}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [op.id]);
        print('✅ Sincronizado exitosamente: ${op.type}');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      final newRetryCount = op.retryCount + 1;
      final newStatus = newRetryCount >= 3 ? 'failed' : 'pending';
      
      await db.update(
        'sync_queue',
        {
          'status': newStatus,
          'retry_count': newRetryCount,
        },
        where: 'id = ?',
        whereArgs: [op.id],
      );
      print('⚠️ Falló sincronización (Intento $newRetryCount): ${op.type} - $e');
    }
  }

  Future<void> forceSync() async {
    await _processQueue();
  }
}