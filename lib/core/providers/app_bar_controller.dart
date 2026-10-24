import 'package:flutter/material.dart';

class AppBarController extends ChangeNotifier {
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