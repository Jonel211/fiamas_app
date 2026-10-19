import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Fila "Producto Activo" con su interruptor.
class ActiveSwitchRow extends StatelessWidget {
  const ActiveSwitchRow({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(
        child: Text('Producto Activo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.teal : AppColors.mist,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ]);
  }
}