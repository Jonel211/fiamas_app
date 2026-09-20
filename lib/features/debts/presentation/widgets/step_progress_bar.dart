import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Barra de progreso de 3 segmentos para el flujo de Nuevo Fiado.
/// `currentStep` es 1-indexado (1, 2 o 3).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({super.key, required this.currentStep, this.totalSteps = 3});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= totalSteps; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= currentStep ? AppColors.ink : AppColors.mist,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i != totalSteps) const SizedBox(width: 6),
        ],
      ],
    );
  }
}