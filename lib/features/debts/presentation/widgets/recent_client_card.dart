import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tarjeta de cliente reciente para la pantalla de Registro de Fiado.
/// Muestra avatar, nombre, teléfono y una etiqueta de calificación.
class RecentClientCard extends StatelessWidget {
  const RecentClientCard({
    super.key,
    required this.name,
    required this.phone,
    this.ratingLabel = 'Buen pagador',
    this.onTap,
  });

  final String name;
  final String phone;
  final String ratingLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mist),
        ),
        child: Row(
          children: [
            // Avatar (círculo gris con silueta)
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.mist,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),

            // Nombre y Teléfono
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),

            // Etiqueta "Buen pagador"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ratingLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}