import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../main.dart';
import '../../domain/product.dart';
import '../widgets/product_tile.dart';
import 'new_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // TODO: reemplazar por datos reales desde InventoryRepository
  static const _products = [
    Product(
        id: '1',
        name: 'Agua San Mateo 1L',
        category: 'Bebidas',
        price: 2.50,
        icon: IconName.bottle),
    Product(
        id: '2',
        name: 'Galletas Soda Field',
        category: 'Snacks',
        price: 0.80,
        icon: IconName.cookie),
    Product(
        id: '3',
        name: 'Pan de Molde Unión',
        category: 'Panadería',
        price: 6.50,
        icon: IconName.bread),
  ];

  static const _categories = [
    'Bebidas',
    'Snacks',
    'Panadería',
    'Abarrotes',
    'Limpieza',
    'Otros',
  ];

  String? _selectedCategory;
  final _searchFocusNode = FocusNode();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == null) return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Filtrar por categoría',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Elige una categoría para ver solo esos productos',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        selected: _selectedCategory == null,
                        onTap: () => setSheetState(() => _selectedCategory = null),
                      ),
                      for (final category in _categories)
                        _FilterChip(
                          label: category,
                          selected: _selectedCategory == category,
                          onTap: () =>
                              setSheetState(() => _selectedCategory = category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // aplica la selección a la lista
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aplicar filtro'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text('Mis Productos',
                                style: Theme.of(context).textTheme.headlineSmall),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Mostrando ${_filteredProducts.length}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.inkMuted),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _openFilterSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.mist),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.filter_list,
                                          size: 15, color: AppColors.ink),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedCategory ?? 'Filter',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _searchFocused ? AppColors.ink : AppColors.mist,
                            width: _searchFocused ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                size: 20,
                                color: _searchFocused
                                    ? AppColors.ink
                                    : AppColors.inkMuted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar producto...',
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                onChanged: (value) {
                                  // TODO: filtrar _filteredProducts por nombre
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            'No hay productos en esta categoría',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                          children: [
                            for (final product in _filteredProducts)
                              ProductTile(
                                product: product,
                                onEdit: () {
                                  // TODO: abrir edición del producto
                                },
                              ),
                          ],
                        ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: AppColors.teal,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewProductScreen()),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            AppRoutes.goHome(context);
          } else if (index == 1) {
            Navigator.of(context).pushNamed(AppRoutes.debts);
          } else if (index == 3) {
            Navigator.of(context).pushNamed(AppRoutes.help);
          }
        },
      ),
    );
  }
}

/// Chip de selección de categoría, usado dentro del bottom sheet de filtro.
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.mist.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}