import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/store.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, this.onTap});

  final Store store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_outlined,
                color: AppColors.ink, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            store.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            store.city.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.3,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Misma forma que [StoreCard] pero como acción para agregar una tienda
/// nueva. Vive junto a las tiendas reales en la grilla.
class AddStoreCard extends StatelessWidget {
  const AddStoreCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mist, width: 1.5),
            ),
            child: const Icon(Icons.add, color: AppColors.inkMuted, size: 28),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nueva Tienda',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}