import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/category.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.categories,
    required this.onApplyFilters,
    this.selectedCategory,
    this.selectedStatus = 'todos',
    this.selectedSort = 'nombre_asc',
    this.minPrice,
    this.maxPrice,
  });

  final List<Category> categories;
  final String? selectedCategory;
  final String selectedStatus;
  final String selectedSort;
  final double? minPrice;
  final double? maxPrice;
  final Function(FilterOptions) onApplyFilters;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class FilterOptions {
  final String? category;
  final String status;
  final String sort;
  final double? minPrice;
  final double? maxPrice;

  FilterOptions({
    this.category,
    required this.status,
    required this.sort,
    this.minPrice,
    this.maxPrice,
  });
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategory;
  late String _selectedStatus;
  late String _selectedSort;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedStatus = widget.selectedStatus;
    _selectedSort = widget.selectedSort;
    _priceRange = RangeValues(widget.minPrice ?? 0, widget.maxPrice ?? 1000);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Contenido scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección: Categoría
                  const Text(
                    'Categoría',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        selected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      ...widget.categories.map(
                        (cat) => _FilterChip(
                          label: cat.nombre,
                          selected: _selectedCategory == cat.id,
                          onTap: () =>
                              setState(() => _selectedCategory = cat.id),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sección: Estado
                  const Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatusChip(
                        label: 'Todos',
                        selected: _selectedStatus == 'todos',
                        onTap: () => setState(() => _selectedStatus = 'todos'),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Activos',
                        selected: _selectedStatus == 'activo',
                        onTap: () => setState(() => _selectedStatus = 'activo'),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Inactivos',
                        selected: _selectedStatus == 'inactivo',
                        onTap: () =>
                            setState(() => _selectedStatus = 'inactivo'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sección: Ordenar por
                  const Text(
                    'Ordenar por',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _SortOption(
                        label: 'Nombre (A-Z)',
                        value: 'nombre_asc',
                        selected: _selectedSort == 'nombre_asc',
                        onTap: () =>
                            setState(() => _selectedSort = 'nombre_asc'),
                      ),
                      _SortOption(
                        label: 'Nombre (Z-A)',
                        value: 'nombre_desc',
                        selected: _selectedSort == 'nombre_desc',
                        onTap: () =>
                            setState(() => _selectedSort = 'nombre_desc'),
                      ),
                      _SortOption(
                        label: 'Precio (menor a mayor)',
                        value: 'precio_asc',
                        selected: _selectedSort == 'precio_asc',
                        onTap: () =>
                            setState(() => _selectedSort = 'precio_asc'),
                      ),
                      _SortOption(
                        label: 'Precio (mayor a menor)',
                        value: 'precio_desc',
                        selected: _selectedSort == 'precio_desc',
                        onTap: () =>
                            setState(() => _selectedSort = 'precio_desc'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ✅ BOTÓN APLICAR (SIN 'const' EN EL PADDING PARA QUE MEDIAQUERY FUNCIONE)
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(
                    FilterOptions(
                      category: _selectedCategory,
                      status: _selectedStatus,
                      sort: _selectedSort,
                      minPrice: _priceRange.start,
                      maxPrice: _priceRange.end,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aplicar filtros',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStatus = 'todos';
      _selectedSort = 'nombre_asc';
      _priceRange = RangeValues(0, 1000);
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.teal.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.teal : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.teal : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.teal : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
