import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Barra superior de la pantalla "Mis Tiendas".
/// Fondo teal + hamburguesa + título centrado + campana.
class StoresAppBar extends StatelessWidget {
  const StoresAppBar({super.key, this.onMenuTap, this.onBellTap});

  final VoidCallback? onMenuTap;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            splashRadius: 22,
          ),
          const Expanded(
            child: Text(
              'Mis Tiendas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          IconButton(
            onPressed: onBellTap,
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            splashRadius: 22,
          ),
        ],
      ),
    );
  }
}