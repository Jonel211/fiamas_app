import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/product.dart';

/// Tarjeta gris del grid: interruptor activo, imagen, nombre y precio.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.active,
    required this.onTap,
    required this.onToggle,
  });

  final Product product;
  final bool active;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  IconData get _icon {
    switch (product.icon) {
      case IconName.bottle:
        return Icons.water_drop_outlined;
      case IconName.cookie:
        return Icons.cookie_outlined;
      case IconName.bread:
        return Icons.bakery_dining_outlined;
      case IconName.generic:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _MiniSwitch(value: active, onChanged: onToggle),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, size: 36, color: AppColors.inkMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.ink)),
            const SizedBox(height: 2),
            Text('S/ ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink)),
          ]),
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _gold = Color(0xFFE0AB3C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? _gold : AppColors.teal,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}