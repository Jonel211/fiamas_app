import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StoreProfileHeader extends StatelessWidget {
  const StoreProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.storefront_rounded, size: 40, color: AppColors.teal),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bodega San Antonio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.white),
                SizedBox(width: 6),
                Text('Activa', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'En la app desde marzo 2024',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}