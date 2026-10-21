import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/app_notification.dart';

/// Colores e ícono de cada tipo de aviso.
/// Colores e ícono de cada notificación.
({IconData icon, Color color, Color bg}) _styleOf(AppNotification n) {
  switch (n.type) {
    case NotificationType.adminNotice:
      switch (n.priority) {
        case 'alta':
        case 'urgente':
          return (icon: Icons.campaign_outlined, color: const Color(0xFFC62828), bg: const Color(0xFFFDECEC));
        case 'baja':
          return (icon: Icons.campaign_outlined, color: const Color(0xFF5F6B7A), bg: const Color(0xFFE9EDF2));
        default:
          return (icon: Icons.campaign_outlined, color: const Color(0xFFD98A1B), bg: const Color(0xFFFFF3D6));
      }
    case NotificationType.urgent:
    case NotificationType.collection:
      return (icon: Icons.warning_amber_rounded, color: const Color(0xFFC62828), bg: const Color(0xFFFDECEC));
    case NotificationType.creditLimit:
      return (icon: Icons.notifications_active_outlined, color: const Color(0xFFD98A1B), bg: const Color(0xFFFFF3D6));
    case NotificationType.dueSoon:
      return (icon: Icons.event_busy_outlined, color: const Color(0xFFD98A1B), bg: const Color(0xFFFFF3D6));
    case NotificationType.overdue:
      return (icon: Icons.history_toggle_off_rounded, color: const Color(0xFFC62828), bg: const Color(0xFFFDECEC));
  }
}

/// Tarjeta de una notificación. Las leídas se ven más apagadas y sin punto.
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final style = _styleOf(n);
    final read = n.isRead;

    return Material(
      color: read ? const Color(0xFFF1F4F8) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: read ? 0 : 1.5,
      shadowColor: AppColors.ink.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Ícono del tipo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: read ? style.bg.withValues(alpha: 0.6) : style.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: read ? const Color(0xFFE3E8EE) : style.bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(n.type.label,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: read ? AppColors.inkMuted : style.color)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(n.timeLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(n.title,
                    style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: read ? FontWeight.w600 : FontWeight.w700,
                        color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(n.body, style: const TextStyle(fontSize: 13, height: 1.3, color: AppColors.inkMuted)),
              ]),
            ),
            // Punto de "sin leer"
            if (!read)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
              ),
          ]),
        ),
      ),
    );
  }
}