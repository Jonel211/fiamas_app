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

  String? get tiendaId => _tiendaId;

  void updateTiendaContext(String token, String nuevaTiendaId) {
    if (_tiendaId != nuevaTiendaId || _token != token) {
      _tiendaId = nuevaTiendaId;
      _token = token;
      _products = [];
      _categories = [];
      _error = null;
      _productService = ProductService(token: token);
      _categoryService = CategoryService(token: token);
      notifyListeners();
    }
  }

  void ensureInitialized(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tiendaProvider = Provider.of<TiendaProvider>(
        context,
        listen: false,
      );

      final token = authProvider.token;
      final tiendaId =
          tiendaProvider.tiendaSeleccionadaId ?? authProvider.tiendaId;

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

  Future<void> loadCategories() async {
    if (_categoryService == null || _tiendaId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _categoryService!.getCategories(_tiendaId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(inventory_category.Category category) async {
    if (_categoryService == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newCategory = await _categoryService!.createCategory(category);
      _categories.add(newCategory);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
    if (_categoryService == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _categoryService!.updateCategory(id, category);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) _categories[index] = updated;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    if (_categoryService == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService!.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    if (_productService == null || _tiendaId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _productService!.getProductsByStore(_tiendaId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> createProduct(Product product, {File? imagenFile}) async {
    if (_productService == null) return null;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newProduct = await _productService!.createProduct(
        product,
        imagenFile: imagenFile,
      );
      _products.add(newProduct);
      _error = null;
      notifyListeners();
      return newProduct;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


   Future<Product?> updateProduct(
    String id,
    Product product, {
    File? imagenFile,
  }) async {
    if (_productService == null) return null;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _productService!.updateProduct(
        id,
        product,
        imagenFile: imagenFile,
      );
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) _products[index] = updated;
      _error = null;
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NUEVO MÉTODO: Activar/Desactivar producto con un solo clic
  Future<void> toggleProductActive(String productId, bool nuevoEstado) async {
    if (_productService == null) return;

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

    try {
      await _productService!.updateProduct(productId, productoActualizado);
      _products[index] = productoActualizado;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_productService == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _productService!.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
