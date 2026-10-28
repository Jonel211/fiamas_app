import 'dart:io';

import 'package:dio/dio.dart';

/// Arma el archivo para subirlo indicando que es una imagen.
Future<MultipartFile> imageMultipart(File file) {
  final name = file.path.split(Platform.pathSeparator).last;
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpeg';
  final subtype = ext == 'jpg' ? 'jpeg' : ext;

  return MultipartFile.fromFile(
    file.path,
    filename: name,
    contentType: DioMediaType('image', subtype),
  );
}