import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/product.dart';
import '../../domain/sale_unit.dart';
import '../../domain/inventory_provider.dart';
import '../widgets/product_detail_field.dart';
import 'new_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  static const _gold = Color(0xFFE0AB3C);

  bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  // ✅ MÉTODO PARA ACTUALIZAR EL PRODUCTO LOCAL CUANDO VUELVE DE LA EDICIÓN
  Future<void> _editProduct() async {
    final result = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (_) => NewProductScreen(product: _currentProduct),
      ),
    );

    // Si el resultado no es nulo, significa que se guardó exitosamente
    if (result != null && mounted) {
      setState(() {
        _currentProduct = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceText =
        'S/. ${_currentProduct.precioVenta.toStringAsFixed(2)}${_currentProduct.tipoVenta.toString().toLowerCase().contains('kg') ? ' / kg' : ''}';
    final esPorKilo =
        _currentProduct.tipoVenta.toString().toLowerCase().contains('kg') ||
        _currentProduct.tipoVenta.toString().toLowerCase().contains('kilo');

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
                  Center(child: _ProductImage(url: _currentProduct.imagenUrl)),
                  const SizedBox(height: 28),
                  ProductDetailField(
                    label: 'Nombre',
                    value: _currentProduct.nombre,
                  ),
                  ProductDetailField(
                    label: 'Categoría',
                    value: _currentProduct.categoria?.nombre ?? 'Sin categoría',
                  ),
                  if (_hasText(_currentProduct.descripcion))
                    ProductDetailField(
                      label: 'Descripción',
                      value: _currentProduct.descripcion!,
                    ),
                  if (!esPorKilo && _hasText(_currentProduct.codigoBarras))
                    ProductDetailField(
                      label: 'Código de barras',
                      value: _currentProduct.codigoBarras!,
                    ),
                  ProductDetailField(label: 'Precio', value: priceText),
                  ProductDetailField(
                    label: 'Estado',
                    value: _currentProduct.activo ? 'Activo' : 'Inactivo',
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
              onPressed: _editProduct,
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
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8),
      ),
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
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
