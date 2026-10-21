import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// Tarjeta de estadística (Cuadrada)
class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.teal),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}

// Botón de Eliminar Tienda
class DeleteStoreTile extends StatelessWidget {
  const DeleteStoreTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Eliminar tienda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}