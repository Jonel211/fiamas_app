import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Círculo gris con cámara y botón "Añadir imagen".
class ProductPhotoPicker extends StatelessWidget {
  const ProductPhotoPicker({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Material(
        color: AppColors.mist,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 84,
            height: 84,
            child: Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.ink),
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          side: const BorderSide(color: AppColors.mist),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: const Text('Añadir imagen'),
      ),
    ]);
  }
}