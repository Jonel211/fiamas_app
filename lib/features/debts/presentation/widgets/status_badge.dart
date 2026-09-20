import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final DebtStatus status;

  bool get _isPending => status == DebtStatus.pendiente;

  @override
  Widget build(BuildContext context) {
    final color = _isPending ? AppColors.gold : AppColors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _isPending ? 'PENDIENTE' : 'PAGADO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: color,
        ),
      ),
    );
  }
}