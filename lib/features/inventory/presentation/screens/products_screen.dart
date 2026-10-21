import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart' show AppRoutes;
import '../../domain/product.dart';
import '../widgets/product_card.dart';
import '../widgets/products_search_bar.dart';
import '../widgets/products_top_bar.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {

  static const _products = [
    Product(
      id: '1',
      name: 'Agua San Mateo 1L',
      category: 'Bebidas',
      price: 2.50,
      icon: IconName.bottle,
    ),
    Product(
      id: '2',
      name: 'Galletas Soda Field',
      category: 'Snacks',
      price: 0.80,
      icon: IconName.cookie,
    ),
    Product(
      id: '3',
      name: 'Pan de Molde Unión',
      category: 'Panadería',
      price: 6.50,
      icon: IconName.bread,
    ),
  ];

  static const _categories = [
    'Bebidas',
    'Snacks',
    'Panadería',
    'Abarrotes',
    'Limpieza',
    'Otros',
  ];

  final _search = TextEditingController();
  final Set<String> _inactive = {};
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final q = _query.trim().toLowerCase();
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesQuery =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _toggleCategory(String category) {
    setState(
      () => _selectedCategory = _selectedCategory == category ? null : category,
    );
  }

  void _clearFilters() {
    _search.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = '';
      _selectedCategory = null;
    });
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          name: product.name,
          category: product.category,
          price: product.price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductsTopBar(
          storeName: 'Bodega Gian Carlos',
          onBellTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Mis productos',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ProductsSearchBar(
                            controller: _search,
                            onChanged: (v) => setState(() => _query = v),
                            onFilter: _clearFilters,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Categorías',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.of(context)
                                        .pushNamed(AppRoutes.categories),
                                child: const Text(
                                  'Ver todo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B6CB0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return _CategoryChip(
                              label: 'Todos',
                              selected: _selectedCategory == null,
                              onTap: () =>
                                  setState(() => _selectedCategory = null),
                            );
                          }
                          final c = _categories[i - 1];
                          return _CategoryChip(
                            label: c,
                            selected: _selectedCategory == c,
                            onTap: () => _toggleCategory(c),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        'Productos Recientes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: products.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              'No se encontraron productos',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            active: !_inactive.contains(product.id),
                            onTap: () => _openDetail(product),
                            onToggle: (on) => setState(() {
                              on
                                  ? _inactive.remove(product.id)
                                  : _inactive.add(product.id);
                            }),
                          );
                        }, childCount: products.length),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.teal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}