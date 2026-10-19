import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Título del grupo ("HOY") con el contador de pendientes a la derecha.
class NotificationGroupHeader extends StatelessWidget {
  const NotificationGroupHeader({super.key, required this.title, required this.pending});

  final String title;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.inkMuted)),
      const Spacer(),
      if (pending > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(pending == 1 ? '1 pendiente' : '$pending pendientes',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.teal)),
        ),
    ]);
  }
}