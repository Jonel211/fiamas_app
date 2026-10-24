import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_bar_controller.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final appBarCtrl = context.watch<AppBarController>();
    final hasTitle = appBarCtrl.title.isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.ivory,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: hasTitle
          ? AppBar(
              backgroundColor: appBarCtrl.backgroundColor ?? AppColors.teal,
              foregroundColor: appBarCtrl.foregroundColor ?? Colors.white,
              elevation: appBarCtrl.elevation,
              centerTitle: appBarCtrl.centerTitle,
              leading: appBarCtrl.showBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: appBarCtrl.onBack ??
                          () => Navigator.of(context).maybePop(),
                      splashRadius: 22,
                    )
                  : null,
              title: Text(
                appBarCtrl.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: appBarCtrl.actions,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, this.bottomNavigationBar});

  final Widget child; // aquí va el contenido que cambia
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final bar = context.watch<AppBarController>();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: bar.title.isEmpty
          ? null
          : AppBar(
              backgroundColor: bar.backgroundColor ?? AppColors.teal,
              foregroundColor: bar.foregroundColor ?? Colors.white,
              elevation: bar.elevation,
              centerTitle: bar.centerTitle,
              leading: bar.showBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: bar.onBack ??
                          () => Navigator.of(context).maybePop(),
                    )
                  : null,
              title: Text(
                bar.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: bar.actions,
            ),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}