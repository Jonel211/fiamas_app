import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/sale_unit.dart';

/// Dos botones "Unidad" / "Kilo (kg)". El elegido se pinta en azul claro.
class SaleUnitSelector extends StatelessWidget {
  const SaleUnitSelector({super.key, required this.selected, required this.onChanged});

  final SaleUnit selected;
  final ValueChanged<SaleUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final unit in SaleUnit.values) ...[
        if (unit != SaleUnit.values.first) const SizedBox(width: 12),
        Expanded(
          child: _UnitButton(
            label: unit.label,
            selected: unit == selected,
            onTap: () => onChanged(unit),
          ),
        ),
      ],
    ]);
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.skyBlue : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? AppColors.skyBlue : AppColors.mist, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 46,
          child: Center(
            child: Text(label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
          ),
        ),
      ),
    );
  }
}