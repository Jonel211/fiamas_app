import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.initial,
    required this.avatarBg,
    required this.avatarFg,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.time,
    required this.showBorder,
  });

  final String initial;
  final Color avatarBg;
  final Color avatarFg;
  final String name;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String time;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF0F3F6), width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarBg,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: avatarFg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPositive
                      ? const Color(0xFF148F8B)
                      : const Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}