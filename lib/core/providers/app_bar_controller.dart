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
  Route<dynamic>? _activeRoute;
  HeaderConfig? _activeConfig;

  HeaderConfig? get activeConfig => _activeConfig;
  Route<dynamic>? get activeRoute => _activeRoute;

  void registerRoute(Route<dynamic> route, HeaderConfig config) {
    final oldConfig = _routeConfigs[route];
    if (oldConfig == config) return;

    _routeConfigs[route] = config;
    if (_activeRoute == route && _activeConfig != config) {
      _activeConfig = config;
      notifyListeners();
    }
  }

  void setActiveRoute(Route<dynamic>? route) {
    if (_activeRoute == route) return;

    _activeRoute = route;
    final newConfig = route == null ? null : _routeConfigs[route];
    if (_activeConfig != newConfig) {
      _activeConfig = newConfig;
      notifyListeners();
    }
  }

  void clearRoute(Route<dynamic> route) {
    final removed = _routeConfigs.remove(route);
    if (removed == null) return;

    if (_activeRoute == route) {
      _activeRoute = null;
      if (_activeConfig != null) {
        _activeConfig = null;
        notifyListeners();
      }
    }
  }

  void clearRouteIfMatches(Route<dynamic> route, HeaderConfig config) {
    if (_routeConfigs[route] != config) return;
    clearRoute(route);
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
