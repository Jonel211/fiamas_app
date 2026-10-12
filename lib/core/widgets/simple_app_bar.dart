import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Barra superior simple: fondo teal + flecha atrás + título centrado.
/// Reutilizable en pantallas que no tienen campana ni menú.
/// Ej: Nueva Tienda, Cambiar Contraseña, Términos y Condiciones, etc.
class SimpleAppBar extends StatelessWidget {
  const SimpleAppBar({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            splashRadius: 22,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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