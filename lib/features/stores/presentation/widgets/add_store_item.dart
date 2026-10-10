import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tarjeta de acción para agregar una tienda nueva.
/// Mismo tamaño y estilo que [StoreListItem], pero con un "+" grande.
class AddStoreItem extends StatelessWidget {
  const AddStoreItem({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double _circleSize = 140;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _circleSize,
            height: _circleSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.skyBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.ink,
              size: 56,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nueva Tienda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}