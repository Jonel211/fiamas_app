import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCurrent = stepNumber == currentStep;
        final isCompleted = stepNumber < currentStep;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent || isCompleted ? AppColors.gold : AppColors.surfaceMuted,
              ),
              child: Center(
                child: Text(
                  isCompleted ? '✓' : '$stepNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCurrent || isCompleted ? Colors.white : AppColors.inkMuted,
                  ),
                ),
              ),
            ),
            if (index < totalSteps - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.inkMuted.withOpacity(0.3),
                ),
              ),
          ],
        );
      }),
    );
  }
}