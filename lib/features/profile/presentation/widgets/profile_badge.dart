import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Etiqueta verde claro con ícono, ej: "Cuenta verificada", "Verificado".
class ProfileBadge extends StatelessWidget {
  const ProfileBadge({
    super.key,
    required this.label,
    this.icon = Icons.check,
    this.large = false,
  });

  final String label;
  final IconData icon;

  /// Versión más grande, usada en la tarjeta principal.
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 16 : 14, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 13 : 12,
              fontWeight: FontWeight.w500,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}