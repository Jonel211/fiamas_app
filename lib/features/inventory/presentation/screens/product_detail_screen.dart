import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/product.dart';
import '../../domain/sale_unit.dart';
import '../widgets/product_detail_field.dart';
import 'new_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  static const _gold = Color(0xFFE0AB3C);

  bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final priceText =
        'S/. ${product.precioVenta.toStringAsFixed(2)}${product.tipoVenta == SaleUnit.kilo ? ' / kg' : ''}';

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Detalle del producto'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _ProductImage(url: product.imagenUrl)),
                  const SizedBox(height: 28),
                  ProductDetailField(label: 'Nombre', value: product.nombre),
                  ProductDetailField(
                    label: 'Categoría',
                    value: product.categoria?.nombre ?? 'Sin categoría',
                  ),
                  if (_hasText(product.descripcion))
                    ProductDetailField(
                      label: 'Descripción',
                      value: product.descripcion!,
                    ),
                  if (!product.tipoVenta.value.contains('kg') &&
                      _hasText(product.codigoBarras))
                    ProductDetailField(
                      label: 'Código de barras',
                      value: product.codigoBarras!,
                    ),
                  ProductDetailField(label: 'Precio', value: priceText),
                  ProductDetailField(
                    label: 'Estado',
                    value: product.activo ? 'Activo' : 'Inactivo',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              8,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewProductScreen(product: product),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto actualizado correctamente'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Editar producto'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 140,
      height: 140,
      color: const Color(0xFFF1F1F1),
      child: const Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.inkMuted,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: (url == null || url!.isEmpty)
          ? placeholder
          : Image.network(
              url!,
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
