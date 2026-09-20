import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.onEdit});

  final Product product;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist),
      ),
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
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink)),
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
                    color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit_outlined,
                    size: 15, color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}