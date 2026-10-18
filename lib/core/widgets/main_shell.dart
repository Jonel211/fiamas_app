import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_bottom_nav.dart';
import '../../main.dart'; // <-- Importante para usar AppRoutes
import '../../features/dashboard/presentation/screens/store_summary_screen.dart';
import '../../features/inventory/presentation/screens/products_screen.dart';
import '../../features/inventory/presentation/screens/new_product_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/debts/presentation/screens/new_debt_customer_screen.dart';
import '../../features/help/presentation/screens/help_screen.dart';

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

  final List<Widget> _pages = const [
    StoreSummaryScreen(), // Índice 0: Inicio
    ProductsScreen(),     // Índice 1: Productos
    DebtsScreen(),        // Índice 2: Clientes / Fiados
    HelpScreen(),         // Índice 3: Más / Ayuda
  ];

  Widget? _buildFab() {
    if (_currentIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const NewProductScreen())),
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else if (_currentIndex == 2) {
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
          setState(() {
            _currentIndex = index;
          });
        },
        onFiadoTap: () {
          // CORREGIDO: Ahora abre la pantalla de Registro Fiado
          Navigator.of(context).pushNamed(AppRoutes.registroFiado);
        },
      ),
    );
  }
}