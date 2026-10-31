// lib/features/debts/presentation/widgets/scanner_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../customers/data/models/cliente_model.dart';
import 'cart_item_tile.dart';

class ScannerBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int index, int delta) onUpdateQuantity;
  final Function(double)? onDrag;
  final ClienteModel cliente; 

  const ScannerBottomSheet({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    this.onDrag,
    required this.cliente, 
  });

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
    
    int totalItems = cartItems.fold(0, (sum, item) {
      final isWeight = item['isWeight'] == true;
      if (isWeight) {
        return sum + 1; 
      } else {
        return sum + (item['qty'] as num).toInt(); 
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragUpdate: onDrag != null ? (details) => onDrag!(details.delta.dy) : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos en la orden',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$totalItems ítems', 
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('No hay productos', style: TextStyle(color: AppColors.inkMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemTile(
                        name: item['name'],
                        price: item['price'],
                        quantity: (item['qty'] as num).toDouble(),
                        isWeight: item['isWeight'] ?? false, 
                        imageUrl: item['imagenUrl'], // Se pasa la imagen al widget
                        onIncrement: () => onUpdateQuantity(index, 1),
                        onDecrement: () => onUpdateQuantity(index, -1),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.mist.withOpacity(0.5))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cartItems.isEmpty 
                  ? null 
                  : () => Navigator.of(context).pushNamed(
                      AppRoutes.finalizarFiado, 
                      arguments: {
                        'cliente': cliente,
                        'cartItems': cartItems,
                      },
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fiar S/ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}