import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/category.dart';
import '../../domain/inventory_exception.dart';

class CategoryService {
  final Dio _dio;

  CategoryService({String? token}) : _dio = DioClient.create() {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Category>> getCategories(String tiendaId) async {
    try {
      final response = await _dio.get(
        '/categorias',
        queryParameters: {'tienda_id': tiendaId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> categoriesJson = data['categorias'] ?? data;
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<Category> createCategory(Category category) async {
    try {
      final response = await _dio.post('/categorias', data: category.toJson());

      if (response.statusCode == 201) {
        final data = response.data;
        return Category.fromJson(data['categoria'] ?? data);
      } else {
        final error = response.data;
        throw Exception(error['error'] ?? 'Error al crear categoría');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final error = e.response!.data;
        throw Exception(error['error'] ?? 'Error al crear categoría');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<Category> updateCategory(String id, Category category) async {
    try {
      final response = await _dio.put(
        '/categorias/$id',
        data: category.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Category.fromJson(data['categoria'] ?? data);
      } else {
        final error = response.data;
        throw Exception(error['error'] ?? 'Error al actualizar categoría');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final error = e.response!.data;
        throw Exception(error['error'] ?? 'Error al actualizar categoría');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<void> deleteCategory(String id) async {
    const fallback = 'No se pudo eliminar la categoría. Intenta de nuevo.';
    try {
      await _dio.delete('/categorias/$id');
    } on DioException catch (e) {
      final data = e.response?.data;
      final backendMessage = data is Map ? data['error'] : null;
      if (e.response?.statusCode == 409 &&
          backendMessage is String &&
          backendMessage.trim().isNotEmpty) {
        throw InventoryException(backendMessage);
      }
      throw const InventoryException(fallback);
    }
  }
}
