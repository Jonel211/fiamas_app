import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../inventory/domain/inventory_provider.dart';
import '../../../inventory/domain/product.dart';
import '../widgets/scanner_tab.dart';
import '../widgets/product_catalog_tab.dart';
import '../widgets/weight_product_bottom_sheet.dart'; 

class ScannerViewScreen extends StatefulWidget {
  final ClienteModel cliente;
  const ScannerViewScreen({super.key, required this.cliente});

  @override
  State<ScannerViewScreen> createState() => _ScannerViewScreenState();
}

class _ScannerViewScreenState extends State<ScannerViewScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
          context.read<AuthProvider>().user?.tiendaId;
      if (tiendaId != null) {
        context.read<InventoryProvider>().loadProducts(); 
      }
    });
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _addToCart(Product product) {
    setState(() {
      int index = _cartItems.indexWhere((item) => item['producto_id'] == product.id);
      if (index >= 0) {
        _cartItems[index]['qty'] += 1.0;
      } else {
        _cartItems.add({
          'producto_id': product.id,
          'name': product.nombre,
          'price': product.precioVenta,
          'qty': 1.0,
          'isWeight': false,
          'imagenUrl': product.imagenUrl,
        });
      }
    });
  }

  // Funcion que recibe el producto pesado con su cantidad
  void _addToCartWithQuantity(Map<String, dynamic> cartItem) {
    setState(() {
      int index = _cartItems.indexWhere((item) => item['producto_id'] == cartItem['producto_id']);
      if (index >= 0) {
        _cartItems[index]['qty'] += cartItem['qty'];
      } else {
        _cartItems.add({
          ...cartItem,
          'isWeight': true, // Declarado por kilo
        });
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index]['qty'] += delta;
      if (_cartItems[index]['qty'] <= 0) _cartItems.removeAt(index);
    });
  }

  // NUEVO: Funcion para eliminar un item del carrito
  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _editWeightItem(int index) {
    final item = _cartItems[index];
    final inventory = context.read<InventoryProvider>();
    final product = inventory.products.firstWhere((p) => p.id == item['producto_id']);

    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WeightProductBottomSheet(
        product: product,
        initialQty: (item['qty'] as num).toDouble(),
      ),
    ).then((result) {
      if (result != null && mounted) {
        setState(() {
          // Si el modal devuelve qty 0, significa que se debe eliminar
          if (result['qty'] <= 0) {
            _cartItems.removeAt(index);
          } else {
            _cartItems[index]['qty'] = result['qty'];
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _currentIndex == 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E2025) : AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.ink),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: isDark ? null : Border.all(color: AppColors.mist),
                      ),
                      child: Row(
                        children: [
                          _buildTopTab('Escanear', 0, isDark),
                          _buildTopTab('Productos', 1, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  ScannerTab(
                    cliente: widget.cliente,
                    cartItems: _cartItems,
                    onUpdateQuantity: _updateQuantity,
                    onProductScanned: _addToCart,
                    onEditWeightItem: _editWeightItem,
                    onRemoveItem: _removeItem, // LE PASAMOS LA FUNCION
                  ),
                  ProductCatalogTab(
                    cliente: widget.cliente,
                    cartItems: _cartItems,
                    onAdd: _addToCart,
                    onAddWithQuantity: _addToCartWithQuantity, // Le pasamos la función de por kilo
                    onUpdateQuantity: _updateQuantity,
                    onEditWeightItem: _editWeightItem,
                    onRemoveItem: _removeItem, // LE PASAMOS LA FUNCION
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTab(String text, int index, bool isDark) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white : AppColors.teal) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isActive ? (isDark ? AppColors.ink : Colors.white) : (isDark ? Colors.white70 : AppColors.inkMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}