import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Buscador azul claro + botón de filtros.
class ProductsSearchBar extends StatelessWidget {
  const ProductsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar producto o categoría',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
            prefixIcon: const Icon(Icons.search, color: AppColors.inkMuted),
            filled: true,
            fillColor: AppColors.skyBlue,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Material(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onFilter,
          borderRadius: BorderRadius.circular(10),
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(Icons.tune, color: Colors.white, size: 22),
          ),
        ),
      ),
    ]);
  }
}