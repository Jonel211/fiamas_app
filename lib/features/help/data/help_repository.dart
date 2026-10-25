import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class HelpRepository {
  HelpRepository([Dio? dio]) : _dio = dio ?? DioClient.create();
  final Dio _dio;

  Future<void> enviarMensajeAyuda({
    required String asunto,
    required String mensaje,
    String prioridad = 'media',
  }) async {
    try {
      await _dio.post(
        '/avisos/ayuda',
        data: {
          'asunto': asunto.trim(),
          'mensaje': mensaje.trim(),
          'prioridad': prioridad,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['msg'] ??
          e.response?.data?['error'] ??
          'Error al enviar el mensaje de ayuda. Intente nuevamente.';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado al enviar el mensaje de ayuda');
    }
  }
}
