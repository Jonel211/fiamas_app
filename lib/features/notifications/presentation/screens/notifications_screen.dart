import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/app_notification.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_group_header.dart';
import '../../data/notification_repository.dart';

/// Pantalla "Notificaciones" del tendero.
/// Se abre al tocar la campanita del dashboard.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationRepository();
  List<AppNotification> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.fetchAll();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las notificaciones.';
        _loading = false;
      });
    }
  }

  int get _unread => _items.where((n) => !n.isRead).length;

  // Actualiza al instante y revierte si la API falla
  Future<void> _markAsRead(String id) async {
    final previous = _items;
    setState(
      () => _items = [for (final n in _items) n.id == id ? n.markAsRead() : n],
    );
    try {
      await _repo.markAsRead(id);
    } catch (_) {
      if (mounted) setState(() => _items = previous);
    }
  }

  Future<void> _markAllAsRead() async {
    final previous = _items;
    setState(() => _items = [for (final n in _items) n.markAsRead()]);
    try {
      await _repo.markAllAsRead();
    } catch (_) {
      if (mounted) setState(() => _items = previous);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(unread: _unread),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!),
                              TextButton(
                                onPressed: _load,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: Text('No tienes notificaciones'),
                                  ),
                                ),
                              for (final group in NotificationGroup.values)
                                ..._buildGroup(group),
                            ],
                          ),
                        ),
            ),
          ],
        ),
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
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: AppColors.ink),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _roundButton(Icons.arrow_back, () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  unread == 0 ? 'Todo al día' : '$unread sin leer',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          // TODO: opciones de notificaciones (el ícono exacto está en Figma).
          _roundButton(Icons.delete_sweep_outlined, () {}),
        ],
      ),
    );
  }
}