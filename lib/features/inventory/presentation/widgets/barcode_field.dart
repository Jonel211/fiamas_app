import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import 'product_input_style.dart';

/// Sección "Código de barras": etiqueta con botón de escáner y el campo.
class BarcodeField extends StatelessWidget {
  const BarcodeField({super.key, required this.controller, required this.onScan});

  final TextEditingController controller;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Expanded(child: ProductFieldLabel('Código de barras')),
        IconButton(
          onPressed: onScan,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.qr_code_scanner, color: AppColors.ink),
        ),
      ]),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: productInputDecoration(
          prefixIcon: const Icon(Icons.view_week_outlined, color: AppColors.ink),
        ),
      ),
    ]);
  }
}