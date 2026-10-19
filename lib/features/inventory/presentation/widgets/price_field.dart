import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'product_input_style.dart';

/// Campo "Precio venta" en forma de píldora con el prefijo S/.
/// Con `perKilo: true` muestra "/ kg" al final.
class PriceField extends StatelessWidget {
  const PriceField({super.key, required this.controller, this.perKilo = false});

  final TextEditingController controller;
  final bool perKilo;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ProductFieldLabel('Precio venta', small: true),
      SizedBox(
        width: 170,
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
          decoration: productInputDecoration(hint: '0.00', pill: true).copyWith(
            prefixText: 'S/.  ',
            prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
            suffixText: perKilo ? '/ kg' : null,
            suffixStyle: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa el precio';
            return double.tryParse(v) == null ? 'Precio no válido' : null;
          },
        ),
      ),
    ]);
  }
}