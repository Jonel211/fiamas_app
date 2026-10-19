import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Par "Etiqueta en negrita + valor" que se repite en el detalle del producto.
class ProductDetailField extends StatelessWidget {
  const ProductDetailField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, color: AppColors.ink)),
      ]),
    );
  }
}