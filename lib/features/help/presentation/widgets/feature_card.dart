import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Card pequeña que describe una capacidad de la app.
/// Se usa en el grid "Qué puedes hacer".
class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal.withOpacity(0.45)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.3,
        ),
      ),
    );
  }
}