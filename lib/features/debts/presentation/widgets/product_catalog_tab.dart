import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'weight_product_bottom_sheet.dart';
import 'scanner_bottom_sheet.dart';

class ProductCatalogTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) onAdd;
  final Function(int, int) onUpdateQuantity;

  const ProductCatalogTab({
    super.key,
    required this.cartItems,
    required this.onAdd,
    required this.onUpdateQuantity,
  });

  @override
  State<ProductCatalogTab> createState() => _ProductCatalogTabState();
}

class _ProductCatalogTabState extends State<ProductCatalogTab> {
  double _panelHeight = 320;
  final double _minHeight = 200;
  final double _maxHeight = 500;

  void _showWeightSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WeightProductBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = [
      {'name': 'Agua San Mateo', 'price': '2.50', 'color': Colors.blue, 'isWeight': false},
      {'name': 'Inca Kola 500ml', 'price': '3.50', 'color': Colors.yellow, 'isWeight': false},
      {'name': 'Galletas Oreo', 'price': '1.80', 'color': Colors.brown, 'isWeight': false},
      {'name': 'Arroz Costeño 1kg', 'price': '4.80', 'color': Colors.blueGrey, 'isWeight': true},
    ];

    return Column(
      children: [
        // CONTENIDO DEL CATÁLOGO (Se achica al subir el panel)
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
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar producto...',
                        hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.inkMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildChip('Todos', isSelected: true),
                      _buildChip('Bebidas'),
                      _buildChip('Snacks'),
                      _buildChip('Limpieza'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final isWeight = p['isWeight'] as bool;
                      return _ProductCard(
                        name: p['name'] as String,
                        price: p['price'] as String,
                        bgColor: p['color'] as Color,
                        onAdd: () {
                          if (isWeight) {
                            _showWeightSheet(context);
                          } else {
                            widget.onAdd(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${p['name']} agregado'), duration: const Duration(seconds: 1)),
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
        
        // PANEL DESLIZABLE (Igual que en la cámara)
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _panelHeight,
          child: ScannerBottomSheet(
            cartItems: widget.cartItems,
            onUpdateQuantity: widget.onUpdateQuantity,
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

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.teal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.teal : AppColors.mist),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.name, required this.price, required this.bgColor, required this.onAdd});
  final String name;
  final String price;
  final Color bgColor;
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
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(child: Icon(Icons.inventory_2_rounded, size: 48, color: bgColor.withOpacity(0.5))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('S/ $price', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.inkMuted)),
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