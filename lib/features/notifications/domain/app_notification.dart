/// Tipos de aviso que recibe el tendero.
enum NotificationType {
  adminNotice('Aviso de Fiamas'),
  urgent('Atención urgente'),
  creditLimit('Aviso de cupo'),
  dueSoon('Vencimiento'),
  collection('Cobranza pendiente'),
  overdue('Plazo vencido');

  const NotificationType(this.label);
  final String label;
}

/// Grupo de fecha en el que se muestra una notificación.
enum NotificationGroup {
  today('Hoy'),
  yesterday('Ayer'),
  thisWeek('Esta semana'),
  older('Anteriores');

  const NotificationGroup(this.label);
  final String label;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.group,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.priority = 'media',
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final NotificationGroup group;
  final String title;
  final String body;

  /// Texto ya formateado, ej: "Hace 2 horas".
  final String timeLabel;

  /// baja | media | alta | urgente (viene del backend).
  final String priority;
  final bool isRead;

  AppNotification markAsRead() => AppNotification(
        id: id,
        type: type,
        group: group,
        title: title,
        body: body,
        timeLabel: timeLabel,
        priority: priority,
        isRead: true,
      );
}