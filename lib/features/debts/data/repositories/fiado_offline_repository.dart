import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/offline/database/database_helper.dart';
import '../../../../core/offline/models/sync_operation.dart';
import '../../../../core/offline/services/connectivity_service.dart';
import '../../../../core/offline/services/sync_service.dart';

class FiadoOfflineRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncService _syncService = SyncService();

  //CREAR FIADO (Modo Inteligente)
  Future<Map<String, dynamic>> crearFiado({
    required String clienteId,
    required String tiendaId,
    required String tenderoId,
    required List<Map<String, dynamic>> productos,
    String? fechaVencimiento,
    String? notas,
  }) async {
    final bool isOnline = await _connectivity.isConnected();

    if (isOnline) {
      // MODO ONLINE: Enviar directo al backend
      return await _crearFiadoOnline(clienteId, tiendaId, productos, fechaVencimiento, notas);
    } else {
      // MODO OFFLINE: Guardar localmente y encolar
      return await _crearFiadoOffline(clienteId, tiendaId, tenderoId, productos, fechaVencimiento, notas);
    }
  }

  Future<Map<String, dynamic>> _crearFiadoOnline(
    String clienteId, String tiendaId, List<Map<String, dynamic>> productos, String? fechaVencimiento, String? notas,
  ) async {
    final dio = DioClient.create();
    final response = await dio.post('/fiados', data: {
      'cliente_id': clienteId,
      'tienda_id': tiendaId,
      'productos': productos,
      'fecha_vencimiento': fechaVencimiento,
      'notas': notas,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> _crearFiadoOffline(
    String clienteId, String tiendaId, String tenderoId, List<Map<String, dynamic>> productos, String? fechaVencimiento, String? notas,
  ) async {
    final db = await _dbHelper.database;
    final localFiadoId = const Uuid().v4();
    final numeroFiadoLocal = 'F-OFF-${DateTime.now().millisecondsSinceEpoch}';
    final fechaActual = DateTime.now().toIso8601String();

    // Calcular monto total localmente
    double montoTotal = 0;
    for (var p in productos) {
      montoTotal += (p['precio_unitario'] * p['cantidad']);
    }

    await db.transaction((txn) async {
      // 1. Guardar Fiado
      await txn.insert('fiados', {
        'id': localFiadoId,
        'cliente_id': clienteId,
        'tienda_id': tiendaId,
        'tendero_id': tenderoId,
        'numero_fiado': numeroFiadoLocal,
        'monto_total': montoTotal,
        'monto_pagado': 0.0,
        'estado': 'pendiente',
        'fecha_fiado': fechaActual,
        'fecha_vencimiento': fechaVencimiento,
        'notas': notas,
        'creado_en': fechaActual,
      });

      // 2. Guardar Detalles
      for (var p in productos) {
        await txn.insert('fiado_detalles', {
          'id': const Uuid().v4(),
          'fiado_id': localFiadoId,
          'producto_id': p['producto_id'],
          'nombre_producto': p['nombre_producto'] ?? 'Producto',
          'cantidad': p['cantidad'],
          'precio_unitario': p['precio_unitario'],
          'subtotal': p['precio_unitario'] * p['cantidad'],
        });
      }
    });

    // 3. Encolar para sincronización
    await _syncService.addToQueue(SyncOperation(
      type: 'create_fiado',
      entity: 'fiado',
      entityId: localFiadoId,
      payload: {
        'cliente_id': clienteId,
        'tienda_id': tiendaId,
        'productos': productos,
        'fecha_vencimiento': fechaVencimiento,
        'notas': notas,
      },
    ));

    return {
      'msg': 'Fiado guardado localmente. Se sincronizará al recuperar conexión.',
      'offline': true,
      'fiado_id': localFiadoId,
    };
  }

  // REGISTRAR PAGO (Modo Inteligente)
  Future<Map<String, dynamic>> registrarPago({
    required String fiadoId,
    required double monto,
    String? metodoPago,
    String? referencia,
    String? notas,
  }) async {
    final bool isOnline = await _connectivity.isConnected();

    if (isOnline) {
      final dio = DioClient.create();
      final response = await dio.post('/pagos', data: {
        'fiado_id': fiadoId,
        'monto': monto,
        'metodo_pago': metodoPago ?? 'efectivo',
        'referencia': referencia,
        'notas': notas,
      });
      return response.data;
    } else {
      final db = await _dbHelper.database;
      final localPagoId = const Uuid().v4();
      final numeroPagoLocal = 'P-OFF-${DateTime.now().millisecondsSinceEpoch}';
      final fechaActual = DateTime.now().toIso8601String();

      // Guardar pago localmente
      await db.insert('pagos', {
        'id': localPagoId,
        'fiado_id': fiadoId,
        'tienda_id': 'pendiente', // Se resolverá al sincronizar
        'cliente_id': 'pendiente',
        'numero_pago': numeroPagoLocal,
        'monto': monto,
        'metodo_pago': metodoPago ?? 'efectivo',
        'fecha_pago': fechaActual,
        'notas': notas,
      });

      // Actualizar monto pagado del fiado local (optimista)
      // Nota: En una app real, deberías consultar el fiado primero para sumar al monto_pagado actual.
      
      // Encolar
      await _syncService.addToQueue(SyncOperation(
        type: 'register_payment',
        entity: 'pago',
        entityId: localPagoId,
        payload: {
          'fiado_id': fiadoId,
          'monto': monto,
          'metodo_pago': metodoPago ?? 'efectivo',
          'referencia': referencia,
          'notas': notas,
        },
      ));

      return {
        'msg': 'Pago registrado localmente. Se sincronizará al recuperar conexión.',
        'offline': true,
      };
    }
  }
}