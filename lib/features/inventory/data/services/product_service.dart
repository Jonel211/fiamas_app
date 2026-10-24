import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/product.dart';


class ProductService {
  final Dio _dio;

  ProductService({String? token}) : _dio = DioClient.create() {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Product>> getProductsByStore(String tiendaId) async {
    try {
      final response = await _dio.get('/productos/tienda/$tiendaId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post('/productos', data: product.toJson());

      if (response.statusCode == 201) {
        final data = response.data;
        return Product.fromJson(data['producto'] ?? data);
      } else {
        final error = response.data;
        throw Exception(error['error'] ?? 'Error al crear producto');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final error = e.response!.data;
        throw Exception(error['error'] ?? 'Error al crear producto');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await _dio.put('/productos/$id', data: product.toJson());

      if (response.statusCode == 200) {
        final data = response.data;
        return Product.fromJson(data['producto'] ?? data);
      } else {
        final error = response.data;
        throw Exception(error['error'] ?? 'Error al actualizar producto');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final error = e.response!.data;
        throw Exception(error['error'] ?? 'Error al actualizar producto');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _dio.delete('/productos/$id');

      if (response.statusCode != 200) {
        final error = response.data;
        throw Exception(error['error'] ?? 'Error al eliminar producto');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final error = e.response!.data;
        throw Exception(error['error'] ?? 'Error al eliminar producto');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  Future<List<Product>> searchProducts(String query, String tiendaId) async {
    try {
      final response = await _dio.get(
        '/productos/buscar',
        queryParameters: {'q': query, 'tienda_id': tiendaId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar productos');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}
