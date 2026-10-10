import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Barra superior de la pantalla "Menú".
/// Fondo teal + flecha atrás + título centrado.
class MenuAppBar extends StatelessWidget {
  const MenuAppBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            splashRadius: 22,
          ),
          const Expanded(
            child: Text(
              'Menú',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 48), // Para centrar el título
        ],
      ),
    );
  }
}