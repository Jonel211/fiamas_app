import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';
import 'debt_avatar.dart';
import 'status_badge.dart';

class DebtTile extends StatelessWidget {
  const DebtTile({super.key, required this.debt, this.onTap});

  final Debt debt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            DebtAvatar(initials: debt.initials, status: debt.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debt.customerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      StatusBadge(status: debt.status),
                      const SizedBox(width: 6),
                      Text(debt.dateLabel,
                          style:
                              const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              'S/ ${debt.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}