import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Título de sección dentro de la pantalla "Acerca de Fiamas".
/// Ej: "Quiénes Somos", "Qué puedes hacer", "Contacto".
class AboutSectionTitle extends StatelessWidget {
  const AboutSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}