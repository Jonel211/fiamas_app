import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';
import 'app_header_config.dart';
import '../../main.dart';
import '../../features/dashboard/presentation/screens/store_summary_screen.dart';
import '../../features/inventory/presentation/screens/products_screen.dart';
import '../../features/inventory/presentation/screens/new_product_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/menu/presentation/screens/more_options_screen.dart';

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
    StoreSummaryScreen(),
    ProductsScreen(),
    DebtsScreen(),
    CustomerListScreen(),
    MoreOptionsScreen(),
  ];

  List<Widget> _buildHeaderActions() {
    if (_currentIndex == 3) {
      return [
        AppHeaderPillAction(
          label: 'scoring',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.scoringHistory),
        ),
      ];
    }
    return [
      AppHeaderIconAction(
        icon: Icons.notifications_none,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
      ),
    ];
  }

  Widget? _buildFab() {
    if (_currentIndex == 1) {
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
      return FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.registroFiado),
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
    return AppHeaderConfig(
      visible: _currentIndex != 0,
      title: 'Bodega Gian Carlos',
      centerTitle: true,
      actions: _buildHeaderActions(),
      child: Scaffold(
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
            Navigator.of(context).pushNamed(AppRoutes.registroFiado);
          },
        ),
      ),
    );
  }
}
