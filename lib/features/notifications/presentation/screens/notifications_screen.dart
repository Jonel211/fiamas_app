import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../data/notification_repository.dart';
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
  final NotificationRepository _repo = NotificationRepository();

  List<AppNotification> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  int get _unread => _items.where((n) => !n.isRead).length;

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

  Future<void> _markAsRead(String id) async {
    final previous = _items;

    setState(() {
      _items = [
        for (final n in _items) n.id == id ? n.markAsRead() : n,
      ];
    });

    try {
      await _repo.markAsRead(id);
    } catch (_) {
      if (mounted) setState(() => _items = previous);
    }
  }

  Future<void> _markAllAsRead() async {
    final previous = _items;

    setState(() {
      _items = [for (final n in _items) n.markAsRead()];
    });

    try {
      await _repo.markAllAsRead();
    } catch (_) {
      if (mounted) setState(() => _items = previous);
    }
  }

  Future<void> _clearAll() async {
    if (_items.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '¿Eliminar notificaciones?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Se vaciará tu bandeja de notificaciones. Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.inkMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final previous = _items;
    setState(() => _items = const []);

    try {
      await _repo.clearAll();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificaciones eliminadas correctamente'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _items = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar las notificaciones'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Notificaciones',
              subtitle: _unread == 0 ? 'Todo al día' : '$_unread sin leer',
              showBack: true,
              centerTitle: true,
              actions: [
                AppHeaderIconAction(
                  icon: Icons.delete_sweep_outlined,
                  onTap: _items.isEmpty ? () {} : _clearAll,
                ),
              ],
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
      );
    }

    return RefreshIndicator(
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
          for (final group in NotificationGroup.values) ..._buildGroup(group),
        ],
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
        NotificationCard(
          notification: n,
          onTap: () => _markAsRead(n.id),
        ),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 12),
    ];
  }
}