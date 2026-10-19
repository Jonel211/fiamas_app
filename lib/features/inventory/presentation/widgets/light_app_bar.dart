import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Barra superior clara: flecha de regreso, título centrado y, opcionalmente,
/// un botón de acción a la derecha.
class LightAppBar extends StatelessWidget {
  const LightAppBar({super.key, required this.title, this.actionIcon, this.onAction});

  final String title;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            ),
            Expanded(
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink)),
            ),
            if (actionIcon != null)
              IconButton(onPressed: onAction, icon: Icon(actionIcon, color: AppColors.ink))
            else
              const SizedBox(width: 48),
          ]),
        ),
      ),
    );
  }
}