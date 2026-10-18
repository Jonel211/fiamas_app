import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../widgets/product_detail_field.dart';

/// Detalle de un producto (solo lectura) con acceso a "Editar producto".
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.barcode,
    this.imageUrl,
    this.perKilo = false,
  });

  final String name;
  final String category;
  final double price;
  final String? description;
  final String? barcode;
  final String? imageUrl;
  final bool perKilo;

  static const _gold = Color(0xFFE0AB3C);

  bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  void _edit(BuildContext context) {
    // TODO: abrir la pantalla de edición (NewProductScreen en modo edición).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La edición estará disponible pronto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceText = 'S/. ${price.toStringAsFixed(2)}${perKilo ? ' / kg' : ''}';

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(children: [
        const SimpleAppBar(title: 'Detalle del producto'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: _ProductImage(url: imageUrl)),
              const SizedBox(height: 28),
              ProductDetailField(label: 'Nombre', value: name),
              ProductDetailField(label: 'Categoría', value: category),
              if (_hasText(description))
                ProductDetailField(label: 'Descripción', value: description!),
              // El código de barras solo aplica a productos por unidad.
              if (!perKilo && _hasText(barcode))
                ProductDetailField(label: 'Código de barras', value: barcode!),
              ProductDetailField(label: 'Precio', value: priceText),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.of(context).padding.bottom),
          child: ElevatedButton(
            onPressed: () => _edit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Editar producto'),
          ),
        ),
      ]),
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
      child: const Icon(Icons.image_outlined, size: 40, color: AppColors.inkMuted),
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
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}