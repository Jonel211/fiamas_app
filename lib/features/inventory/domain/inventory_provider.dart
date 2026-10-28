import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../data/services/product_service.dart';
import '../data/services/category_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/providers/tienda_provider.dart';
import 'product.dart';
import 'category.dart' as inventory_category;

class InventoryProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<inventory_category.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<inventory_category.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductService? _productService;
  CategoryService? _categoryService;
  String? _tiendaId;
  String? _token;
  bool _disposed = false;

  String? get tiendaId => _tiendaId;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Notifica fuera del ciclo de build (evita "setState during build"
  /// cuando lo dispara un ProxyProvider).
  void _notifySoon() {
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
  }

  /// Vacía todo (cierre de sesión o sin tienda seleccionada).
  void reset() {
    if (_tiendaId == null && _token == null) return;
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

  /// Cambia de tienda: descarta los datos de la anterior.
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

  /// Respaldo: normalmente el ProxyProvider de main.dart ya mantiene el
  /// contexto al día. Solo usa la tienda SELECCIONADA, nunca la del login.
  void ensureInitialized(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tiendaProvider = Provider.of<TiendaProvider>(
        context,
        listen: false,
      );

      final token = authProvider.token;
      final tiendaId = tiendaProvider.tiendaSeleccionadaId;

      if (token != null && tiendaId != null) {
        updateTiendaContext(token, tiendaId);
      }
    } catch (e) {
      // Ignorar error silenciosamente
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Categorías ──────────────────────────────────────────

  Future<void> loadCategories() async {
    if (_categoryService == null || _tiendaId == null) return;
    final requestedId = _tiendaId!;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _categoryService!.getCategories(requestedId);
      if (_tiendaId != requestedId) return; // la tienda cambió: descartar
      _categories = result;
    } catch (e) {
      if (_tiendaId == requestedId) _error = e.toString();
    } finally {
      if (_tiendaId == requestedId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> createCategory(inventory_category.Category category) async {
    if (_categoryService == null) return;
    final storeId = _tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newCategory = await _categoryService!.createCategory(category);
      if (_tiendaId == storeId) _categories.add(newCategory);
      _error = null;
    } catch (e) {
      if (_tiendaId == storeId) _error = e.toString();
      rethrow;
    } finally {
      if (_tiendaId == storeId) _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(
    String id,
    inventory_category.Category category,
  ) async {
    if (_categoryService == null) return;
    final storeId = _tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _categoryService!.updateCategory(id, category);
      if (_tiendaId == storeId) {
        final index = _categories.indexWhere((c) => c.id == id);
        if (index != -1) _categories[index] = updated;
      }
      _error = null;
    } catch (e) {
      if (_tiendaId == storeId) _error = e.toString();
      rethrow;
    } finally {
      if (_tiendaId == storeId) _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    if (_categoryService == null) return;
    final storeId = _tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService!.deleteCategory(id);
      if (_tiendaId == storeId) _categories.removeWhere((c) => c.id == id);
      _error = null;
    } catch (e) {
      if (_tiendaId == storeId) _error = e.toString();
      rethrow;
    } finally {
      if (_tiendaId == storeId) _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Productos ───────────────────────────────────────────

  Future<void> loadProducts() async {
    if (_productService == null || _tiendaId == null) return;
    final requestedId = _tiendaId!;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _productService!.getProductsByStore(requestedId);
      if (_tiendaId != requestedId) return; // la tienda cambió: descartar
      _products = result;
    } catch (e) {
      if (_tiendaId == requestedId) _error = e.toString();
    } finally {
      if (_tiendaId == requestedId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<Product?> createProduct(Product product, {File? imagenFile}) async {
    if (_productService == null) return null;
    final storeId = _tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newProduct = await _productService!.createProduct(
        product,
        imagenFile: imagenFile,
      );
      if (_tiendaId == storeId) _products.add(newProduct);
      _error = null;
      return newProduct;
    } catch (e) {
      if (_tiendaId == storeId) _error = e.toString();
      rethrow;
    } finally {
      if (_tiendaId == storeId) _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> updateProduct(
    String id,
    Product product, {
    File? imagenFile,
  }) async {
    if (_productService == null) return null;
    final storeId = _tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _productService!.updateProduct(
        id,
        product,
        imagenFile: imagenFile,
      );
      if (_tiendaId == storeId) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) _products[index] = updated;
      }
      _error = null;
      return updated;
    } catch (e) {
      if (_tiendaId == storeId) _error = e.toString();
      rethrow;
    } finally {
      if (_tiendaId == storeId) _isLoading = false;
      notifyListeners();
    }
  }

  /// Activar/desactivar producto con un solo clic.
  Future<void> toggleProductActive(String productId, bool nuevoEstado) async {
    if (_productService == null) return;
    final storeId = _tiendaId;

    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final productoActual = _products[index];

    final productoActualizado = Product(
      id: productoActual.id,
      tiendaId: productoActual.tiendaId,
      categoriaId: productoActual.categoriaId,
      nombre: productoActual.nombre,
      descripcion: productoActual.descripcion,
      codigoBarras: productoActual.codigoBarras,
      tipoVenta: productoActual.tipoVenta,
      unidadMedida: productoActual.unidadMedida,
      precioVenta: productoActual.precioVenta,
      activo: nuevoEstado,
      imagenUrl: productoActual.imagenUrl,
      categoria: productoActual.categoria,
    );

    await _productService!.updateProduct(productId, productoActualizado);
    if (_tiendaId != storeId) return;
    final i = _products.indexWhere((p) => p.id == productId);
    if (i != -1) _products[i] = productoActualizado;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    if (_productService == null) return;
    final storeId = _tiendaId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _productService!.deleteProduct(id);
      if (_tiendaId == storeId) _products.removeWhere((p) => p.id == id);
      _error = null;
    } catch (e) {
      if (_tiendaId == storeId) _error = e.toString();
      rethrow;
    } finally {
      if (_tiendaId == storeId) _isLoading = false;
      notifyListeners();
    }
  }
}