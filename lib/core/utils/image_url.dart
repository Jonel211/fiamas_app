import '../network/dio_client.dart';

/// Devuelve una URL absoluta lista para `Image.network`.
///
/// El backend puede responder rutas relativas (por ejemplo
/// `/uploads/foto.jpg`). En ese caso se resuelven contra el origen del API.
/// Las URLs absolutas (Cloudinary, http, https, data) se devuelven intactas.
String? resolveImageUrl(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  if (value.startsWith('data:') || value.startsWith('blob:')) return value;
  if (value.startsWith('//')) return 'https:$value';

  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme && uri.scheme.startsWith('http')) {
    return value;
  }

  final base = Uri.parse(DioClient.baseUrl);
  final origin =
      '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';

  if (value.startsWith('/')) return '$origin$value';
  return '$origin/$value';
}
