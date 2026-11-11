import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/offline/database/database_helper.dart';
import '../../../core/offline/models/sync_operation.dart';
import '../../../core/offline/services/connectivity_service.dart';
import '../../../core/offline/services/sync_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/providers/tienda_provider.dart';
import '../data/services/category_service.dart';
import '../data/services/product_service.dart';
import 'category.dart' as inventory_category;
import 'product.dart';

class InventoryProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<inventory_category.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get activeProducts =>
      _products.where((p) => p.activo).toList(growable: false);
  List<inventory_category.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductService? _productService;
  CategoryService? _categoryService;
  String? _tiendaId;
  String? _token;
  bool _disposed = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  String? get tiendaId => _tiendaId;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notifySoon() {
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
  }

  void reset() {
    _tiendaId = null;
    _token = null;
    _products = [];
    _categories = [];
    _error = null;
    _isLoading = false;
    _productService = null;
    _categoryService = null;
    _notifySoon();
  }

  void updateTiendaContext(String token, String nuevaTiendaId) {
    if (_tiendaId != nuevaTiendaId || _token != token) {
      _tiendaId = nuevaTiendaId;
      _token = token;
      _products = [];
      _categories = [];
      _error = null;
      _isLoading = false;
      _productService = ProductService(token: token);
      _categoryService = CategoryService(token: token);
      _notifySoon();
    }
  }

  void ensureInitialized(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tiendaProvider = Provider.of<TiendaProvider>(context, listen: false);
      final token = authProvider.token;
      final tiendaId = tiendaProvider.tiendaSeleccionadaId;
      if (token != null && tiendaId != null) {
        updateTiendaContext(token, tiendaId);
      }
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Categorías ───────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    if (_tiendaId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final requestedId = _tiendaId!;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cached = await _dbHelper.getCategorias(requestedId);
      if (cached.isNotEmpty && _tiendaId == requestedId && !_disposed) {
        _categories = cached
            .map((c) => inventory_category.Category.fromMap(c))
            .toList();
        _isLoading = false;
        notifyListeners();
      }

      final isConnected = await _connectivity.isConnected();
      if (isConnected &&
          _categoryService != null &&
          _tiendaId == requestedId &&
          !_disposed) {
        try {
          final result = await _categoryService!
              .getCategories(requestedId)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Timeout en categorías'),
              );

          if (_tiendaId == requestedId && !_disposed) {
            _categories = result;
            unawaited(
              _dbHelper.saveCategorias(
                requestedId,
                _categories.map((c) => c.toMap()).toList(),
              ),
            );
          }
        } catch (_) {}
      }
    } catch (e) {
      if (_tiendaId == requestedId && !_disposed) {
        _error = 'Error: $e';
      }
    } finally {
      if (_tiendaId == requestedId && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> createCategory(inventory_category.Category category) async {
    if (_categoryService == null || _tiendaId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final newCategory = await _categoryService!.createCategory(category);
      _categories.add(newCategory);
      unawaited(
        _dbHelper.saveCategorias(
          _tiendaId!,
          _categories.map((c) => c.toMap()).toList(),
        ),
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(
    String id,
    inventory_category.Category category,
  ) async {
    if (_categoryService == null || _tiendaId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _categoryService!.updateCategory(id, category);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updated;
        unawaited(
          _dbHelper.saveCategorias(
            _tiendaId!,
            _categories.map((c) => c.toMap()).toList(),
          ),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    if (_categoryService == null || _tiendaId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _categoryService!.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      unawaited(
        _dbHelper.saveCategorias(
          _tiendaId!,
          _categories.map((c) => c.toMap()).toList(),
        ),
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Productos ────────────────────────────────────────────────────────────
  Future<void> loadProducts() async {
    if (_tiendaId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final requestedId = _tiendaId!;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cached = await _dbHelper.getProductos(requestedId);
      if (cached.isNotEmpty && _tiendaId == requestedId && !_disposed) {
        _products = cached.map((p) => Product.fromMap(p)).toList();
        _isLoading = false;
        notifyListeners();
      }

      final isConnected = await _connectivity.isConnected();
      if (isConnected &&
          _productService != null &&
          _tiendaId == requestedId &&
          !_disposed) {
        try {
          final result = await _productService!
              .getProductsByStore(requestedId)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Timeout en productos'),
              );

          if (_tiendaId == requestedId && !_disposed) {
            _products = result;
            if (_products.isNotEmpty) {
              unawaited(
                _dbHelper.saveProductos(
                  requestedId,
                  _products.map((p) => p.toMap()).toList(),
                ),
              );
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      if (_tiendaId == requestedId && !_disposed) {
        _error = 'Error: $e';
      }
    } finally {
      if (_tiendaId == requestedId && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<Product?> createProduct(Product product, {File? imagenFile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_tiendaId == null) {
        _error = 'No hay tienda seleccionada';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final isConnected = await _connectivity.isConnected();

      if (isConnected && _productService != null) {
        try {
          final newProduct = await _productService!.createProduct(
            product,
            imagenFile: imagenFile,
          );
          _products.add(newProduct);
          unawaited(
            _dbHelper.saveProductos(
              _tiendaId!,
              _products.map((p) => p.toMap()).toList(),
            ),
          );
          _isLoading = false;
          notifyListeners();
          return newProduct;
        } catch (_) {
          return await _createProductOffline(product, imagenFile);
        }
      } else {
        return await _createProductOffline(product, imagenFile);
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Product?> _createProductOffline(
    Product product,
    File? imagenFile,
  ) async {
    try {
      final tempId = 'temp_prod_${DateTime.now().millisecondsSinceEpoch}';

      final localProduct = Product(
        id: tempId,
        tiendaId: _tiendaId!,
        categoriaId: product.categoriaId,
        nombre: product.nombre,
        descripcion: product.descripcion,
        codigoBarras: product.codigoBarras,
        tipoVenta: product.tipoVenta,
        unidadMedida: product.unidadMedida,
        precioVenta: product.precioVenta,
        activo: product.activo,
        imagenUrl: product.imagenUrl,
        stockActual: product.stockActual,
      );

      _products.add(localProduct);

      try {
        final allProductsMap = _products.map((p) => p.toMap()).toList();
        await _dbHelper.saveProductos(_tiendaId!, allProductsMap);
      } catch (_) {}

      try {
        final payload = {...localProduct.toJson(), 'tienda_id': _tiendaId};
        await SyncService().addToQueue(
          SyncOperation(
            type: 'create_product',
            entity: 'producto',
            entityId: tempId,
            payload: payload,
          ),
        );
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
      return localProduct;
    } catch (e) {
      _error = 'Error al crear producto local: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Product?> updateProduct(
    String id,
    Product product, {
    File? imagenFile,
  }) async {
    if (_productService == null || _tiendaId == null) return null;
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _productService!.updateProduct(
        id,
        product,
        imagenFile: imagenFile,
      );
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
        unawaited(
          _dbHelper.saveProductos(
            _tiendaId!,
            _products.map((p) => p.toMap()).toList(),
          ),
        );
      }
      _isLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleProductActive(String productId, bool nuevoEstado) async {
    if (_productService == null || _tiendaId == null) return;
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final p = _products[index];
    final productoActualizado = Product(
      id: p.id,
      tiendaId: p.tiendaId,
      categoriaId: p.categoriaId,
      nombre: p.nombre,
      descripcion: p.descripcion,
      codigoBarras: p.codigoBarras,
      tipoVenta: p.tipoVenta,
      unidadMedida: p.unidadMedida,
      precioVenta: p.precioVenta,
      activo: nuevoEstado,
      imagenUrl: p.imagenUrl,
      categoria: p.categoria,
      stockActual: p.stockActual,
    );

    await _productService!.updateProduct(productId, productoActualizado);
    _products[index] = productoActualizado;
    unawaited(
      _dbHelper.saveProductos(
        _tiendaId!,
        _products.map((p) => p.toMap()).toList(),
      ),
    );
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    if (_productService == null || _tiendaId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _productService!.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      unawaited(
        _dbHelper.saveProductos(
          _tiendaId!,
          _products.map((p) => p.toMap()).toList(),
        ),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}