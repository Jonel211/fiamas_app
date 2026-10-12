import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text(
            'Más / Ayuda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 16),
          // Lista de opciones, perfil, ajustes o preguntas frecuentes
        ],
      ),
    );
  }
}
