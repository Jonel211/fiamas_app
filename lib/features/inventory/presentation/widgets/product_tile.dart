import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.onTap, this.onEdit});

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  IconData get _icon {
    switch (product.icon) {
      case IconName.bottle:
        return Icons.water_drop_outlined;
      case IconName.cookie:
        return Icons.cookie_outlined;
      case IconName.bread:
        return Icons.bakery_dining_outlined;
      case IconName.generic:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.mist),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: AppColors.ink, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.3,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}