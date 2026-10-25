import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/category.dart';

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
    try {
      final response = await _dio.delete('/categorias/$id');

      if (response.statusCode != 200) {
        final error = response.data;
        throw Exception(error['error'] ?? 'Error al eliminar categoría');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final error = e.response!.data;
        throw Exception(error['error'] ?? 'Error al eliminar categoría');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}
