import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.imageUrl,
    this.isWeight = false, // ✅ NUEVO
  });

  final String name;
  final double price;
  final double quantity; // ✅ Cambiado a double
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String? imageUrl;
  final bool isWeight; // ✅ NUEVO

  @override
  Widget build(BuildContext context) {
    // Formatear cantidad (si es 1.0, que muestre 1. Si es 1.5, que muestre 1.5)
    final qtyText = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.mist.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
            child: imageUrl != null
                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl!, fit: BoxFit.cover))
                : const Icon(Icons.inventory_2_outlined, color: AppColors.inkMuted, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('S/ ${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
              ],
            ),
          ),
          
          // ✅ Si es de peso, solo mostramos el número. Si es unidad, mostramos los botones.
          if (isWeight)
             Text(
               '$qtyText kg', 
               style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)
             )
          else
            Row(
              children: [
                _buildQtyButton(icon: Icons.remove, onTap: onDecrement),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(qtyText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
                ),
                _buildQtyButton(icon: Icons.add, onTap: onIncrement),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.mist.withOpacity(0.5), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: AppColors.ink),
      ),
    );
  }
}