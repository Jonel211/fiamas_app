import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import 'status_badge.dart';

class CustomerCard extends StatelessWidget {
  final String id;
  final String name;
  final String phone;
  final String status;
  final double debtAmount;
  final String extraInfo;
  final VoidCallback onTapProfile; // ✅ Nuevo
  final VoidCallback onTapHistory; // ✅ Nuevo

  const CustomerCard({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.debtAmount,
    required this.extraInfo,
    required this.onTapProfile,
    required this.onTapHistory,
  });

  Color _getAvatarColor() {
    final colors = [
      AppColors.teal,
      AppColors.danger,
      AppColors.gold,
      AppColors.skyBlue,
      AppColors.purple,
    ];
    final index = id.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ 1. ZONA DEL AVATAR (Lleva al Perfil)
          GestureDetector(
            onTap: onTapProfile,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: _getAvatarColor(),
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ✅ 2. ZONA DEL RESTO DE LA TARJETA (Lleva al Historial)
          Expanded(
            child: InkWell(
              onTap: onTapHistory,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              StatusBadge(status: status),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  extraInfo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'S/ ${debtAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: debtAmount > 0 ? AppColors.gold : AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(Icons.chevron_right, color: AppColors.inkMuted, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}