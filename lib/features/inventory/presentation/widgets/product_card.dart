import 'package:flutter/material.dart';

import '../../../../core/widgets/image_placeholder.dart';
import '../../domain/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.active = true,
    this.onTap,
    this.onToggle,
  });

  final Product product;
  final bool active;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final priceText = 'S/ ${product.precioVenta.toStringAsFixed(2)}';
    final hasImage = product.imagenUrl != null && product.imagenUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: hasImage
                            ? SizedBox.expand(
                                child: Image.network(
                                  product.imagenUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const ImagePlaceholder(),
                                ),
                              )
                            : const ImagePlaceholder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (onToggle != null) {
                    onToggle!(!active);
                  }
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 20,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFFFA500)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 16,
                              height: 16,
                              margin: EdgeInsets.only(left: active ? 14 : 2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
