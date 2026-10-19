import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/app_notification.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_group_header.dart';

/// Pantalla "Notificaciones" del tendero.
/// Se abre al tocar la campanita del dashboard.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: reemplazar por las notificaciones reales (API).
  List<AppNotification> _items = const [
    AppNotification(
      id: '1', type: NotificationType.urgent, group: NotificationGroup.today,
      title: 'Doña Martha Gómez alcanzó su límite',
      body: 'Está al 100% de su crédito autorizado (S/ 500.00)',
      timeLabel: 'Hace 2 horas',
    ),
    AppNotification(
      id: '2', type: NotificationType.creditLimit, group: NotificationGroup.today,
      title: 'Don Roberto Ruiz está al 80% de su límite',
      body: 'Le queda S/ 100.00 de crédito disponible',
      timeLabel: 'Hace 5 horas',
    ),
    AppNotification(
      id: '3', type: NotificationType.dueSoon, group: NotificationGroup.today,
      title: 'Don Roberto Ruiz debe S/ 95.00',
      body: 'Fiado vencido hace 7 días',
      timeLabel: 'Hace 6 horas', isRead: true,
    ),
    AppNotification(
      id: '4', type: NotificationType.collection, group: NotificationGroup.yesterday,
      title: 'Luis Paredes debe S/ 150.00',
      body: 'Fiado vencido hace 15 días',
      timeLabel: 'Ayer 6:15 pm',
    ),
    AppNotification(
      id: '5', type: NotificationType.creditLimit, group: NotificationGroup.thisWeek,
      title: 'Ana Quispe está al 80% de su límite',
      body: 'Le queda S/ 60.00 de crédito disponible',
      timeLabel: 'Hace 3 días', isRead: true,
    ),
    AppNotification(
      id: '6', type: NotificationType.overdue, group: NotificationGroup.older,
      title: 'Pedro Sánchez debe S/ 22.50',
      body: 'Fiado vencido hace 20 días',
      timeLabel: 'Hace 2 semanas', isRead: true,
    ),
  ];

  int get _unread => _items.where((n) => !n.isRead).length;

  void _markAsRead(String id) => setState(() {
        _items = [for (final n in _items) n.id == id ? n.markAsRead() : n];
      });

  void _markAllAsRead() => setState(() {
        _items = [for (final n in _items) n.markAsRead()];
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _Header(unread: _unread),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                OutlinedButton.icon(
                  onPressed: _unread == 0 ? null : _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded, size: 20),
                  label: const Text('Marcar todas como leídas'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.mist),
                    minimumSize: const Size.fromHeight(46),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                for (final group in NotificationGroup.values)
                  ..._buildGroup(group),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildGroup(NotificationGroup group) {
    final items = _items.where((n) => n.group == group).toList();
    if (items.isEmpty) return const [];

    return [
      NotificationGroupHeader(
        title: group.label,
        pending: items.where((n) => !n.isRead).length,
      ),
      const SizedBox(height: 10),
      for (final n in items) ...[
        NotificationCard(notification: n, onTap: () => _markAsRead(n.id)),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 12),
    ];
  }
}

/// Barra superior: flecha, título con contador de "sin leer" y botón de opciones.
class _Header extends StatelessWidget {
  const _Header({required this.unread});

  final int unread;

  Widget _roundButton(IconData icon, VoidCallback onTap) => Material(
        color: AppColors.surface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.mist)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: AppColors.ink)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        _roundButton(Icons.arrow_back, () => Navigator.of(context).pop()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Text('Notificaciones',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
            Text(unread == 0 ? 'Todo al día' : '$unread sin leer',
                style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
          ]),
        ),
        // TODO: opciones de notificaciones (el ícono exacto está en Figma).
        _roundButton(Icons.delete_sweep_outlined, () {}),
      ]),
    );
  }
}