import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_bar_controller.dart';

class AppHeaderConfig extends StatefulWidget {
  const AppHeaderConfig({
    super.key,
    this.visible = true,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.leading,
    this.centerTitle = false,
    this.actions = const [],
    required this.child,
  });

  final bool visible;
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool centerTitle;
  final List<Widget> actions;
  final Widget child;

  @override
  State<AppHeaderConfig> createState() => _AppHeaderConfigState();
}

class _AppHeaderConfigState extends State<AppHeaderConfig> {
  AppBarController? _controller;
  Route<dynamic>? _route;
  HeaderConfig? _registeredConfig;
  bool _registrationScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = Provider.of<AppBarController>(context, listen: false);
    _route = ModalRoute.of(context);
    _scheduleRegistration();
  }

  @override
  void didUpdateWidget(covariant AppHeaderConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasChanged(oldWidget)) {
      _scheduleRegistration();
    }
  }

  bool _hasChanged(AppHeaderConfig oldWidget) {
    return oldWidget.visible != widget.visible ||
        oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle ||
        oldWidget.showBack != widget.showBack ||
        oldWidget.onBack != widget.onBack ||
        oldWidget.leading != widget.leading ||
        oldWidget.centerTitle != widget.centerTitle ||
        !_listEquals(oldWidget.actions, widget.actions);
  }

  void _scheduleRegistration() {
    if (_registrationScheduled) return;
    _registrationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registrationScheduled = false;
      if (!mounted) return;

      final route = _route;
      final controller = _controller;
      if (route == null || controller == null) return;

      final config = HeaderConfig(
        visible: widget.visible,
        title: widget.title,
        subtitle: widget.subtitle,
        showBack: widget.showBack,
        onBack:
            widget.onBack ??
            (widget.showBack ? () => Navigator.of(context).maybePop() : null),
        leading: widget.leading,
        centerTitle: widget.centerTitle,
        actions: widget.actions,
      );

      _registeredConfig = config;
      controller.registerRoute(route, config);
    });
  }

  @override
  void dispose() {
    final controller = _controller;
    final route = _route;
    final config = _registeredConfig;
    if (controller != null && route != null && config != null) {
      controller.clearRouteIfMatches(route, config);
    }
    super.dispose();
  }

  bool _listEquals(List<Widget> a, List<Widget> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
