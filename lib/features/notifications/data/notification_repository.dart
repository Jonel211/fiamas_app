import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/app_notification.dart';

class NotificationRepository {
  NotificationRepository([Dio? dio]) : _dio = dio ?? DioClient.create();
  final Dio _dio;

  Future<List<AppNotification>> fetchAll() async {
    final res = await _dio.get('/notificaciones');
    final items = (res.data['items'] as List).cast<Map<String, dynamic>>();
    return items.map(_fromJson).toList();
  }

  Future<int> unreadCount() async {
    final res = await _dio.get('/notificaciones/no-leidas/count');
    return res.data['count'] as int;
  }

  Future<void> markAsRead(String id) => _dio.patch('/notificaciones/$id/leer');
  Future<void> markAllAsRead() => _dio.patch('/notificaciones/leer-todas');
  Future<void> clearAll() => _dio.delete('/notificaciones/limpiar');

  AppNotification _fromJson(Map<String, dynamic> j) {
    final date = DateTime.parse(j['fecha'] as String).toLocal();
    return AppNotification(
      id: j['id'] as String,
      type: _type(j['tipo'] as String, j['prioridad'] as String? ?? 'media'),
      group: _group(date),
      title: j['titulo'] as String,
      body: j['mensaje'] as String,
      timeLabel: _timeLabel(date),
      priority: j['prioridad'] as String? ?? 'media',
      isRead: j['leida'] as bool,
    );
  }

  NotificationType _type(String tipo, String prioridad) {
    switch (tipo) {
      case 'limite_credito':
        return (prioridad == 'urgente' || prioridad == 'alta')
            ? NotificationType.urgent
            : NotificationType.creditLimit;
      case 'recordatorio_pago':
        return NotificationType.collection;
      default: // aviso_admin y cualquier otro
        return NotificationType.adminNotice;
    }
  }

  NotificationGroup _group(DateTime d) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (days <= 0) return NotificationGroup.today;
    if (days == 1) return NotificationGroup.yesterday;
    if (days < 7) return NotificationGroup.thisWeek;
    return NotificationGroup.older;
  }

  String _timeLabel(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    final group = _group(d);
    if (group == NotificationGroup.today) {
      final h = diff.inHours;
      return 'Hace $h ${h == 1 ? 'hora' : 'horas'}';
    }
    if (group == NotificationGroup.yesterday) {
      final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final min = d.minute.toString().padLeft(2, '0');
      return 'Ayer $h12:$min ${d.hour >= 12 ? 'pm' : 'am'}';
    }
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    final w = diff.inDays ~/ 7;
    return 'Hace $w ${w == 1 ? 'semana' : 'semanas'}';
  }
}