import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart' show AppRoutes;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../domain/inventory_provider.dart';
import '../../domain/product.dart';
import '../widgets/product_card.dart';
import '../widgets/products_search_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  String _query = '';
  
  // Variables de filtros
  String? _selectedCategory;
  String _selectedStatus = 'todos';
  String _selectedSort = 'nombre_asc';
  double? _minPrice;
  double? _maxPrice;

  void _loadDataForCurrentStore() {
    final authProvider = context.read<AuthProvider>();
    final tiendaProvider = context.read<TiendaProvider>();
    final inventoryProvider = context.read<InventoryProvider>();

    final currentTiendaId = tiendaProvider.tiendaSeleccionadaId ?? authProvider.tiendaId;
    final token = authProvider.token;

    if (currentTiendaId != null && token != null) {
      inventoryProvider.updateTiendaContext(token, currentTiendaId);
      inventoryProvider.loadProducts();
      inventoryProvider.loadCategories();
    }
  }

  Future<void> _onRefresh() async {
    final authProvider = context.read<AuthProvider>();
    final tiendaProvider = context.read<TiendaProvider>();
    final inventoryProvider = context.read<InventoryProvider>();

    final currentTiendaId = tiendaProvider.tiendaSeleccionadaId ?? authProvider.tiendaId;
    final token = authProvider.token;

    if (currentTiendaId != null && token != null) {
      inventoryProvider.updateTiendaContext(token, currentTiendaId);
      await Future.wait([
        inventoryProvider.loadProducts(),
        inventoryProvider.loadCategories(),
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentStore();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // MÉTODO PARA ABRIR EL BOTTOM SHEET DE FILTROS
  void _openFilterSheet() {
    final provider = context.read<InventoryProvider>();
    final categoriasActivas = provider.categories.where((c) => c.activo).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => FilterBottomSheet(
        categories: categoriasActivas,
        selectedCategory: _selectedCategory,
        selectedStatus: _selectedStatus,
        selectedSort: _selectedSort,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApplyFilters: (options) {
          setState(() {
            _selectedCategory = options.category;
            _selectedStatus = options.status;
            _selectedSort = options.sort;
            _minPrice = options.minPrice;
            _maxPrice = options.maxPrice;
          });
        },
      ),
    );
  }

  // MÉTODO PARA ACTIVAR/DESACTIVAR PRODUCTO
  Future<void> _toggleProduct(Product product, bool nuevoEstado) async {
    try {
      await context.read<InventoryProvider>().toggleProductActive(product.id, nuevoEstado);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoEstado ? 'Producto activado' : 'Producto desactivado'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // MÉTODO DE FILTRADO COMPLETO
  List<Product> _getFilteredProducts(List<Product> products) {
    final q = _query.trim().toLowerCase();
    
    List<Product> filtered = products.where((p) {
      // Filtro por búsqueda
      final categoriaNombre = p.categoria?.nombre ?? '';
      final matchesQuery = q.isEmpty || 
          p.nombre.toLowerCase().contains(q) || 
          categoriaNombre.toLowerCase().contains(q);
      
      // Filtro por categoría
      final matchesCategory = _selectedCategory == null || p.categoriaId == _selectedCategory;
      
      // Filtro por estado
      final matchesStatus = _selectedStatus == 'todos' || 
          (_selectedStatus == 'activo' && p.activo) ||
          (_selectedStatus == 'inactivo' && !p.activo);
      
      // Filtro por precio
      final matchesPrice = (_minPrice == null || p.precioVenta >= _minPrice!) &&
          (_maxPrice == null || p.precioVenta <= _maxPrice!);
      
      return matchesQuery && matchesCategory && matchesStatus && matchesPrice;
    }).toList();
    
    // Ordenamiento
    switch (_selectedSort) {
      case 'nombre_asc':
        filtered.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'nombre_desc':
        filtered.sort((a, b) => b.nombre.compareTo(a.nombre));
        break;
      case 'precio_asc':
        filtered.sort((a, b) => a.precioVenta.compareTo(b.precioVenta));
        break;
      case 'precio_desc':
        filtered.sort((a, b) => b.precioVenta.compareTo(a.precioVenta));
        break;
    }
    
    return filtered;
  }

  void _toggleCategory(String category) {
    setState(() => _selectedCategory = _selectedCategory == category ? null : category);
  }

  void _clearFilters() {
    _search.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = '';
      _selectedCategory = null;
      _selectedStatus = 'todos';
      _selectedSort = 'nombre_asc';
      _minPrice = null;
      _maxPrice = null;
    });
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) return const Center(child: CircularProgressIndicator());
        
        final products = _getFilteredProducts(provider.products);
        final categoriasActivas = provider.categories.where((c) => c.activo).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.teal,
                backgroundColor: Colors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                onFilter: _openFilterSheet,
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
                                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.categories),
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
                            itemCount: categoriasActivas.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              if (i == 0) {
                                return _CategoryChip(label: 'Todos', selected: _selectedCategory == null, onTap: () => setState(() => _selectedCategory = null));
                              }
                              final c = categoriasActivas[i - 1];
                              return _CategoryChip(label: c.nombre, selected: _selectedCategory == c.id, onTap: () => _toggleCategory(c.id));
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 0), child: Text('Productos Recientes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink))),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    sliver: products.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Text(
                                  'No se encontraron productos',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _clearFilters,
                                  icon: const Icon(Icons.filter_alt_off),
                                  label: const Text('Limpiar filtros'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 12, childAspectRatio: 0.70),
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                active: product.activo,
                                onTap: () => _openDetail(product),
                                onToggle: (nuevoEstado) => _toggleProduct(product, nuevoEstado),
                              );
                            }, childCount: products.length),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
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
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}