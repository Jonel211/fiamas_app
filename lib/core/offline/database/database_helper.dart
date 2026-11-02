import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Actualizando BD de v$oldVersion a v$newVersion');
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE categorias ADD COLUMN icono TEXT');
        await db.execute('ALTER TABLE categorias ADD COLUMN color TEXT');
      } catch (e) {
        print('⚠️ Columnas de categorías ya existen o error: $e');
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute(
          'ALTER TABLE productos ADD COLUMN stock_actual INTEGER',
        );
      } catch (e) {
        print('⚠️ Columna stock_actual ya existe o error: $e');
      }
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (id TEXT PRIMARY KEY, telefono TEXT NOT NULL, nombres TEXT NOT NULL, apellidos TEXT NOT NULL, direccion TEXT, foto_perfil_url TEXT, creado_en TEXT, limite_credito REAL, saldo_actual REAL)
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

  // ✅ CATEGORÍAS POR TIENDA
  Future<void> saveCategorias(
    String tiendaId,
    List<Map<String, dynamic>> categorias,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'categorias',
        where: 'tienda_id = ?',
        whereArgs: [tiendaId],
      );
      for (var cat in categorias) await txn.insert('categorias', cat);
    });
  }

  Future<List<Map<String, dynamic>>> getCategorias(String tiendaId) async {
    final db = await database;
    return await db.query(
      'categorias',
      where: 'tienda_id = ?',
      whereArgs: [tiendaId],
    );
  }

  // ✅ PRODUCTOS POR TIENDA
  Future<void> saveProductos(
    String tiendaId,
    List<Map<String, dynamic>> productos,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'productos',
        where: 'tienda_id = ?',
        whereArgs: [tiendaId],
      );
      for (var producto in productos) await txn.insert('productos', producto);
    });
  }

  Future<List<Map<String, dynamic>>> getProductos(String tiendaId) async {
    final db = await database;
    return await db.query(
      'productos',
      where: 'tienda_id = ? AND activo = ?',
      whereArgs: [tiendaId, 1],
    );
  }

  // ... (Mantén los demás métodos de clientes, fiados, pagos y sync_queue igual que antes) ...
  Future<void> saveClientes(List<Map<String, dynamic>> clientes) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('clientes');
      for (var cliente in clientes) await txn.insert('clientes', cliente);
    });
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await database;
    return await db.query('clientes', orderBy: 'nombres ASC');
  }

  Future<void> saveFiado(Map<String, dynamic> fiado) async {
    final db = await database;
    await db.insert(
      'fiados',
      fiado,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    await db.insert(
      'pagos',
      pago,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addToSyncQueue(Map<String, dynamic> operation) async {
    final db = await database;
    await db.insert('sync_queue', operation);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
      limit: 10,
    );
  }

  Future<void> removeSyncQueue(String id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSyncQueueStatus(
    String id,
    String status,
    int retryCount,
  ) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {'status': status, 'retry_count': retryCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
