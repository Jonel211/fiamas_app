import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsFilters extends StatelessWidget {
  const ReportsFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['Hoy', 'Esta Semana', 'Mes Actual', 'Personalizado'];
    
    return SizedBox(
      height: 38, // <-- CORREGIDO: Antes era 50, ahora es más delgado
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = index == 1;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14), // <-- Un poco menos de ancho
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? AppColors.teal : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isActive ? AppColors.teal : AppColors.mist),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index == 3) ...[
                  Icon(Icons.calendar_today_rounded, size: 12, color: isActive ? Colors.white : AppColors.ink), // Ícono un poco más pequeño
                  const SizedBox(width: 4),
                ],
                Text(
                  filters[index],
                  style: TextStyle(
                    fontSize: 12, // <-- Letra un poco más pequeña para que encaje
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}