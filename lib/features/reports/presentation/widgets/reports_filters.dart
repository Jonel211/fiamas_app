import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const ReportsFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    // etiqueta -> valor que espera el backend
    const filtros = {
      'Hoy': 'hoy',
      'Esta Semana': 'semana',
      'Mes Actual': 'mes',
      'Todo': 'todo',
    };
    final etiquetas = filtros.keys.toList();

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SizedBox(
        height: 38,
        width: double.infinity,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: etiquetas.length,
          itemBuilder: (context, index) {
            final label = etiquetas[index];
            final valor = filtros[label]!;
            final isActive = selectedFilter == valor;

            return GestureDetector(
              onTap: () => onFilterSelected(valor),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.teal : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive ? AppColors.teal : AppColors.mist),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.inkMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}