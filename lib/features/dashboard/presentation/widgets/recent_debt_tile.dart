import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RecentDebtTile extends StatelessWidget {
  const RecentDebtTile({
    super.key,
    required this.customerName,
    required this.timeAgo,
    required this.amount,
  });

  final String customerName;
  final String timeAgo;
  final String amount;

  String get _initials {
    final parts = customerName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.mist,
            child: Text(
              _initials,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink)),
                Text(timeAgo,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}