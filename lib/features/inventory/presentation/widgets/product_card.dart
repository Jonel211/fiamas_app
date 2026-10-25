import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Imagen del producto
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        product.imagenUrl != null &&
                            product.imagenUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imagenUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Nombre del producto
                  Text(
                    product.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Precio
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ TOGGLE SWITCH FUNCIONAL CON ANIMACIÓN
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: () {
                  if (onToggle != null) {
                    onToggle!(!active);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFFA500)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(left: active ? 18 : 2),
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
          ],
        ),
      ),
    );
  }
}
