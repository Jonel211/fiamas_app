import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../main.dart';
import '../../data/models/producto_model.dart';
import '../../data/producto_repository.dart';
import 'new_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _repository = ProductoRepository();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  List<ProductoModel> _productos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _tiendaNombre;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tienda = await SessionService.getTiendaActual();
    if (tienda == null) {
      setState(() {
        _errorMessage = 'No hay tienda seleccionada';
        _isLoading = false;
      });
      return;
    }

    _tiendaNombre = tienda['nombre'];

    final result = await _repository.obtenerProductosPorTienda(tienda['id']!);

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final lista = (data['data']?['productos'] ?? []) as List<dynamic>;
      setState(() {
        _productos = lista
            .map((p) => ProductoModel.fromJson(p as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Error al cargar productos';
        _isLoading = false;
      });
    }
  }

  Future<void> _irANuevoProducto() async {
    final creado = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const NewProductScreen()));
    if (creado == true) _cargarProductos();
  }

  List<ProductoModel> get _filteredProductos {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _productos;
    return _productos
        .where((p) => p.nombre.toLowerCase().contains(query))
        .toList();
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
                      Text(
                        'Mis Productos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_tiendaNombre != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _tiendaNombre!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _searchFocusNode.hasFocus
                                ? AppColors.ink
                                : AppColors.mist,
                            width: _searchFocusNode.hasFocus ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 20,
                              color: _searchFocusNode.hasFocus
                                  ? AppColors.ink
                                  : AppColors.inkMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar producto...',
                                  filled: false,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0E7C7B),
                          ),
                        )
                      : _errorMessage != null
                      ? _buildError()
                      : _filteredProductos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: AppColors.inkMuted,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aún no tienes productos',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Toca el botón + para agregar uno',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _cargarProductos,
                          color: const Color(0xFF0E7C7B),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                            itemCount: _filteredProductos.length,
                            itemBuilder: (_, i) {
                              final p = _filteredProductos[i];
                              return _ProductoCard(producto: p);
                            },
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: AppColors.teal,
                onPressed: _irANuevoProducto,
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _cargarProductos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta visual de un producto (reemplaza el ProductTile antiguo)
class _ProductoCard extends StatelessWidget {
  const _ProductoCard({required this.producto});
  final ProductoModel producto;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${producto.stockActual} ${producto.unidadMedida}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'S/ ${producto.precioVenta.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.edit_outlined,
                size: 15,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
