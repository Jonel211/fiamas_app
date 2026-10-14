import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_bottom_nav.dart';
import '../../features/dashboard/presentation/screens/store_summary_screen.dart';
import '../../features/inventory/presentation/screens/products_screen.dart';
import '../../features/inventory/presentation/screens/new_product_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/debts/presentation/screens/new_debt_customer_screen.dart';
import '../../features/help/presentation/screens/help_screen.dart';

// ✅ IMPORTACIÓN DE LA NUEVA PANTALLA DE CLIENTES
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

  // ✅ LISTA DE 5 PANTALLAS (Índices 0 a 4)
  final List<Widget> _pages = const [
    StoreSummaryScreen(), // 0: Inicio
    ProductsScreen(), // 1: Productos
    DebtsScreen(), // 2: Fiados (Gestión de deudas)
    CustomerListScreen(), // 3: Clientes (Nuestra nueva pantalla)
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
          'Nuevo producto',
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
    } else if (_currentIndex == 3) {
      // ✅ FAB para Clientes
      return FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Próximamente: Agregar nuevo cliente'),
            ),
          );
        },
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nuevo cliente',
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
          // ✅ MAPEO EXPLÍCITO Y SEGURO DE ÍNDICES
          setState(() {
            if (index == 0) {
              _currentIndex = 0; // Inicio
            } else if (index == 1) {
              _currentIndex = 1; // Productos
            } else if (index == 2) {
              _currentIndex = 3; // Clientes (Salta el índice 2 que es Fiados)
            } else if (index == 3) {
              _currentIndex = 4; // Más / Ayuda
            }
          });
        },
        onFiadoTap: () {
          // El botón central "+" siempre lleva a Fiados (índice 2)
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
    );
  }
}
