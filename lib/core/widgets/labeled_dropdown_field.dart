import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Campo de selección con el mismo look que [LabeledField] (label arriba,
/// ícono a la izquierda, caja con borde), pero usando un dropdown en vez
/// de texto libre.
class LabeledDropdownField extends StatelessWidget {
  const LabeledDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.icon,
    this.validator,
  });

  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final IconData? icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.inkMuted, size: 20),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppColors.inkMuted)
                : null,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}