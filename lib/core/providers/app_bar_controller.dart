import 'package:flutter/material.dart';

class HeaderConfig {
  const HeaderConfig({
    this.visible = true,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.leading,
    this.centerTitle = false,
    this.actions = const [],
  });

  final bool visible;
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool centerTitle;
  final List<Widget> actions;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is HeaderConfig &&
        other.visible == visible &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.showBack == showBack &&
        other.onBack == onBack &&
        other.leading == leading &&
        other.centerTitle == centerTitle &&
        _listEquals(other.actions, actions);
  }

  @override
  int get hashCode {
    return Object.hash(
      visible,
      title,
      subtitle,
      showBack,
      onBack,
      leading,
      centerTitle,
      Object.hashAll(actions),
    );
  }

  static bool _listEquals(List<Widget> a, List<Widget> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class AppBarController extends ChangeNotifier {
  final Map<Route<dynamic>, HeaderConfig> _routeConfigs = {};
  final Set<Route<dynamic>> _pendingResolutions = {};
  Route<dynamic>? _activeRoute;
  HeaderConfig? _activeConfig;
  HeaderConfig? _lastConfig;
  Route<dynamic>? _pendingRoute;
  bool _notificationScheduled = false;

  HeaderConfig? get activeConfig => _activeConfig;
  Route<dynamic>? get activeRoute => _activeRoute;

  void registerRoute(
    Route<dynamic> route,
    HeaderConfig config, {
    bool notify = true,
  }) {
    final oldConfig = _routeConfigs[route];
    if (oldConfig == config) {
      if (_activeRoute == route && _pendingRoute == route) {
        _pendingRoute = null;
      }
      return;
    }

    _routeConfigs[route] = config;

    if (_activeRoute != route) return;

    _pendingRoute = null;
    final changed = _setActiveConfig(config);
    if (!changed) return;

    if (notify) {
      notifyListeners();
    } else {
      _scheduleNotification();
    }
  }

  void setActiveRoute(Route<dynamic>? route) {
    if (_activeRoute == route) return;

    _activeRoute = route;

    if (route == null) {
      _pendingRoute = null;
      _lastConfig = null;
      if (_setActiveConfig(null)) {
        notifyListeners();
      }
      return;
    }

    final registeredConfig = _routeConfigs[route];
    if (registeredConfig != null) {
      _pendingRoute = null;
      if (_setActiveConfig(registeredConfig)) {
        notifyListeners();
      }
      return;
    }

    _pendingRoute = route;
    if (_setActiveConfig(_lastConfig)) {
      notifyListeners();
    }
    _schedulePendingResolution(route);
  }

  void clearRoute(Route<dynamic> route) {
    final removed = _routeConfigs.remove(route);
    if (removed == null) return;

    if (_activeRoute == route) {
      _activeRoute = null;
      _pendingRoute = null;
      _lastConfig = null;
      if (_setActiveConfig(null)) {
        notifyListeners();
      }
    }
  }

  void clearRouteIfMatches(Route<dynamic> route, HeaderConfig config) {
    if (_routeConfigs[route] != config) return;
    clearRoute(route);
  }

  bool _setActiveConfig(HeaderConfig? config) {
    final changed = _activeConfig != config;
    _activeConfig = config;
    _lastConfig = config;
    return changed;
  }

  void _schedulePendingResolution(Route<dynamic> route) {
    if (!_pendingResolutions.add(route)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingResolutions.remove(route);
      if (_pendingRoute != route || _activeRoute != route) return;

      if (_routeConfigs.containsKey(route)) {
        _pendingRoute = null;
        return;
      }

      _pendingRoute = null;
      _lastConfig = null;
      if (_setActiveConfig(null)) {
        notifyListeners();
      }
    });
  }

  void _scheduleNotification() {
    if (_notificationScheduled) return;
    _notificationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationScheduled = false;
      notifyListeners();
    });
  }

  // API legacy conservada para AppShellScaffold / AppShell.
  String _title = '';
  bool _showBack = false;
  VoidCallback? _onBack;
  List<Widget> _actions = const [];
  Color? _backgroundColor;
  Color? _foregroundColor;
  bool _centerTitle = true;
  double _elevation = 0;

  String get title => _title;
  bool get showBack => _showBack;
  VoidCallback? get onBack => _onBack;
  List<Widget> get actions => _actions;
  Color? get backgroundColor => _backgroundColor;
  Color? get foregroundColor => _foregroundColor;
  bool get centerTitle => _centerTitle;
  double get elevation => _elevation;

  void setConfig({
    required String title,
    bool showBack = false,
    VoidCallback? onBack,
    List<Widget> actions = const [],
    Color? backgroundColor,
    Color? foregroundColor,
    bool centerTitle = true,
    double elevation = 0,
  }) {
    _title = title;
    _showBack = showBack;
    _onBack = onBack;
    _actions = actions;
    _backgroundColor = backgroundColor;
    _foregroundColor = foregroundColor;
    _centerTitle = centerTitle;
    _elevation = elevation;
    notifyListeners();
  }

  void clear() {
    setConfig(title: '');
  }
}
