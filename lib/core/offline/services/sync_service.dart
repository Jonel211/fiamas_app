import 'dart:async';

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
        Future.delayed(const Duration(seconds: 2), () => forceSync());
      }
    });

    Future.delayed(const Duration(seconds: 5), () => forceSync());
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
      bool hasMorePending = true;

      while (hasMorePending) {
        final pendingOps = await db.query(
          'sync_queue',
          where: 'status = ?',
          whereArgs: ['pending'],
          orderBy: 'created_at ASC',
          limit: 10,
        );

        if (pendingOps.isEmpty) {
          hasMorePending = false;
          break;
        }

        for (final opMap in pendingOps) {
          final operation = SyncOperation.fromMap(opMap);
          await _executeOperation(operation);
        }
      }
    } catch (_) {
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _executeOperation(SyncOperation op) async {
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
          response = await dio.post('/fiados', data: op.payload);
          break;
        case 'register_payment':
          response = await dio.post('/pagos', data: op.payload);
          break;
        case 'create_client':
          response = await dio.post('/clientes', data: op.payload);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            if (responseData is Map && responseData['cliente'] != null) {
              final realId = responseData['cliente']['id']?.toString();
              if (realId != null && realId != op.entityId) {
                await _updateClientIdInDatabase(op.entityId, realId);
              }
            }
          }
          break;
        case 'create_product':
          response = await dio.post('/productos', data: op.payload);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            if (responseData is Map && responseData['producto'] != null) {
              final realId = responseData['producto']['id']?.toString();
              if (realId != null && realId != op.entityId) {
                await _updateProductIdInDatabase(op.entityId, realId);
              }
            } else if (responseData is Map && responseData['id'] != null) {
              final realId = responseData['id']?.toString();
              if (realId != null && realId != op.entityId) {
                await _updateProductIdInDatabase(op.entityId, realId);
              }
            }
          }
          break;
        default:
          throw Exception('Tipo de operación no soportado: ${op.type}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [op.id]);
        return true;
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} ${response.data}',
        );
      }
    } catch (e) {
      final newRetryCount = op.retryCount + 1;
      final newStatus = newRetryCount >= 10 ? 'failed' : 'pending';

      await db.update(
        'sync_queue',
        {'status': newStatus, 'retry_count': newRetryCount},
        where: 'id = ?',
        whereArgs: [op.id],
      );

      return false;
    }
  }

  Future<void> _updateClientIdInDatabase(String tempId, String realId) async {
    final db = await _dbHelper.database;
    try {
      await db.update(
        'clientes',
        {'id': realId},
        where: 'id = ?',
        whereArgs: [tempId],
      );

      await db.update(
        'sync_queue',
        {'entity_id': realId},
        where: 'entity_id = ? AND entity = ?',
        whereArgs: [tempId, 'cliente'],
      );
    } catch (_) {}
  }

  Future<void> _updateProductIdInDatabase(String tempId, String realId) async {
    final db = await _dbHelper.database;
    try {
      await db.update(
        'productos',
        {'id': realId},
        where: 'id = ?',
        whereArgs: [tempId],
      );

      await db.update(
        'sync_queue',
        {'entity_id': realId},
        where: 'entity_id = ? AND entity = ?',
        whereArgs: [tempId, 'producto'],
      );

      await db.update(
        'fiado_detalles',
        {'producto_id': realId},
        where: 'producto_id = ?',
        whereArgs: [tempId],
      );
    } catch (_) {}
  }

  Future<void> forceSync() async {
    final db = await _dbHelper.database;

    await db.update(
      'sync_queue',
      {'status': 'pending', 'retry_count': 0},
      where: 'status = ?',
      whereArgs: ['failed'],
    );

    await _processQueue();
  }

  Future<int> getPendingCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sync_queue WHERE status != "syncing"',
    );
    return result.first['count'] as int;
  }
}