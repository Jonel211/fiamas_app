// lib/features/debts/presentation/widgets/product_catalog_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../customers/data/models/cliente_model.dart'; 
import '../../../inventory/domain/inventory_provider.dart';
import '../../../inventory/domain/product.dart';
import '../../../inventory/domain/sale_unit.dart'; // ✅ Importamos SaleUnit
import 'weight_product_bottom_sheet.dart'; // ✅ Importamos el modal
import 'scanner_bottom_sheet.dart';

class ProductCatalogTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Product) onAdd;
  final Function(Map<String, dynamic>) onAddWithQuantity; // ✅ NUEVO
  final Function(int, int) onUpdateQuantity;
  final ClienteModel cliente; 

  const ProductCatalogTab({
    super.key,
    required this.cartItems,
    required this.onAdd,
    required this.onAddWithQuantity, // ✅ NUEVO
    required this.onUpdateQuantity,
    required this.cliente, 
  });

  @override
  State<ProductCatalogTab> createState() => _ProductCatalogTabState();
}

class _ProductCatalogTabState extends State<ProductCatalogTab> {
  double _panelHeight = 320;
  final double _minHeight = 200;
  final double _maxHeight = 500;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    
    final productos = inventory.activeProducts.where((p) => 
      p.nombre.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColors.ivory,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.mist),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Buscar producto...',
                        hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.inkMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                if (inventory.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (productos.isEmpty)
                  const Center(child: Text('No hay productos registrados', style: TextStyle(color: AppColors.inkMuted)))
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final p = productos[index];
                        return _ProductCard(
                          product: p,
                          onAdd: () async {
                            // ✅ VALIDACIÓN: Si es por kilo, abrimos el modal de peso
                            if (p.tipoVenta == SaleUnit.kilo) {
                              final result = await showModalBottomSheet<Map<String, dynamic>>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => WeightProductBottomSheet(product: p),
                              );
                              if (result != null) {
                                widget.onAddWithQuantity(result);
                              }
                            } else {
                              // Si es por unidad, se agrega normal
                              widget.onAdd(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${p.nombre} agregado'), duration: const Duration(seconds: 1)),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _panelHeight,
          child: ScannerBottomSheet(
            cartItems: widget.cartItems,
            onUpdateQuantity: widget.onUpdateQuantity,
            cliente: widget.cliente,
            onDrag: (deltaY) {
              setState(() {
                _panelHeight -= deltaY;
                if (_panelHeight < _minHeight) _panelHeight = _minHeight;
                if (_panelHeight > _maxHeight) _panelHeight = _maxHeight;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onAdd});
  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.skyBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(child: Icon(Icons.inventory_2_rounded, size: 48, color: AppColors.teal)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.tipoVenta == SaleUnit.kilo 
                        ? 'S/ ${product.precioVenta.toStringAsFixed(2)}/kg' 
                        : 'S/ ${product.precioVenta.toStringAsFixed(2)}', 
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.inkMuted)
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}