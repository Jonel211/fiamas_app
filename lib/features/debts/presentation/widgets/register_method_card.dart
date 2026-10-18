import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tarjeta de opción para elegir cómo registrar al cliente (QR o Manual).
class RegisterMethodCard extends StatelessWidget {
  const RegisterMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isTealBackground = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTealBackground;

  @override
  Widget build(BuildContext context) {
    final bgColor = isTealBackground ? AppColors.teal : AppColors.surface;
    final textColor = isTealBackground ? Colors.white : AppColors.teal;
    final subtitleColor = isTealBackground
        ? Colors.white.withOpacity(0.8)
        : AppColors.inkMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isTealBackground
              ? null
              : Border.all(
                  color: isSelected ? AppColors.teal : AppColors.mist,
                  width: isSelected ? 2 : 1,
                ),
          // Borde izquierdo grueso si está seleccionado (estilo manual)
          boxShadow: [
            if (isSelected && !isTealBackground)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isTealBackground
                    ? Colors.white.withOpacity(0.15)
                    : AppColors.skyBlue.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isTealBackground ? Colors.white : AppColors.teal,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Ícono de acción (Chevron o Check)
            if (isTealBackground)
              const Icon(Icons.chevron_right_rounded, color: Colors.white)
            else if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.teal)
            else
              const Icon(Icons.circle_outlined, color: AppColors.mist),
          ],
        ),
      ),
    );
  }
}