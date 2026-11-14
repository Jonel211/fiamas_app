import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as dev;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fiamas_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Versión 4 para la migración de clientes
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    dev.log('🔄 Actualizando BD de v$oldVersion a v$newVersion', name: 'DB_MIGRATION');
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE categorias ADD COLUMN icono TEXT');
        await db.execute('ALTER TABLE categorias ADD COLUMN color TEXT');
      } catch (e) { dev.log('⚠️ Columnas categorías: $e', name: 'DB_MIGRATION'); }
    }
    if (oldVersion < 3) {
      try { await db.execute('ALTER TABLE productos ADD COLUMN stock_actual INTEGER'); } 
      catch (e) { dev.log('⚠️ Columna stock: $e', name: 'DB_MIGRATION'); }
    }
    if (oldVersion < 4) {
      // Agregar tienda_id a clientes sin perder datos existentes
      try { await db.execute('ALTER TABLE clientes ADD COLUMN tienda_id TEXT'); } 
      catch (e) { dev.log('⚠️ Columna tienda_id en clientes: $e', name: 'DB_MIGRATION'); }
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        id TEXT PRIMARY KEY, tienda_id TEXT, telefono TEXT NOT NULL, nombres TEXT NOT NULL, 
        apellidos TEXT NOT NULL, direccion TEXT, foto_perfil_url TEXT, creado_en TEXT, 
        limite_credito REAL, saldo_actual REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE categorias (id TEXT PRIMARY KEY, tienda_id TEXT NOT NULL, nombre TEXT NOT NULL, descripcion TEXT, icono TEXT, color TEXT, activo INTEGER DEFAULT 1)
    ''');
    await db.execute('''
      CREATE TABLE productos (id TEXT PRIMARY KEY, tienda_id TEXT NOT NULL, categoria_id TEXT, nombre TEXT NOT NULL, descripcion TEXT, codigo_barras TEXT, tipo_venta TEXT, unidad_medida TEXT, precio_venta REAL NOT NULL, stock_actual INTEGER, activo INTEGER DEFAULT 1, imagen_url TEXT, creado_en TEXT)
    ''');
    await db.execute('''
      CREATE TABLE fiados (id TEXT PRIMARY KEY, cliente_id TEXT NOT NULL, tienda_id TEXT NOT NULL, tendero_id TEXT NOT NULL, numero_fiado TEXT NOT NULL, monto_total REAL NOT NULL, monto_pagado REAL DEFAULT 0, estado TEXT NOT NULL, fecha_fiado TEXT NOT NULL, fecha_vencimiento TEXT, notas TEXT, creado_en TEXT NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE fiado_detalles (id TEXT PRIMARY KEY, fiado_id TEXT NOT NULL, producto_id TEXT NOT NULL, nombre_producto TEXT NOT NULL, cantidad REAL NOT NULL, precio_unitario REAL NOT NULL, subtotal REAL NOT NULL, FOREIGN KEY (fiado_id) REFERENCES fiados (id) ON DELETE CASCADE)
    ''');
    await db.execute('''
      CREATE TABLE pagos (id TEXT PRIMARY KEY, fiado_id TEXT NOT NULL, tienda_id TEXT NOT NULL, cliente_id TEXT NOT NULL, numero_pago TEXT NOT NULL, monto REAL NOT NULL, metodo_pago TEXT, fecha_pago TEXT NOT NULL, notas TEXT, FOREIGN KEY (fiado_id) REFERENCES fiados (id) ON DELETE CASCADE)
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (id TEXT PRIMARY KEY, type TEXT NOT NULL, entity TEXT NOT NULL, entity_id TEXT NOT NULL, payload TEXT NOT NULL, status TEXT DEFAULT 'pending', retry_count INTEGER DEFAULT 0, created_at TEXT NOT NULL)
    ''');
  }

  //  UPSERT SEGURO: Reemplaza si existe, inserta si no. No borra toda la tabla.
  Future<void> saveClientes(String tiendaId, List<Map<String, dynamic>> clientes) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var cliente in clientes) {
        await txn.insert('clientes', cliente, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  //  FILTRADO POR TIENDA: Evita mezclar clientes de diferentes tiendas
  Future<List<Map<String, dynamic>>> getClientes(String tiendaId) async {
    final db = await database;
    return await db.query('clientes', where: 'tienda_id = ?', whereArgs: [tiendaId], orderBy: 'nombres ASC');
  }

  Future<void> saveCategorias(String tiendaId, List<Map<String, dynamic>> categorias) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var cat in categorias) {
        await txn.insert('categorias', cat, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCategorias(String tiendaId) async {
    final db = await database;
    return await db.query('categorias', where: 'tienda_id = ?', whereArgs: [tiendaId]);
  }

  Future<void> saveProductos(String tiendaId, List<Map<String, dynamic>> productos) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var producto in productos) {
        await txn.insert('productos', producto, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getProductos(String tiendaId) async {
    final db = await database;
    return await db.query('productos', where: 'tienda_id = ? AND activo = ?', whereArgs: [tiendaId, 1]);
  }

  Future<void> saveFiado(Map<String, dynamic> fiado) async {
    final db = await database;
    await db.insert('fiados', fiado, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFiados() async {
    final db = await database;
    return await db.query('fiados', orderBy: 'creado_en DESC');
  }

  Future<void> saveFiadoDetalle(Map<String, dynamic> detalle) async {
    final db = await database;
    await db.insert('fiado_detalles', detalle);
  }

  Future<void> savePago(Map<String, dynamic> pago) async {
    final db = await database;
    await db.insert('pagos', pago, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addToSyncQueue(Map<String, dynamic> operation) async {
    final db = await database;
    await db.insert('sync_queue', operation);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final db = await database;
    return await db.query('sync_queue', where: 'status = ?', whereArgs: ['pending'], orderBy: 'created_at ASC');
  }

  Future<void> removeSyncQueue(String id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSyncQueueStatus(String id, String status, int retryCount) async {
    final db = await database;
    await db.update('sync_queue', {'status': status, 'retry_count': retryCount}, where: 'id = ?', whereArgs: [id]);
  }
    //  NUEVO: Valida si ya existe un producto con ese nombre en la tienda (ignora mayúsculas/minúsculas)
  Future<bool> productoExistePorNombre(String tiendaId, String nombre) async {
    final db = await database;
    final nombreNormalizado = nombre.trim().toLowerCase();
    final result = await db.query(
      'productos',
      where: 'tienda_id = ? AND LOWER(nombre) = ?',
      whereArgs: [tiendaId, nombreNormalizado],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}