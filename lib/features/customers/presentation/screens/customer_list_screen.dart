import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';

import '../widgets/customer_card.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _selectedFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  // Datos de ejemplo (después vendrán del backend)
  final List<Map<String, dynamic>> _customers = [
    {
      'id': '1',
      'name': 'Doña Martha Gómez',
      'phone': '+51 987 654 321',
      'status': 'Con deuda',
      'debt': 20.00,
      'activeDebts': 2,
    },
    {
      'id': '2',
      'name': 'Don Roberto Ruiz',
      'phone': '+51 912 345 678',
      'status': 'Vencido',
      'debt': 85.00,
      'activeDebts': 1,
    },
    {
      'id': '3',
      'name': 'Carlos Mendoza',
      'phone': '+51 998 776 554',
      'status': 'Al día',
      'debt': 0.00,
      'activeDebts': 0,
    },
  ];

  List<Map<String, dynamic>> get _filteredCustomers {
    if (_selectedFilter == 'Todos') return _customers;
    return _customers.where((c) => c['status'] == _selectedFilter).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la tienda
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors.teal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bodega Gian Carlos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Clientes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_customers.length} clientes registrados',
                      style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 24),

                    // Barra de búsqueda
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.inkMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre o teléfono',
                                hintStyle: TextStyle(color: AppColors.inkMuted),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filtros tipo chip
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todos', true),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Al día',
                            false,
                            dotColor: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Con deuda',
                            false,
                            dotColor: AppColors.gold,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Vencido',
                            false,
                            dotColor: AppColors.danger,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lista de clientes
                    ..._filteredCustomers.map(
                      (customer) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomerCard(
                          id: customer['id'] as String,
                          name: customer['name'] as String,
                          phone: customer['phone'] as String,
                          status: customer['status'] as String,
                          debtAmount: customer['debt'] as double,
                          extraInfo: _getExtraInfo(customer),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/customer-profile',
                              arguments: customer,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, {Color? dotColor}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.teal : AppColors.mist),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getExtraInfo(Map<String, dynamic> customer) {
    final status = customer['status'] as String;
    final activeDebts = customer['activeDebts'] as int;

    if (status == 'Al día') return 'Sin fiados activos';
    if (status == 'Vencido') return '$activeDebts fiado vencido';
    return '$activeDebts fiados activos';
  }
}
