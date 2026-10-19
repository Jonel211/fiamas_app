import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/scanner_tab.dart';
import '../widgets/product_catalog_tab.dart';

class ScannerViewScreen extends StatefulWidget {
  const ScannerViewScreen({super.key});

  @override
  State<ScannerViewScreen> createState() => _ScannerViewScreenState();
}

class _ScannerViewScreenState extends State<ScannerViewScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 🛒 Estado global del carrito
  final List<Map<String, dynamic>> _cartItems = [
    {'id': '1', 'name': 'Agua San Mateo 1L', 'price': 2.50, 'qty': 1},
    {'id': '2', 'name': 'Galletas Oreo', 'price': 1.80, 'qty': 2},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Funciones para modificar el carrito
  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      int index = _cartItems.indexWhere((item) => item['name'] == product['name']);
      if (index >= 0) {
        _cartItems[index]['qty'] += 1;
      } else {
        _cartItems.add({
          'id': DateTime.now().toString(),
          'name': product['name'],
          'price': double.parse(product['price']),
          'qty': 1,
        });
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index]['qty'] += delta;
      if (_cartItems[index]['qty'] <= 0) {
        _cartItems.removeAt(index);
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
            // BARRA SUPERIOR COMPARTIDA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
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
                  const SizedBox(width: 8),
                  if (isDark)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flashlight_on_rounded, color: Colors.white, size: 20),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),

            // CONTENIDO DESLIZABLE
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  // Pasamos los datos a la pestaña del escáner
                  ScannerTab(
                    cartItems: _cartItems,
                    onUpdateQuantity: _updateQuantity,
                  ),
                  // Pasamos los datos y la función de agregar al catálogo
                  ProductCatalogTab(
                    cartItems: _cartItems,
                    onAdd: _addToCart,
                    onUpdateQuantity: _updateQuantity,
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
                color: isActive
                    ? (isDark ? AppColors.ink : Colors.white)
                    : (isDark ? Colors.white70 : AppColors.inkMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}