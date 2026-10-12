import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Indicador de progreso "1 → 2 → 3".
///
/// Los pasos alcanzados se pintan en dorado. Cada conector que sale de un
/// paso alcanzado lleva flecha; los demás son una línea simple.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.currentStep, this.totalSteps = 3});

  /// Paso actual, desde 1.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int step = 1; step <= totalSteps; step++) ...[
          _StepBox(number: step, reached: step <= currentStep),
          if (step < totalSteps) _Connector(withArrow: step <= currentStep),
        ],
      ],
    );
  }
}

class _StepBox extends StatelessWidget {
  const _StepBox({required this.number, required this.reached});

  final int number;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: reached ? AppColors.gold : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: reached
            ? null
            : Border.all(color: AppColors.inkMuted.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: reached ? Colors.white : AppColors.inkMuted,
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.withArrow});

  final bool withArrow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: withArrow
          ? const Icon(Icons.arrow_right_alt, size: 44, color: AppColors.ink)
          : Center(
              child: Container(
                width: 40,
                height: 1.5,
                color: AppColors.ink,
              ),
            ),
    );
  }
}