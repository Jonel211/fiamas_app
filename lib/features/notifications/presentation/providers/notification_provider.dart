import 'package:flutter/material.dart';

import '../../data/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider([NotificationRepository? repository])
      : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  Future<void> refresh() async {
    try {
      final count = await _repository.unreadCount();
      setUnread(count);
    } catch (_) {
      // Conserva el último valor conocido si falla la consulta.
    }
  }

  void setUnread(int n) {
    final value = n < 0 ? 0 : n;
    if (_unreadCount == value) return;
    _unreadCount = value;
    notifyListeners();
  }
}
