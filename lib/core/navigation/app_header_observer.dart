import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_bar_controller.dart';

class AppHeaderObserver extends NavigatorObserver {
  AppBarController? _controller;

  AppBarController? _resolveController(Route<dynamic> route) {
    final cached = _controller;
    if (cached != null) return cached;

    final context = route.navigator?.context;
    if (context == null) return null;

    try {
      return _controller = Provider.of<AppBarController>(
        context,
        listen: false,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isPageRoute(Route<dynamic>? route) => route is PageRoute<dynamic>;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!_isPageRoute(route)) return;

    _resolveController(route)?.setActiveRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (!_isPageRoute(route)) return;

    final controller = _resolveController(route);
    if (controller == null) return;

    controller.setActiveRoute(
      _isPageRoute(previousRoute) ? previousRoute : null,
    );
    controller.clearRoute(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (!_isPageRoute(route)) return;

    final controller = _resolveController(route);
    if (controller == null) return;

    if (controller.activeRoute == route) {
      controller.setActiveRoute(
        _isPageRoute(previousRoute) ? previousRoute : null,
      );
    }
    controller.clearRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (!_isPageRoute(newRoute)) {
      if (_isPageRoute(oldRoute)) {
        _resolveController(oldRoute!)?.clearRoute(oldRoute);
      }
      return;
    }

    final controller = _resolveController(newRoute!);
    if (controller == null) return;

    if (oldRoute == null || controller.activeRoute == oldRoute) {
      controller.setActiveRoute(newRoute);
    }
    if (_isPageRoute(oldRoute)) {
      controller.clearRoute(oldRoute!);
    }
  }
}
