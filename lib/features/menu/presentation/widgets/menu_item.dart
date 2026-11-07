import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Item individual del menú.
/// Se usa para "Centro de ayuda", "Cambiar contraseña", etc.
class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleTrailing,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.iconColor = AppColors.teal,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? titleTrailing;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Ícono en caja con fondo azul claro
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    iconBackgroundColor ??
                    AppColors.skyBlue.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Título + subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (titleTrailing != null) ...[
                        const SizedBox(width: 8),
                        titleTrailing!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing (chevron o widget custom)
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
