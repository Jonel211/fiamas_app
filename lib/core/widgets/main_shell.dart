import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_bottom_nav.dart';
import '../../main.dart';
import '../../features/dashboard/presentation/screens/store_summary_screen.dart';
import '../../features/inventory/presentation/screens/products_screen.dart';
import '../../features/inventory/presentation/screens/new_product_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/debts/presentation/screens/new_debt_customer_screen.dart';
import '../../features/help/presentation/screens/help_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // LISTA DE 5 PANTALLAS (Índices 0 a 4)
  final List<Widget> _pages = const [
    StoreSummaryScreen(), // 0: Inicio
    ProductsScreen(), // 1: Productos
    DebtsScreen(), // 2: Fiados
    CustomerListScreen(), // 3: Clientes
    HelpScreen(), // 4: Más / Ayuda
  ];

  Widget? _buildFab() {
    if (_currentIndex == 1) {
      // FAB para Productos
      return FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const NewProductScreen())),
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else if (_currentIndex == 2) {
      // FAB para Fiados
      return FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewDebtCustomerScreen()),
        ),
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo fiado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }
    // Ya NO hay FAB para Clientes (índice 3)
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        onFiadoTap: () {
          // CORREGIDO: Ahora abre la pantalla de Registro Fiado
          Navigator.of(context).pushNamed(AppRoutes.registroFiado);
        },
      ),
    );
  }
}