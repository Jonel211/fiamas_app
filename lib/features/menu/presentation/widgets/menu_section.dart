import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Contenedor de una sección del menú (con título y contenido).
/// Ej: "DATOS Y RESPALDO", "SOPORTE", "LEGAL".
class MenuSection extends StatelessWidget {
  const MenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.inkMuted,
            ),
          ),
        ),
        // Contenedor blanco con los items
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.mist),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}