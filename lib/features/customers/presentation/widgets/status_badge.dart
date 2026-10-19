import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case 'Al día':
        return AppColors.success;
      case 'Con deuda':
        return AppColors.gold;
      case 'Vencido':
        return AppColors.danger;
      default:
        return AppColors.inkMuted;
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case 'Al día':
        return AppColors.success.withOpacity(0.15);
      case 'Con deuda':
        return AppColors.gold.withOpacity(0.15);
      case 'Vencido':
        return AppColors.danger.withOpacity(0.15);
      default:
        return AppColors.inkMuted.withOpacity(0.15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getColor(),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
