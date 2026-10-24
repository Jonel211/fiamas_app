import 'package:flutter/material.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../main.dart';

/// Wrapper delgado para mantener compatibilidad si quedara algún uso.
/// Usa AppHeader con diseño unificado.
class ProductsTopBar extends StatelessWidget {
  const ProductsTopBar({super.key, required this.storeName, this.onBellTap});

  final String storeName;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: storeName,
      actions: [
        AppHeaderIconAction(
          icon: Icons.notifications_none,
          onTap: onBellTap ??
              () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
      ],
    );
  }
}
