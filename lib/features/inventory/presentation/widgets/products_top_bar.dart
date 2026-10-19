import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Barra teal con el nombre de la tienda y la campana de notificaciones.
class ProductsTopBar extends StatelessWidget {
  const ProductsTopBar({super.key, required this.storeName, this.onBellTap});

  final String storeName;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.teal,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 12),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        IconButton(
          onPressed: onBellTap,
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ]),
    );
  }
}   