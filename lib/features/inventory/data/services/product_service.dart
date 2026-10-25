import 'dart:io';

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

  // ✅ MÉTODO ACTUALIZADO PARA ENVIAR IMAGEN CON FORMDATA
  Future<Product> createProduct(Product product, {File? imagenFile}) async {
    try {
      // Si hay imagen, usamos FormData; si no, enviamos JSON normal
      if (imagenFile != null) {
        String fileName = imagenFile.path.split('/').last;
        FormData formData = FormData.fromMap({
          'nombre': product.nombre,
          'tienda_id': product.tiendaId,
          'categoria_id': product.categoriaId,
          'descripcion': product.descripcion ?? '',
          'codigo_barras': product.codigoBarras ?? '',
          'tipo_venta': product.tipoVenta.value,
          'unidad_medida': product.unidadMedida,
          'precio_venta': product.precioVenta.toString(),
          'activo': product.activo.toString(),
          'imagen': await MultipartFile.fromFile(
            imagenFile.path,
            filename: fileName,
          ),
        });

        final response = await _dio.post(
          '/productos',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data;
          return Product.fromJson(data['producto'] ?? data);
        } else {
          throw Exception(
            'Error HTTP ${response.statusCode}: ${response.data}',
          );
        }
      } else {
        // Sin imagen, enviamos JSON normal
        final response = await _dio.post('/productos', data: product.toJson());

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data;
          return Product.fromJson(data['producto'] ?? data);
        } else {
          throw Exception(
            'Error HTTP ${response.statusCode}: ${response.data}',
          );
        }
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMsg =
            e.response!.data['error'] ??
            e.response!.data['message'] ??
            'Error desconocido';
        throw Exception('Backend dice: $errorMsg');
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // ✅ MÉTODO ACTUALIZADO PARA ACTUALIZAR CON IMAGEN
  Future<Product> updateProduct(
    String id,
    Product product, {
    File? imagenFile,
  }) async {
    try {
      if (imagenFile != null) {
        String fileName = imagenFile.path.split('/').last;
        FormData formData = FormData.fromMap({
          'nombre': product.nombre,
          'categoria_id': product.categoriaId,
          'descripcion': product.descripcion ?? '',
          'codigo_barras': product.codigoBarras ?? '',
          'tipo_venta': product.tipoVenta.value,
          'unidad_medida': product.unidadMedida,
          'precio_venta': product.precioVenta.toString(),
          'activo': product.activo.toString(),
          'imagen': await MultipartFile.fromFile(
            imagenFile.path,
            filename: fileName,
          ),
        });

        final response = await _dio.put(
          '/productos/$id',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          return Product.fromJson(data['producto'] ?? data);
        } else {
          throw Exception(
            'Error HTTP ${response.statusCode}: ${response.data}',
          );
        }
      } else {
        final response = await _dio.put(
          '/productos/$id',
          data: product.toJson(),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          return Product.fromJson(data['producto'] ?? data);
        } else {
          throw Exception(
            'Error HTTP ${response.statusCode}: ${response.data}',
          );
        }
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorMsg =
            e.response!.data['error'] ??
            e.response!.data['message'] ??
            'Error desconocido';
        throw Exception('Backend dice: $errorMsg');
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
