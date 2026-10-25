import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StoreProfileHeader extends StatelessWidget {
  final String storeName;
  final String status;
  final String? subtitle;

  const StoreProfileHeader({
    super.key,
    this.storeName = 'Mi Tienda',
    this.status = 'Activa',
    this.subtitle,
  });

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
          Text(
            storeName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.white),
                const SizedBox(width: 6),
                Text(status, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ],
      ),
    );
  }
}