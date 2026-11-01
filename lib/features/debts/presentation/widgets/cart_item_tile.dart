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
    this.isWeight = false, 
    this.onTap,
    this.onRemove, 
  });

  final String name;
  final double price;
  final double quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String? imageUrl;
  final bool isWeight;
  final VoidCallback? onTap;
  final VoidCallback? onRemove; 

  @override
  Widget build(BuildContext context) {
    final qtyText = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
            
            if (isWeight)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$qtyText kg', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)
                  ),
                  // ESPACIADO AGREGADO AQUI
                  const SizedBox(width: 12), 
                  if (onRemove != null)
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      ),
                    ),
                ],
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