import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';

class DebtAvatar extends StatelessWidget {
  const DebtAvatar({
    super.key,
    required this.initials,
    this.status,
    this.radius = 20,
  });

  final String initials;
  final DebtStatus? status;
  final double radius;

  Color get _accentColor {
    switch (status) {
      case DebtStatus.pendiente:
        return AppColors.gold;
      case DebtStatus.pagado:
        return AppColors.teal;
      case null:
        return AppColors.mist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mist,
        border: Border.all(color: _accentColor, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.55,
          color: AppColors.ink,
        ),
      ),
    );
  }
}