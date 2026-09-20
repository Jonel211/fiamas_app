import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final DebtItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 17, color: AppColors.inkMuted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
                Text('S/ ${item.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
              ],
            ),
          ),
          if (onDecrement != null && onIncrement != null) ...[
            _StepperButton(icon: Icons.remove, onTap: onDecrement!),
            SizedBox(
              width: 24,
              child: Text('${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            _StepperButton(icon: Icons.add, onTap: onIncrement!),
          ] else
            Text('x${item.quantity}',
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.inkMuted),
              splashRadius: 18,
            ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: AppColors.ink),
      ),
    );
  }
}